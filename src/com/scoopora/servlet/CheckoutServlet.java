package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        try (Connection conn = DBConnection.getConnection()) {
            List<Map<String, Object>> cartItems = CartServlet.getCartItems(conn, user.getId());
            if (cartItems.isEmpty()) { res.sendRedirect("cart"); return; }
            double subtotal = cartItems.stream().mapToDouble(i -> (double) i.get("subtotal")).sum();
            int shopId = (int) cartItems.get(0).get("shopId");
            Shop shop = CartServlet.getShop(conn, shopId);
            req.setAttribute("cartItems", cartItems);
            req.setAttribute("cartSubtotal", subtotal);
            req.setAttribute("cartShop", shop);
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/checkout.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        String fulfillment   = req.getParameter("fulfillment");
        String customerName  = req.getParameter("customerName");
        String customerPhone = req.getParameter("customerPhone");
        String houseStreet   = req.getParameter("houseStreet");
        String area          = req.getParameter("area");
        String city          = req.getParameter("city");
        String pincode       = req.getParameter("pincode");
        String instructions  = req.getParameter("instructions");

        // Input validation
        if (customerName == null || customerName.trim().isEmpty() ||
            customerPhone == null || customerPhone.trim().isEmpty()) {
            forwardWithError(req, res, user.getId(), "Name and phone number are required."); return;
        }
        if (!customerPhone.trim().matches("^[6-9]\\d{9}$")) {
            forwardWithError(req, res, user.getId(), "Enter a valid 10-digit Indian mobile number."); return;
        }
        if ("delivery".equals(fulfillment) &&
            (isBlank(houseStreet) || isBlank(area) || isBlank(city) || isBlank(pincode))) {
            forwardWithError(req, res, user.getId(), "All address fields are required for delivery."); return;
        }
        if ("delivery".equals(fulfillment) && !pincode.trim().matches("^\\d{6}$")) {
            forwardWithError(req, res, user.getId(), "Enter a valid 6-digit PIN code."); return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            List<Map<String, Object>> cartItems = CartServlet.getCartItems(conn, user.getId());
            if (cartItems.isEmpty()) { conn.rollback(); res.sendRedirect("cart"); return; }

            int shopId = (int) cartItems.get(0).get("shopId");
            Shop shop = CartServlet.getShop(conn, shopId);
            double subtotal = cartItems.stream().mapToDouble(i -> (double) i.get("subtotal")).sum();

            // Delivery area validation
            if ("delivery".equals(fulfillment)) {
                if (!shop.isHomeDelivery()) {
                    conn.rollback();
                    forwardWithError(req, res, user.getId(), "This shop does not offer home delivery. Please choose pickup."); return;
                }
                String areas = shop.getDeliveryAreas() != null ? shop.getDeliveryAreas().toLowerCase() : "";
                String enteredCity = city.trim().toLowerCase();
                String enteredArea = area.trim().toLowerCase();
                boolean areaMatch = areas.isEmpty() ||
                    Arrays.stream(areas.split(",")).map(String::trim)
                          .anyMatch(a -> enteredCity.contains(a) || enteredArea.contains(a)
                                      || a.contains(enteredCity) || a.contains(enteredArea));
                if (!areaMatch) {
                    conn.rollback();
                    forwardWithError(req, res, user.getId(),
                        "Sorry, delivery is not available to " + city.trim() + " / " + area.trim() +
                        ". Available areas: " + shop.getDeliveryAreas() +
                        (shop.isPickupAvailable() ? ". You can choose Pickup instead." : ".")); return;
                }
            }

            // ── Stock validation ──
            PreparedStatement lockPs = conn.prepareStatement(
                "SELECT id, name, stock, low_stock_threshold FROM products WHERE id = ?");
            for (Map<String, Object> item : cartItems) {
                int productId = (int) item.get("productId");
                int requested = (int) item.get("quantity");
                lockPs.setInt(1, productId);
                ResultSet rs = lockPs.executeQuery();
                if (!rs.next()) {
                    conn.rollback();
                    forwardWithError(req, res, user.getId(), "A product in your cart is no longer available."); return;
                }
                int available = rs.getInt("stock");
                String productName = rs.getString("name");
                if (available == 0) {
                    conn.rollback();
                    forwardWithError(req, res, user.getId(),
                        "Sorry! \"" + productName + "\" is out of stock. Please remove it from your cart."); return;
                }
                if (requested > available) {
                    conn.rollback();
                    forwardWithError(req, res, user.getId(),
                        "Sorry! Only " + available + " item" + (available > 1 ? "s" : "") +
                        " of \"" + productName + "\" " + (available > 1 ? "are" : "is") + " currently available."); return;
                }
            }

            // ── Deduct stock atomically ──
            PreparedStatement deductPs = conn.prepareStatement(
                "UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?");
            for (Map<String, Object> item : cartItems) {
                int qty = (int) item.get("quantity");
                int pid = (int) item.get("productId");
                deductPs.setInt(1, qty);
                deductPs.setInt(2, pid);
                deductPs.setInt(3, qty);
                int updated = deductPs.executeUpdate();
                if (updated == 0) {
                    // Race condition: another order consumed stock between lock and update
                    conn.rollback();
                    forwardWithError(req, res, user.getId(),
                        "Stock changed while processing your order. Please review your cart and try again."); return;
                }
            }

            // ── Raise low-stock notifications ──
            PreparedStatement notifyCheck = conn.prepareStatement(
                "SELECT id, name, stock, low_stock_threshold, shop_id FROM products WHERE id = ?");
            PreparedStatement notifyIns = conn.prepareStatement(
                "INSERT INTO stock_notifications (shop_id, product_id, current_stock, threshold) " +
                "SELECT ?, ?, ?, ? WHERE NOT EXISTS (" +
                "  SELECT 1 FROM stock_notifications WHERE product_id=? AND is_read=0)"); // SQLite supports this syntax
            for (Map<String, Object> item : cartItems) {
                notifyCheck.setInt(1, (int) item.get("productId"));
                ResultSet rs = notifyCheck.executeQuery();
                if (rs.next()) {
                    int stock = rs.getInt("stock");
                    int threshold = rs.getInt("low_stock_threshold");
                    if (stock <= threshold) {
                        notifyIns.setInt(1, rs.getInt("shop_id"));
                        notifyIns.setInt(2, (int) item.get("productId"));
                        notifyIns.setInt(3, stock);
                        notifyIns.setInt(4, threshold);
                        notifyIns.setInt(5, (int) item.get("productId"));
                        notifyIns.executeUpdate();
                    }
                }
            }

            // ── Insert order ──
            double deliveryFee = "delivery".equals(fulfillment) ? shop.getDeliveryFee() : 0.0;
            double total = subtotal + deliveryFee;
            String fullAddress = "delivery".equals(fulfillment)
                ? houseStreet.trim() + ", " + area.trim() + ", " + city.trim() + " - " + pincode.trim()
                : "Pickup";

            PreparedStatement orderPs = conn.prepareStatement(
                "INSERT INTO orders (user_id, shop_id, total_amount, delivery_fee, fulfillment_type, " +
                "customer_name, customer_phone, house_street, area, city, pincode, delivery_address, delivery_instructions) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, user.getId());
            orderPs.setInt(2, shopId);
            orderPs.setDouble(3, total);
            orderPs.setDouble(4, deliveryFee);
            orderPs.setString(5, fulfillment);
            orderPs.setString(6, customerName.trim());
            orderPs.setString(7, customerPhone.trim());
            orderPs.setString(8, "delivery".equals(fulfillment) ? houseStreet.trim() : null);
            orderPs.setString(9, "delivery".equals(fulfillment) ? area.trim() : null);
            orderPs.setString(10, "delivery".equals(fulfillment) ? city.trim() : null);
            orderPs.setString(11, "delivery".equals(fulfillment) ? pincode.trim() : null);
            orderPs.setString(12, fullAddress);
            orderPs.setString(13, instructions != null ? instructions.trim() : null);
            orderPs.executeUpdate();
            ResultSet keys = orderPs.getGeneratedKeys();
            keys.next();
            int orderId = keys.getInt(1);

            // ── Insert order items ──
            PreparedStatement itemPs = conn.prepareStatement(
                "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?,?,?,?)");
            for (Map<String, Object> item : cartItems) {
                itemPs.setInt(1, orderId);
                itemPs.setInt(2, (int) item.get("productId"));
                itemPs.setInt(3, (int) item.get("quantity"));
                itemPs.setDouble(4, (double) item.get("price"));
                itemPs.addBatch();
            }
            itemPs.executeBatch();

            // ── Clear cart ──
            PreparedStatement clearCart = conn.prepareStatement("DELETE FROM cart WHERE user_id=?");
            clearCart.setInt(1, user.getId());
            clearCart.executeUpdate();

            conn.commit();

        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            throw new ServletException(e);
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }

        res.sendRedirect("orders?placed=true");
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse res,
                                   int userId, String error) throws ServletException, IOException {
        req.setAttribute("error", error);
        try (Connection conn = DBConnection.getConnection()) {
            List<Map<String, Object>> cartItems = CartServlet.getCartItems(conn, userId);
            double subtotal = cartItems.stream().mapToDouble(i -> (double) i.get("subtotal")).sum();
            req.setAttribute("cartItems", cartItems);
            req.setAttribute("cartSubtotal", subtotal);
            if (!cartItems.isEmpty())
                req.setAttribute("cartShop", CartServlet.getShop(conn, (int) cartItems.get(0).get("shopId")));
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/checkout.jsp").forward(req, res);
    }

    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}
