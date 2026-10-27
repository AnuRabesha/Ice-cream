package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }
        try (Connection conn = DBConnection.getConnection()) {
            req.setAttribute("orders", getUserOrders(conn, user.getId()));
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/orders.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        String action  = req.getParameter("action");
        int    orderId = Integer.parseInt(req.getParameter("orderId"));

        if ("cancel".equals(action)) {
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);

                // Verify order belongs to this user and is cancellable
                PreparedStatement checkPs = conn.prepareStatement(
                    "SELECT id, status FROM orders WHERE id = ? AND user_id = ?");
                checkPs.setInt(1, orderId); checkPs.setInt(2, user.getId());
                ResultSet rs = checkPs.executeQuery();
                if (!rs.next()) { conn.rollback(); res.sendRedirect("orders"); return; }
                String status = rs.getString("status");
                if (!"pending".equals(status) && !"confirmed".equals(status)) {
                    conn.rollback();
                    res.sendRedirect("orders?cancelError=true"); return;
                }

                // Restore stock for each order item
                PreparedStatement itemsPs = conn.prepareStatement(
                    "SELECT product_id, quantity FROM order_items WHERE order_id = ?");
                itemsPs.setInt(1, orderId);
                ResultSet items = itemsPs.executeQuery();
                PreparedStatement restorePs = conn.prepareStatement(
                    "UPDATE products SET stock = stock + ? WHERE id = ?");
                while (items.next()) {
                    restorePs.setInt(1, items.getInt("quantity"));
                    restorePs.setInt(2, items.getInt("product_id"));
                    restorePs.addBatch();
                }
                restorePs.executeBatch();

                // Mark order cancelled
                PreparedStatement cancelPs = conn.prepareStatement(
                    "UPDATE orders SET status = 'cancelled' WHERE id = ?");
                cancelPs.setInt(1, orderId);
                cancelPs.executeUpdate();

                // Clear any unread low-stock notifications that are now resolved
                PreparedStatement clearNotif = conn.prepareStatement(
                    "UPDATE stock_notifications SET is_read = 1 WHERE is_read = 0 AND product_id IN (" +
                    "  SELECT id FROM products WHERE stock > low_stock_threshold)");
                clearNotif.executeUpdate();

                conn.commit();
            } catch (SQLException e) {
                if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
                throw new ServletException(e);
            } finally {
                if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
            res.sendRedirect("orders?cancelled=true");
        }
    }

    private List<Map<String, Object>> getUserOrders(Connection conn, int userId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT o.*, s.name AS shop_name FROM orders o " +
            "LEFT JOIN shops s ON o.shop_id = s.id " +
            "WHERE o.user_id = ? ORDER BY o.created_at DESC");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> o = new HashMap<>();
            o.put("id",              rs.getInt("id"));
            o.put("shopName",        rs.getString("shop_name"));
            o.put("total",           rs.getDouble("total_amount"));
            o.put("deliveryFee",     rs.getDouble("delivery_fee"));
            o.put("status",          rs.getString("status"));
            o.put("fulfillmentType", rs.getString("fulfillment_type"));
            o.put("address",         rs.getString("delivery_address"));
            o.put("instructions",    rs.getString("delivery_instructions"));
            o.put("date",            rs.getString("created_at"));
            o.put("items",           getOrderItems(conn, rs.getInt("id")));
            o.put("cancellable",     "pending".equals(rs.getString("status")) ||
                                     "confirmed".equals(rs.getString("status")));
            list.add(o);
        }
        return list;
    }

    private List<Map<String, Object>> getOrderItems(Connection conn, int orderId) throws SQLException {
        List<Map<String, Object>> items = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT oi.quantity, oi.unit_price, p.name FROM order_items oi " +
            "JOIN products p ON oi.product_id = p.id WHERE oi.order_id = ?");
        ps.setInt(1, orderId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("name",      rs.getString("name"));
            item.put("quantity",  rs.getInt("quantity"));
            item.put("unitPrice", rs.getDouble("unit_price"));
            items.add(item);
        }
        return items;
    }
}
