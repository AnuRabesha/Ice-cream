package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        try (Connection conn = DBConnection.getConnection()) {
            List<Map<String, Object>> cartItems = getCartItems(conn, user.getId());
            double subtotal = cartItems.stream().mapToDouble(i -> (double) i.get("subtotal")).sum();
            req.setAttribute("cartItems", cartItems);
            req.setAttribute("cartSubtotal", subtotal);
            if (!cartItems.isEmpty())
                req.setAttribute("cartShop", getShop(conn, (int) cartItems.get(0).get("shopId")));
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/cart.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        String action    = req.getParameter("action");
        int    productId = Integer.parseInt(req.getParameter("productId"));
        try (Connection conn = DBConnection.getConnection()) {
            if ("add".equals(action))         addToCart(conn, user.getId(), productId);
            else if ("remove".equals(action)) removeFromCart(conn, user.getId(), productId);
            else if ("update".equals(action)) updateCart(conn, user.getId(), productId,
                                                  Integer.parseInt(req.getParameter("qty")));
        } catch (SQLException e) { throw new ServletException(e); }
        String ref = req.getHeader("Referer");
        res.sendRedirect(ref != null && ref.contains("/cart") ? "cart" : (ref != null ? ref : "cart"));
    }

    // ── Shared helpers (used by CheckoutServlet) ─────────────────────────────

    static List<Map<String, Object>> getCartItems(Connection conn, int userId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT c.id, c.quantity, p.id AS pid, p.name, p.price, p.image_url, p.shop_id, " +
            "p.stock, p.low_stock_threshold " +
            "FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            int cartQty  = rs.getInt("quantity");
            int stock    = rs.getInt("stock");
            // Cap cart quantity at current stock silently
            int effectiveQty = Math.min(cartQty, Math.max(stock, 0));
            Map<String, Object> item = new HashMap<>();
            item.put("cartId",    rs.getInt("id"));
            item.put("productId", rs.getInt("pid"));
            item.put("shopId",    rs.getInt("shop_id"));
            item.put("name",      rs.getString("name"));
            item.put("price",     rs.getDouble("price"));
            item.put("quantity",  effectiveQty);
            item.put("stock",     stock);
            item.put("lowStockThreshold", rs.getInt("low_stock_threshold"));
            item.put("imageUrl",  rs.getString("image_url"));
            item.put("subtotal",  rs.getDouble("price") * effectiveQty);
            item.put("outOfStock",   stock == 0);
            item.put("lowStock",     stock > 0 && stock <= rs.getInt("low_stock_threshold"));
            item.put("qtyExceeded",  cartQty > stock && stock > 0);
            list.add(item);
        }
        return list;
    }

    static Shop getShop(Connection conn, int shopId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, name, city, home_delivery, delivery_fee, min_order, delivery_time, " +
            "delivery_areas, pickup_available FROM shops WHERE id = ?");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) return null;
        Shop s = new Shop();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setCity(rs.getString("city"));
        s.setHomeDelivery(rs.getBoolean("home_delivery"));
        s.setDeliveryFee(rs.getDouble("delivery_fee"));
        s.setMinOrder(rs.getDouble("min_order"));
        s.setDeliveryTime(rs.getString("delivery_time"));
        s.setDeliveryAreas(rs.getString("delivery_areas"));
        s.setPickupAvailable(rs.getBoolean("pickup_available"));
        return s;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private void addToCart(Connection conn, int userId, int productId) throws SQLException {
        // Check current stock
        PreparedStatement stockPs = conn.prepareStatement("SELECT stock FROM products WHERE id = ?");
        stockPs.setInt(1, productId);
        ResultSet sr = stockPs.executeQuery();
        if (!sr.next() || sr.getInt("stock") <= 0) return; // out of stock, silently ignore

        PreparedStatement check = conn.prepareStatement(
            "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ?");
        check.setInt(1, userId); check.setInt(2, productId);
        ResultSet rs = check.executeQuery();
        if (rs.next()) {
            int currentQty = rs.getInt("quantity");
            int stock = sr.getInt("stock");
            if (currentQty >= stock) return; // already at stock limit
            PreparedStatement upd = conn.prepareStatement("UPDATE cart SET quantity = quantity + 1 WHERE id = ?");
            upd.setInt(1, rs.getInt("id")); upd.executeUpdate();
        } else {
            PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO cart (user_id, product_id, quantity) VALUES (?,?,1)");
            ins.setInt(1, userId); ins.setInt(2, productId); ins.executeUpdate();
        }
    }

    private void removeFromCart(Connection conn, int userId, int productId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM cart WHERE user_id = ? AND product_id = ?");
        ps.setInt(1, userId); ps.setInt(2, productId); ps.executeUpdate();
    }

    private void updateCart(Connection conn, int userId, int productId, int qty) throws SQLException {
        if (qty <= 0) { removeFromCart(conn, userId, productId); return; }
        // Cap at available stock
        PreparedStatement stockPs = conn.prepareStatement("SELECT stock FROM products WHERE id = ?");
        stockPs.setInt(1, productId);
        ResultSet sr = stockPs.executeQuery();
        int maxQty = sr.next() ? sr.getInt("stock") : qty;
        int safeQty = Math.min(qty, maxQty);
        if (safeQty <= 0) { removeFromCart(conn, userId, productId); return; }
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?");
        ps.setInt(1, safeQty); ps.setInt(2, userId); ps.setInt(3, productId); ps.executeUpdate();
    }
}
