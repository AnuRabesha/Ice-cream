package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.BusinessAccount;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/business/order")
public class BusinessOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        // business_id must come from the authenticated session, not the request
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");
        if (ba == null) { res.sendRedirect(req.getContextPath() + "/business-login.jsp"); return; }
        int businessId   = ba.getId();
        int productId    = parseInt(req.getParameter("product_id"), 0);
        int quantity     = parseInt(req.getParameter("quantity"), 1);
        double unitPrice = parseDouble(req.getParameter("unit_price"), 0);
        String orderType = "quotation".equals(req.getParameter("order_type")) ? "quotation" : "order";

        String buyerName    = req.getParameter("buyer_name");
        String buyerEmail   = req.getParameter("buyer_email");
        String buyerPhone   = req.getParameter("buyer_phone");
        String buyerCompany = req.getParameter("buyer_company");
        String address      = req.getParameter("delivery_address");
        String city         = req.getParameter("delivery_city");
        String pincode      = req.getParameter("delivery_pincode");
        String notes        = req.getParameter("notes");

        double total = quantity * unitPrice;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO b2b_orders (business_id,buyer_name,buyer_email,buyer_phone,buyer_company," +
                "product_id,quantity,unit_price,total_amount,delivery_address,delivery_city," +
                "delivery_pincode,order_type,notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            ps.setInt(1, businessId);
            ps.setString(2, buyerName);   ps.setString(3, buyerEmail);
            ps.setString(4, buyerPhone);  ps.setString(5, buyerCompany);
            ps.setInt(6, productId);
            ps.setInt(7, quantity);
            ps.setDouble(8, unitPrice);   ps.setDouble(9, total);
            ps.setString(10, address);    ps.setString(11, city);
            ps.setString(12, pincode);    ps.setString(13, orderType);
            ps.setString(14, notes);
            ps.executeUpdate();
            res.sendRedirect(req.getContextPath() + "/bulk.jsp?ordered=true");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private static int parseInt(String val, int def) {
        if (val == null || val.trim().isEmpty()) return def;
        try { return Integer.parseInt(val.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static double parseDouble(String val, double def) {
        if (val == null || val.trim().isEmpty()) return def;
        try { return Double.parseDouble(val.trim()); } catch (NumberFormatException e) { return def; }
    }
}
