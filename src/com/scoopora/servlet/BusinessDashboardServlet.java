package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.BusinessAccount;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/business/dashboard")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class BusinessDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");
        if (ba == null) { res.sendRedirect(req.getContextPath() + "/business-login.jsp"); return; }

        String tab = req.getParameter("tab") != null ? req.getParameter("tab") : "overview";
        req.setAttribute("tab", tab);

        try (Connection conn = DBConnection.getConnection()) {
            loadOverviewStats(conn, ba.getId(), req);
            loadProducts(conn, ba.getId(), req);
            loadOrders(conn, ba.getId(), req);
            loadInvoices(conn, ba.getId(), req);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        req.getRequestDispatcher("/business-dashboard.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");
        if (ba == null) { res.sendRedirect(req.getContextPath() + "/business-login.jsp"); return; }

        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            switch (action == null ? "" : action) {
                case "add_product":    addProduct(conn, ba, req);    break;
                case "update_product": updateProduct(conn, ba, req); break;
                case "delete_product": deleteProduct(conn, ba, req); break;
                case "update_order":   updateOrder(conn, ba, req);   break;
                case "create_invoice": createInvoice(conn, ba, req); break;
                case "update_stock":   updateStock(conn, ba, req);   break;
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        String redirect = req.getParameter("redirect_tab");
        res.sendRedirect(req.getContextPath() + "/business/dashboard?tab=" + (redirect != null ? redirect : "overview"));
    }

    // ── Stats ─────────────────────────────────────────────────────────────────
    private void loadOverviewStats(Connection conn, int bid, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) total, SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) pending," +
                " SUM(CASE WHEN status IN('accepted','processing','shipped','delivered') THEN total_amount ELSE 0 END) revenue" +
                " FROM b2b_orders WHERE business_id=?")) {
            ps.setInt(1, bid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    req.setAttribute("statTotalOrders", rs.getInt("total"));
                    req.setAttribute("statPendingOrders", rs.getInt("pending"));
                    req.setAttribute("statRevenue", rs.getDouble("revenue"));
                }
            }
        }
        try (PreparedStatement ps2 = conn.prepareStatement(
                "SELECT COUNT(*) FROM business_products WHERE business_id=? AND is_available=1")) {
            ps2.setInt(1, bid);
            try (ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) req.setAttribute("statActiveProducts", rs2.getInt(1));
            }
        }
    }

    // ── Products ──────────────────────────────────────────────────────────────
    private void loadProducts(Connection conn, int bid, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM business_products WHERE business_id=? ORDER BY created_at DESC")) {
            ps.setInt(1, bid);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> products = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> p = new LinkedHashMap<>();
                    p.put("id",             rs.getInt("id"));
                    p.put("name",           rs.getString("name"));
                    p.put("description",    rs.getString("description"));
                    p.put("category",       rs.getString("category"));
                    p.put("imageUrl",       rs.getString("image_url"));
                    p.put("packSize",       rs.getString("pack_size"));
                    p.put("wholesalePrice", rs.getDouble("wholesale_price"));
                    p.put("moq",            rs.getInt("moq"));
                    p.put("stock",          rs.getInt("stock"));
                    p.put("isAvailable",    rs.getInt("is_available") == 1);
                    products.add(p);
                }
                req.setAttribute("products", products);
            }
        }
    }

    private void addProduct(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException, IOException, ServletException {
        String imageUrl = saveProductImage(req, ba.getId());
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO business_products (business_id,name,description,category,image_url,pack_size,wholesale_price,moq,stock) VALUES (?,?,?,?,?,?,?,?,?)")) {
            ps.setInt(1, ba.getId());
            ps.setString(2, req.getParameter("name"));
            ps.setString(3, req.getParameter("description"));
            ps.setString(4, req.getParameter("category"));
            ps.setString(5, imageUrl);
            ps.setString(6, req.getParameter("pack_size"));
            ps.setDouble(7, parseDouble(req.getParameter("wholesale_price"), 0));
            ps.setInt(8, parseInt(req.getParameter("moq"), 1));
            ps.setInt(9, parseInt(req.getParameter("stock"), 0));
            ps.executeUpdate();
        }
    }

    private void updateProduct(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException, IOException, ServletException {
        int pid = parseInt(req.getParameter("product_id"), 0);
        String imageUrl = saveProductImage(req, ba.getId());
        if (imageUrl == null) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE business_products SET name=?,description=?,category=?,pack_size=?,wholesale_price=?,moq=?,stock=?,is_available=? WHERE id=? AND business_id=?")) {
                ps.setString(1, req.getParameter("name"));
                ps.setString(2, req.getParameter("description"));
                ps.setString(3, req.getParameter("category"));
                ps.setString(4, req.getParameter("pack_size"));
                ps.setDouble(5, parseDouble(req.getParameter("wholesale_price"), 0));
                ps.setInt(6, parseInt(req.getParameter("moq"), 1));
                ps.setInt(7, parseInt(req.getParameter("stock"), 0));
                ps.setInt(8, "on".equals(req.getParameter("is_available")) ? 1 : 0);
                ps.setInt(9, pid); ps.setInt(10, ba.getId());
                ps.executeUpdate();
            }
        } else {
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE business_products SET name=?,description=?,category=?,image_url=?,pack_size=?,wholesale_price=?,moq=?,stock=?,is_available=? WHERE id=? AND business_id=?")) {
                ps.setString(1, req.getParameter("name"));
                ps.setString(2, req.getParameter("description"));
                ps.setString(3, req.getParameter("category"));
                ps.setString(4, imageUrl);
                ps.setString(5, req.getParameter("pack_size"));
                ps.setDouble(6, parseDouble(req.getParameter("wholesale_price"), 0));
                ps.setInt(7, parseInt(req.getParameter("moq"), 1));
                ps.setInt(8, parseInt(req.getParameter("stock"), 0));
                ps.setInt(9, "on".equals(req.getParameter("is_available")) ? 1 : 0);
                ps.setInt(10, pid); ps.setInt(11, ba.getId());
                ps.executeUpdate();
            }
        }
    }

    private void deleteProduct(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM business_products WHERE id=? AND business_id=?")) {
            ps.setInt(1, parseInt(req.getParameter("product_id"), 0));
            ps.setInt(2, ba.getId());
            ps.executeUpdate();
        }
    }

    private void updateStock(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE business_products SET stock=? WHERE id=? AND business_id=?")) {
            ps.setInt(1, parseInt(req.getParameter("stock"), 0));
            ps.setInt(2, parseInt(req.getParameter("product_id"), 0));
            ps.setInt(3, ba.getId());
            ps.executeUpdate();
        }
    }

    // ── Orders ────────────────────────────────────────────────────────────────
    private void loadOrders(Connection conn, int bid, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT o.*, p.name product_name FROM b2b_orders o " +
                "JOIN business_products p ON o.product_id=p.id " +
                "WHERE o.business_id=? ORDER BY o.created_at DESC")) {
            ps.setInt(1, bid);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> orders = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> o = new LinkedHashMap<>();
                    o.put("id",           rs.getInt("id"));
                    o.put("buyerName",    rs.getString("buyer_name"));
                    o.put("buyerEmail",   rs.getString("buyer_email"));
                    o.put("buyerPhone",   rs.getString("buyer_phone"));
                    o.put("buyerCompany", rs.getString("buyer_company"));
                    o.put("productName",  rs.getString("product_name"));
                    o.put("quantity",     rs.getInt("quantity"));
                    o.put("unitPrice",    rs.getDouble("unit_price"));
                    o.put("totalAmount",  rs.getDouble("total_amount"));
                    o.put("deliveryCity", rs.getString("delivery_city"));
                    o.put("orderType",    rs.getString("order_type"));
                    o.put("status",       rs.getString("status"));
                    o.put("notes",        rs.getString("notes"));
                    o.put("sellerNotes",  rs.getString("seller_notes"));
                    o.put("createdAt",    rs.getTimestamp("created_at"));
                    orders.add(o);
                }
                req.setAttribute("orders", orders);
            }
        }
    }

    private void updateOrder(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE b2b_orders SET status=?, seller_notes=? WHERE id=? AND business_id=?")) {
            ps.setString(1, req.getParameter("status"));
            ps.setString(2, req.getParameter("seller_notes"));
            ps.setInt(3, parseInt(req.getParameter("order_id"), 0));
            ps.setInt(4, ba.getId());
            ps.executeUpdate();
        }
    }

    // ── Invoices ──────────────────────────────────────────────────────────────
    private void loadInvoices(Connection conn, int bid, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT i.*, o.buyer_name, o.buyer_company FROM b2b_invoices i " +
                "JOIN b2b_orders o ON i.order_id=o.id " +
                "WHERE i.business_id=? ORDER BY i.created_at DESC")) {
            ps.setInt(1, bid);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> invoices = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> inv = new LinkedHashMap<>();
                    inv.put("id",            rs.getInt("id"));
                    inv.put("invoiceNumber", rs.getString("invoice_number"));
                    inv.put("orderId",       rs.getInt("order_id"));
                    inv.put("buyerName",     rs.getString("buyer_name"));
                    inv.put("buyerCompany",  rs.getString("buyer_company"));
                    inv.put("amount",        rs.getDouble("amount"));
                    inv.put("taxAmount",     rs.getDouble("tax_amount"));
                    inv.put("totalAmount",   rs.getDouble("total_amount"));
                    inv.put("status",        rs.getString("status"));
                    inv.put("dueDate",       rs.getDate("due_date"));
                    inv.put("createdAt",     rs.getTimestamp("created_at"));
                    invoices.add(inv);
                }
                req.setAttribute("invoices", invoices);
            }
        }
    }

    private void createInvoice(Connection conn, BusinessAccount ba, HttpServletRequest req) throws SQLException {
        int orderId   = parseInt(req.getParameter("order_id"), 0);
        double amount = parseDouble(req.getParameter("amount"), 0);
        double tax    = parseDouble(req.getParameter("tax_amount"), 0);
        String invNum = "INV-" + ba.getId() + "-" + System.currentTimeMillis();
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO b2b_invoices (order_id,business_id,invoice_number,amount,tax_amount,total_amount,due_date,notes) VALUES (?,?,?,?,?,?,?,?)")) {
            ps.setInt(1, orderId);
            ps.setInt(2, ba.getId());
            ps.setString(3, invNum);
            ps.setDouble(4, amount);
            ps.setDouble(5, tax);
            ps.setDouble(6, amount + tax);
            ps.setString(7, req.getParameter("due_date"));
            ps.setString(8, req.getParameter("notes"));
            ps.executeUpdate();
        }
    }

    // ── Image Upload Helper ───────────────────────────────────────────────────
    private String saveProductImage(HttpServletRequest req, int bid) throws IOException, ServletException {
        Part part = req.getPart("image");
        if (part == null || part.getSize() == 0) return null;
        String uploadDir = getServletContext().getRealPath("/images/business/");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
        String fileName = "prod_" + bid + "_" + System.currentTimeMillis() + ".jpg";
        part.write(uploadDir + File.separator + fileName);
        return "images/business/" + fileName;
    }

    // ── Parse Helpers ─────────────────────────────────────────────────────────
    private static int parseInt(String val, int def) {
        if (val == null || val.trim().isEmpty()) return def;
        try { return Integer.parseInt(val.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static double parseDouble(String val, double def) {
        if (val == null || val.trim().isEmpty()) return def;
        try { return Double.parseDouble(val.trim()); } catch (NumberFormatException e) { return def; }
    }
}
