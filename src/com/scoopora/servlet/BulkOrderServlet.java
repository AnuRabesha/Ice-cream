package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/bulk")
public class BulkOrderServlet extends HttpServlet {

    // Wholesale delivery: ₹500 flat under ₹10,000 order value; free at or above.
    private static final double FREE_DELIVERY_THRESHOLD = 10_000.00;
    private static final double DELIVERY_FEE            =    500.00;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String category = req.getParameter("category");
        String shopId   = req.getParameter("shopId");

        try (Connection conn = DBConnection.getConnection()) {
            req.setAttribute("products",  getCatalog(conn, category, shopId));
            req.setAttribute("suppliers", getSuppliers(conn));
            User user = (User) req.getSession().getAttribute("user");
            if (user != null) req.setAttribute("myOrders", getMyOrders(conn, user.getId()));
        } catch (SQLException e) { throw new ServletException(e); }

        req.setAttribute("selectedCategory", category);
        req.setAttribute("selectedShop",     shopId);
        req.getRequestDispatcher("/bulk.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        String action = req.getParameter("action");

        // Repeat order: pre-fill from a previous order
        if ("repeat".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            try (Connection conn = DBConnection.getConnection()) {
                Map<String, Object> prev = getOrderById(conn, orderId, user.getId());
                if (prev != null) {
                    req.setAttribute("repeatOrder", prev);
                    req.setAttribute("products",    getCatalog(conn, null, null));
                    req.setAttribute("suppliers",   getSuppliers(conn));
                    req.setAttribute("myOrders",    getMyOrders(conn, user.getId()));
                }
            } catch (SQLException e) { throw new ServletException(e); }
            req.getRequestDispatcher("/bulk.jsp").forward(req, res);
            return;
        }

        // Place new bulk order
        int    productId    = Integer.parseInt(req.getParameter("productId"));
        int    quantity     = Integer.parseInt(req.getParameter("quantity"));
        String bizType      = req.getParameter("businessType");
        String bizName      = req.getParameter("businessName");
        String address      = req.getParameter("deliveryAddress");
        String city         = req.getParameter("deliveryCity");
        String pincode      = req.getParameter("deliveryPincode");
        String notes        = req.getParameter("notes");

        // Validate business type
        Set<String> validTypes = new HashSet<>(Arrays.asList(
            "ice_cream_shop","cafe","hotel","restaurant","caterer","event_organizer","retailer","other"));
        if (!validTypes.contains(bizType)) bizType = "other";

        try (Connection conn = DBConnection.getConnection()) {
            // Load product with lock
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, name, moq, stock, base_price, " +
                "tier1_qty, tier1_price, tier2_qty, tier2_price, tier3_qty, tier3_price " +
                "FROM wholesale_products WHERE id = ? AND is_active = 1");
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { res.sendRedirect("bulk?error=notfound"); return; }

            int moq   = rs.getInt("moq");
            int stock = rs.getInt("stock");

            if (quantity < moq) {
                res.sendRedirect("bulk?error=moq&moq=" + moq + "&pid=" + productId); return;
            }
            if (quantity > stock) {
                res.sendRedirect("bulk?error=stock&avail=" + stock + "&pid=" + productId); return;
            }

            double unitPrice = resolvePrice(rs, quantity);
            double subtotal  = unitPrice * quantity;
            double fee       = subtotal >= FREE_DELIVERY_THRESHOLD ? 0.0 : DELIVERY_FEE;
            double total     = subtotal + fee;

            conn.setAutoCommit(false);
            try {
                // Deduct stock
                PreparedStatement deduct = conn.prepareStatement(
                    "UPDATE wholesale_products SET stock = stock - ? WHERE id = ? AND stock >= ?");
                deduct.setInt(1, quantity); deduct.setInt(2, productId); deduct.setInt(3, quantity);
                if (deduct.executeUpdate() == 0) {
                    conn.rollback();
                    res.sendRedirect("bulk?error=stock&avail=0&pid=" + productId); return;
                }

                PreparedStatement ins = conn.prepareStatement(
                    "INSERT INTO bulk_orders (business_id, wholesale_product_id, business_type, business_name, " +
                    "quantity, unit_price, total_price, delivery_address, delivery_city, delivery_pincode, " +
                    "delivery_fee, notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
                ins.setInt(1, user.getId());
                ins.setInt(2, productId);
                ins.setString(3, bizType);
                ins.setString(4, bizName != null ? bizName.trim() : null);
                ins.setInt(5, quantity);
                ins.setDouble(6, unitPrice);
                ins.setDouble(7, total);
                ins.setString(8, address != null ? address.trim() : null);
                ins.setString(9, city    != null ? city.trim()    : null);
                ins.setString(10, pincode != null ? pincode.trim() : null);
                ins.setDouble(11, fee);
                ins.setString(12, notes  != null ? notes.trim()   : null);
                ins.executeUpdate();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback(); throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) { throw new ServletException(e); }

        res.sendRedirect("bulk?submitted=true");
    }

    // ── Tier price resolver ───────────────────────────────────────────────────
    private double resolvePrice(ResultSet rs, int qty) throws SQLException {
        if (qty >= rs.getInt("tier3_qty")) return rs.getDouble("tier3_price");
        if (qty >= rs.getInt("tier2_qty")) return rs.getDouble("tier2_price");
        if (qty >= rs.getInt("tier1_qty")) return rs.getDouble("tier1_price");
        return rs.getDouble("base_price");
    }

    // ── Catalog query ─────────────────────────────────────────────────────────
    private List<Map<String, Object>> getCatalog(Connection conn, String category, String shopId)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT wp.*, s.name AS shop_name, s.city AS shop_city, s.phone AS shop_phone " +
            "FROM wholesale_products wp JOIN shops s ON wp.shop_id = s.id " +
            "WHERE wp.is_active = 1");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.isEmpty()) {
            sql.append(" AND wp.category = ?"); params.add(category);
        }
        if (shopId != null && !shopId.isEmpty()) {
            sql.append(" AND wp.shop_id = ?"); params.add(Integer.parseInt(shopId));
        }
        sql.append(" ORDER BY wp.category, wp.name");

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        ResultSet rs = ps.executeQuery();

        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> p = new HashMap<>();
            p.put("id",          rs.getInt("id"));
            p.put("name",        rs.getString("name"));
            p.put("description", rs.getString("description"));
            p.put("category",    rs.getString("category"));
            p.put("unitLabel",   rs.getString("unit_label"));
            p.put("basePrice",   rs.getDouble("base_price"));
            p.put("tier1Qty",    rs.getInt("tier1_qty"));
            p.put("tier1Price",  rs.getDouble("tier1_price"));
            p.put("tier2Qty",    rs.getInt("tier2_qty"));
            p.put("tier2Price",  rs.getDouble("tier2_price"));
            p.put("tier3Qty",    rs.getInt("tier3_qty"));
            p.put("tier3Price",  rs.getDouble("tier3_price"));
            p.put("moq",         rs.getInt("moq"));
            p.put("stock",       rs.getInt("stock"));
            p.put("imageUrl",    rs.getString("image_url"));
            p.put("shopName",    rs.getString("shop_name"));
            p.put("shopCity",    rs.getString("shop_city"));
            p.put("shopPhone",   rs.getString("shop_phone"));
            list.add(p);
        }
        return list;
    }

    private List<Map<String, Object>> getSuppliers(Connection conn) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT DISTINCT s.id, s.name, s.city FROM shops s " +
            "JOIN wholesale_products wp ON wp.shop_id = s.id WHERE wp.is_active = 1 ORDER BY s.name");
        ResultSet rs = ps.executeQuery();
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> s = new HashMap<>();
            s.put("id",   rs.getInt("id"));
            s.put("name", rs.getString("name"));
            s.put("city", rs.getString("city"));
            list.add(s);
        }
        return list;
    }

    private List<Map<String, Object>> getMyOrders(Connection conn, int userId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT bo.*, wp.name AS product_name, wp.unit_label, wp.category, s.name AS shop_name " +
            "FROM bulk_orders bo " +
            "JOIN wholesale_products wp ON bo.wholesale_product_id = wp.id " +
            "JOIN shops s ON wp.shop_id = s.id " +
            "WHERE bo.business_id = ? ORDER BY bo.created_at DESC");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> o = new HashMap<>();
            o.put("id",              rs.getInt("id"));
            o.put("productId",       rs.getInt("wholesale_product_id"));
            o.put("productName",     rs.getString("product_name"));
            o.put("unitLabel",       rs.getString("unit_label"));
            o.put("category",        rs.getString("category"));
            o.put("shopName",        rs.getString("shop_name"));
            o.put("businessType",    rs.getString("business_type"));
            o.put("businessName",    rs.getString("business_name"));
            o.put("quantity",        rs.getInt("quantity"));
            o.put("unitPrice",       rs.getDouble("unit_price"));
            o.put("deliveryFee",     rs.getDouble("delivery_fee"));
            o.put("totalPrice",      rs.getDouble("total_price"));
            o.put("deliveryCity",    rs.getString("delivery_city"));
            o.put("status",          rs.getString("status"));
            o.put("date",            rs.getString("created_at"));
            list.add(o);
        }
        return list;
    }

    private Map<String, Object> getOrderById(Connection conn, int orderId, int userId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT bo.*, wp.name AS product_name FROM bulk_orders bo " +
            "JOIN wholesale_products wp ON bo.wholesale_product_id = wp.id " +
            "WHERE bo.id = ? AND bo.business_id = ?");
        ps.setInt(1, orderId); ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) return null;
        Map<String, Object> o = new HashMap<>();
        o.put("productId",    rs.getInt("wholesale_product_id"));
        o.put("productName",  rs.getString("product_name"));
        o.put("businessType", rs.getString("business_type"));
        o.put("businessName", rs.getString("business_name"));
        o.put("quantity",     rs.getInt("quantity"));
        o.put("deliveryCity", rs.getString("delivery_city"));
        o.put("notes",        rs.getString("notes"));
        return o;
    }
}
