package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        if (!"business".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            res.sendError(403); return;
        }
        try (Connection conn = DBConnection.getConnection()) {
            int shopId = getOwnerShopId(conn, user.getId());
            if (shopId == 0) { res.sendError(404, "No shop found for this account."); return; }
            req.setAttribute("products",      getInventory(conn, shopId));
            req.setAttribute("notifications", getLowStockNotifications(conn, shopId));
            req.setAttribute("shopId",        shopId);
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/inventory.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        if (!"business".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            res.sendError(403); return;
        }

        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            int shopId = getOwnerShopId(conn, user.getId());
            if (shopId == 0) { res.sendError(404); return; }

            if ("updateStock".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int newStock  = Integer.parseInt(req.getParameter("stock"));
                int threshold = Integer.parseInt(req.getParameter("threshold"));
                if (newStock < 0) newStock = 0;
                if (threshold < 1) threshold = 1;

                // Verify product belongs to this shop
                PreparedStatement verifyPs = conn.prepareStatement(
                    "SELECT id FROM products WHERE id = ? AND shop_id = ?");
                verifyPs.setInt(1, productId); verifyPs.setInt(2, shopId);
                if (!verifyPs.executeQuery().next()) { res.sendError(403); return; }

                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE products SET stock = ?, low_stock_threshold = ? WHERE id = ? AND shop_id = ?");
                ps.setInt(1, newStock); ps.setInt(2, threshold);
                ps.setInt(3, productId); ps.setInt(4, shopId);
                ps.executeUpdate();

                // Auto-resolve notification if stock is now above threshold
                if (newStock > threshold) {
                    PreparedStatement resolve = conn.prepareStatement(
                        "UPDATE stock_notifications SET is_read = 1 WHERE product_id = ? AND is_read = 0");
                    resolve.setInt(1, productId);
                    resolve.executeUpdate();
                }

            } else if ("dismissNotification".equals(action)) {
                int notifId = Integer.parseInt(req.getParameter("notifId"));
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE stock_notifications SET is_read = 1 WHERE id = ? AND shop_id = ?");
                ps.setInt(1, notifId); ps.setInt(2, shopId);
                ps.executeUpdate();
            }
        } catch (SQLException e) { throw new ServletException(e); }

        res.sendRedirect("inventory?updated=true");
    }

    private int getOwnerShopId(Connection conn, int userId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT id FROM shops WHERE owner_id = ? LIMIT 1");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? rs.getInt("id") : 0;
    }

    private List<Map<String, Object>> getInventory(Connection conn, int shopId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, name, category, stock, low_stock_threshold, price " +
            "FROM products WHERE shop_id = ? ORDER BY stock ASC, name ASC");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> p = new HashMap<>();
            int stock     = rs.getInt("stock");
            int threshold = rs.getInt("low_stock_threshold");
            p.put("id",        rs.getInt("id"));
            p.put("name",      rs.getString("name"));
            p.put("category",  rs.getString("category"));
            p.put("stock",     stock);
            p.put("threshold", threshold);
            p.put("price",     rs.getDouble("price"));
            p.put("outOfStock", stock == 0);
            p.put("lowStock",   stock > 0 && stock <= threshold);
            list.add(p);
        }
        return list;
    }

    private List<Map<String, Object>> getLowStockNotifications(Connection conn, int shopId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT sn.id, sn.current_stock, sn.threshold, sn.created_at, p.name AS product_name " +
            "FROM stock_notifications sn JOIN products p ON sn.product_id = p.id " +
            "WHERE sn.shop_id = ? AND sn.is_read = 0 ORDER BY sn.created_at DESC");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> n = new HashMap<>();
            n.put("id",          rs.getInt("id"));
            n.put("productName", rs.getString("product_name"));
            n.put("stock",       rs.getInt("current_stock"));
            n.put("threshold",   rs.getInt("threshold"));
            n.put("date",        rs.getString("created_at"));
            list.add(n);
        }
        return list;
    }
}
