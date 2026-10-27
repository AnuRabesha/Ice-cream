package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.util.*;

@WebServlet("/custom-cake")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB photo upload
public class CustomCakeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            if ("dashboard".equals(action) && "business".equals(user.getRole())) {
                // Owner dashboard — show all cake orders for their shops
                req.setAttribute("cakeOrders", getOwnerCakeOrders(conn, user.getId()));
                req.getRequestDispatcher("/cake-dashboard.jsp").forward(req, res);
            } else {
                // Customer — show their own cake orders
                req.setAttribute("myCakeOrders", getMyCakeOrders(conn, user.getId()));
                req.getRequestDispatcher("/my-cake-orders.jsp").forward(req, res);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        // Handle owner status update
        if ("updateStatus".equals(req.getParameter("action"))) {
            updateOrderStatus(req, res, user);
            return;
        }

        // Save new custom cake order
        String photoRef = handlePhotoUpload(req);

        try (Connection conn = DBConnection.getConnection()) {
            int designId   = Integer.parseInt(req.getParameter("designId"));
            int shopId     = Integer.parseInt(req.getParameter("shopId"));
            String size    = req.getParameter("size");
            String shape   = req.getParameter("shape");
            String flavour = req.getParameter("flavour");
            String colour  = req.getParameter("colour");
            String[] tops  = req.getParameterValues("toppings");
            String toppings = tops != null ? String.join(", ", tops) : "";
            String message = req.getParameter("message");
            String extras  = req.getParameter("extras");
            String delDate = req.getParameter("deliveryDate");
            String address = req.getParameter("address");
            String notes   = req.getParameter("notes");
            int qty        = Integer.parseInt(req.getParameter("qty") != null ? req.getParameter("qty") : "1");
            double finalPrice = Double.parseDouble(req.getParameter("finalPrice"));

            // Validate price server-side
            double serverPrice = calcPrice(conn, designId, size, tops != null ? tops.length : 0,
                                           photoRef != null, qty);
            if (Math.abs(serverPrice - finalPrice) > 1.0) finalPrice = serverPrice;

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO custom_cake_orders (user_id,shop_id,cake_design_id,selected_size,selected_shape," +
                "selected_flavour,selected_colour,selected_toppings,custom_message,photo_reference," +
                "extra_decorations,quantity,base_price,final_price,delivery_date,delivery_address," +
                "special_notes,status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'pending')",
                Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, user.getId()); ps.setInt(2, shopId); ps.setInt(3, designId);
            ps.setString(4, size); ps.setString(5, shape); ps.setString(6, flavour);
            ps.setString(7, colour); ps.setString(8, toppings); ps.setString(9, message);
            ps.setString(10, photoRef); ps.setString(11, extras); ps.setInt(12, qty);
            ps.setDouble(13, finalPrice / qty); ps.setDouble(14, finalPrice);
            ps.setString(15, delDate); ps.setString(16, address); ps.setString(17, notes);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            int orderId = keys.next() ? keys.getInt(1) : 0;
            res.sendRedirect("custom-cake?ordered=" + orderId);
        } catch (SQLException e) { throw new ServletException(e); }
    }

    // ── helpers ───────────────────────────────────────────────────────────────
    private String handlePhotoUpload(HttpServletRequest req) {
        try {
            Part photo = req.getPart("photoFile");
            if (photo == null || photo.getSize() == 0) return null;
            String fileName = "cake_photo_" + System.currentTimeMillis() + "_" +
                              Paths.get(photo.getSubmittedFileName()).getFileName();
            String uploadDir = getServletContext().getRealPath("/uploads/");
            new File(uploadDir).mkdirs();
            photo.write(uploadDir + fileName);
            return "uploads/" + fileName;
        } catch (Exception e) { return null; }
    }

    private double calcPrice(Connection conn, int designId, String size, int toppingCnt,
                             boolean photo, int qty) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT available_sizes, base_price FROM cake_designs WHERE id=?");
        ps.setInt(1, designId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) return 0;
        String sizesStr = rs.getString("available_sizes");
        double price = rs.getDouble("base_price");
        if (sizesStr != null && size != null) {
            for (String entry : sizesStr.split(",")) {
                String[] parts = entry.trim().split(":");
                if (parts.length == 2 && parts[0].trim().equalsIgnoreCase(size.trim())) {
                    price = Double.parseDouble(parts[1].trim()); break;
                }
            }
        }
        price += toppingCnt * 50.0;
        if (photo) price += 200.0;
        return price * qty;
    }

    private void updateOrderStatus(HttpServletRequest req, HttpServletResponse res, User user)
            throws IOException, ServletException {
        if (!"business".equals(user.getRole())) {
            res.sendError(403); return;
        }
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        String status = req.getParameter("status");
        String ownerNotes = req.getParameter("ownerNotes");
        try (Connection conn = DBConnection.getConnection()) {
            // Verify the order belongs to a shop owned by this user
            PreparedStatement check = conn.prepareStatement(
                "SELECT co.id FROM custom_cake_orders co " +
                "JOIN shops s ON co.shop_id = s.id " +
                "WHERE co.id = ? AND s.owner_id = ?");
            check.setInt(1, orderId); check.setInt(2, user.getId());
            if (!check.executeQuery().next()) { res.sendError(403); return; }

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE custom_cake_orders SET status=?, owner_notes=? WHERE id=?");
            ps.setString(1, status); ps.setString(2, ownerNotes); ps.setInt(3, orderId);
            ps.executeUpdate();
        } catch (SQLException e) { throw new ServletException(e); }
        res.sendRedirect("custom-cake?action=dashboard&updated=" + orderId);
    }

    private List<Map<String, Object>> getOwnerCakeOrders(Connection conn, int ownerId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT co.*, u.name AS customer_name, u.phone AS customer_phone, " +
            "s.name AS shop_name, cd.name AS design_name " +
            "FROM custom_cake_orders co " +
            "JOIN users u ON co.user_id=u.id " +
            "JOIN shops s ON co.shop_id=s.id " +
            "LEFT JOIN cake_designs cd ON co.cake_design_id=cd.id " +
            "WHERE s.owner_id=? ORDER BY co.created_at DESC");
        ps.setInt(1, ownerId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(mapOrderRow(rs, true));
        return list;
    }

    private List<Map<String, Object>> getMyCakeOrders(Connection conn, int userId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT co.*, s.name AS shop_name, cd.name AS design_name " +
            "FROM custom_cake_orders co " +
            "JOIN shops s ON co.shop_id=s.id " +
            "LEFT JOIN cake_designs cd ON co.cake_design_id=cd.id " +
            "WHERE co.user_id=? ORDER BY co.created_at DESC");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(mapOrderRow(rs, false));
        return list;
    }

    private Map<String, Object> mapOrderRow(ResultSet rs, boolean includeCustomer) throws SQLException {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id",              rs.getInt("id"));
        m.put("shopName",        rs.getString("shop_name"));
        m.put("designName",      rs.getString("design_name"));
        m.put("size",            rs.getString("selected_size"));
        m.put("shape",           rs.getString("selected_shape"));
        m.put("flavour",         rs.getString("selected_flavour"));
        m.put("colour",          rs.getString("selected_colour"));
        m.put("toppings",        rs.getString("selected_toppings"));
        m.put("message",         rs.getString("custom_message"));
        m.put("photo",           rs.getString("photo_reference"));
        m.put("quantity",        rs.getInt("quantity"));
        m.put("finalPrice",      rs.getDouble("final_price"));
        m.put("deliveryDate",    rs.getString("delivery_date"));
        m.put("deliveryAddress", rs.getString("delivery_address"));
        m.put("status",          rs.getString("status"));
        m.put("ownerNotes",      rs.getString("owner_notes"));
        m.put("createdAt",       rs.getString("created_at"));
        if (includeCustomer) {
            m.put("customerName",  rs.getString("customer_name"));
            m.put("customerPhone", rs.getString("customer_phone"));
        }
        return m;
    }
}
