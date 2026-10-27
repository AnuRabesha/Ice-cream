package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.BusinessAccount;
import com.scoopora.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/supplier-compare")
public class SupplierCompareServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            if ("my-quotes".equals(action)) {
                loadMyQuotes(conn, req);
            } else {
                loadCompareData(conn, req);
            }
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/supplier-compare.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            switch (action == null ? "" : action) {
                case "request_quote":  handleRequestQuote(conn, req, res);  return;
                case "submit_offer":   handleSubmitOffer(conn, req, res);   return;
                case "accept_offer":   handleAcceptOffer(conn, req, res);   return;
                case "reject_offer":   handleRejectOffer(conn, req, res);   return;
            }
        } catch (SQLException e) { throw new ServletException(e); }
        res.sendRedirect(req.getContextPath() + "/supplier-compare");
    }

    // ── Compare Page Data ─────────────────────────────────────────────────────
    private void loadCompareData(Connection conn, HttpServletRequest req) throws SQLException {
        String category  = req.getParameter("category");
        String sortBy    = req.getParameter("sort");
        String minStock  = req.getParameter("minStock");
        String maxPrice  = req.getParameter("maxPrice");
        String maxMoq    = req.getParameter("maxMoq");
        String verified  = req.getParameter("verified");

        // Build unified supplier product list from both wholesale_products (shops) and business_products
        StringBuilder sql = new StringBuilder(
            "SELECT 'shop' AS src_type, wp.id AS product_id, s.id AS supplier_id, " +
            "s.name AS supplier_name, s.city AS supplier_city, " +
            "'verified' AS verification_status, " +
            "wp.name AS product_name, wp.category, wp.unit_label AS pack_size, " +
            "wp.base_price AS wholesale_price, wp.moq, wp.stock, " +
            "CASE WHEN wp.base_price * wp.moq >= 10000 THEN 0 ELSE 500 END AS delivery_charge, " +
            "s.delivery_time, wp.image_url " +
            "FROM wholesale_products wp JOIN shops s ON wp.shop_id = s.id WHERE wp.is_active = 1 " +
            "UNION ALL " +
            "SELECT 'business' AS src_type, bp.id AS product_id, ba.id AS supplier_id, " +
            "ba.business_name AS supplier_name, ba.city AS supplier_city, " +
            "ba.verification_status, " +
            "bp.name AS product_name, bp.category, bp.pack_size, " +
            "bp.wholesale_price, bp.moq, bp.stock, " +
            "0 AS delivery_charge, ba.delivery_time, bp.image_url " +
            "FROM business_products bp JOIN business_accounts ba ON bp.business_id = ba.id " +
            "WHERE bp.is_available = 1 AND ba.is_active = 1");

        // Wrap in subquery for filtering
        StringBuilder outer = new StringBuilder("SELECT * FROM (").append(sql).append(") t WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.isEmpty()) {
            outer.append(" AND category = ?"); params.add(category);
        }
        if (minStock != null && !minStock.isEmpty()) {
            outer.append(" AND stock >= ?"); params.add(Integer.parseInt(minStock));
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            outer.append(" AND wholesale_price <= ?"); params.add(Double.parseDouble(maxPrice));
        }
        if (maxMoq != null && !maxMoq.isEmpty()) {
            outer.append(" AND moq <= ?"); params.add(Integer.parseInt(maxMoq));
        }
        if ("true".equals(verified)) {
            outer.append(" AND verification_status = 'verified'");
        }

        String order = " ORDER BY ";
        if ("price_asc".equals(sortBy))    order += "wholesale_price ASC";
        else if ("price_desc".equals(sortBy)) order += "wholesale_price DESC";
        else if ("moq_asc".equals(sortBy))    order += "moq ASC";
        else if ("stock_desc".equals(sortBy)) order += "stock DESC";
        else order += "supplier_name ASC";
        outer.append(order);

        PreparedStatement ps = conn.prepareStatement(outer.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        ResultSet rs = ps.executeQuery();

        List<Map<String, Object>> rows = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> r = new LinkedHashMap<>();
            r.put("srcType",            rs.getString("src_type"));
            r.put("productId",          rs.getInt("product_id"));
            r.put("supplierId",         rs.getInt("supplier_id"));
            r.put("supplierName",       rs.getString("supplier_name"));
            r.put("supplierCity",       rs.getString("supplier_city"));
            r.put("verificationStatus", rs.getString("verification_status"));
            r.put("productName",        rs.getString("product_name"));
            r.put("category",           rs.getString("category"));
            r.put("packSize",           rs.getString("pack_size"));
            r.put("wholesalePrice",     rs.getDouble("wholesale_price"));
            r.put("moq",                rs.getInt("moq"));
            r.put("stock",              rs.getInt("stock"));
            r.put("deliveryCharge",     rs.getDouble("delivery_charge"));
            r.put("deliveryTime",       rs.getString("delivery_time"));
            r.put("imageUrl",           rs.getString("image_url"));
            rows.add(r);
        }

        req.setAttribute("compareRows", rows);
        req.setAttribute("selectedCategory", category);
        req.setAttribute("selectedSort", sortBy);
        req.setAttribute("filterMinStock", minStock);
        req.setAttribute("filterMaxPrice", maxPrice);
        req.setAttribute("filterMaxMoq", maxMoq);
        req.setAttribute("filterVerified", verified);
        req.setAttribute("action", "compare");
    }

    // ── My Quotes ─────────────────────────────────────────────────────────────
    private void loadMyQuotes(Connection conn, HttpServletRequest req) throws SQLException {
        User user = (User) req.getSession().getAttribute("user");
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");

        if (user != null) {
            // Buyer: load their requests + offers received
            PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM quotation_requests WHERE requester_id = ? ORDER BY created_at DESC");
            ps.setInt(1, user.getId());
            ResultSet rs = ps.executeQuery();
            List<Map<String, Object>> requests = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> qr = new LinkedHashMap<>();
                qr.put("id",                  rs.getInt("id"));
                qr.put("productName",         rs.getString("product_name"));
                qr.put("quantity",            rs.getInt("quantity"));
                qr.put("preferredPackSize",   rs.getString("preferred_pack_size"));
                qr.put("deliveryLocation",    rs.getString("delivery_location"));
                qr.put("requiredDeliveryDate",rs.getDate("required_delivery_date"));
                qr.put("additionalReqs",      rs.getString("additional_requirements"));
                qr.put("status",              rs.getString("status"));
                qr.put("createdAt",           rs.getTimestamp("created_at"));
                qr.put("offers",              getOffersForRequest(conn, rs.getInt("id")));
                requests.add(qr);
            }
            req.setAttribute("myRequests", requests);
        }

        if (ba != null) {
            // Supplier: load open requests they can respond to + their submitted offers
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT qr.*, " +
                "(SELECT COUNT(*) FROM quotation_offers qo WHERE qo.request_id=qr.id AND qo.business_id=?) AS already_offered " +
                "FROM quotation_requests qr WHERE qr.status='open' ORDER BY qr.created_at DESC");
            ps2.setInt(1, ba.getId());
            ResultSet rs2 = ps2.executeQuery();
            List<Map<String, Object>> openRequests = new ArrayList<>();
            while (rs2.next()) {
                Map<String, Object> qr = new LinkedHashMap<>();
                qr.put("id",                  rs2.getInt("id"));
                qr.put("requesterName",       rs2.getString("requester_name"));
                qr.put("requesterCompany",    rs2.getString("requester_company"));
                qr.put("productName",         rs2.getString("product_name"));
                qr.put("quantity",            rs2.getInt("quantity"));
                qr.put("preferredPackSize",   rs2.getString("preferred_pack_size"));
                qr.put("deliveryLocation",    rs2.getString("delivery_location"));
                qr.put("requiredDeliveryDate",rs2.getDate("required_delivery_date"));
                qr.put("additionalReqs",      rs2.getString("additional_requirements"));
                qr.put("alreadyOffered",      rs2.getInt("already_offered") > 0);
                openRequests.add(qr);
            }
            req.setAttribute("openRequests", openRequests);
        }

        req.setAttribute("action", "my-quotes");
    }

    private List<Map<String, Object>> getOffersForRequest(Connection conn, int requestId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT qo.*, " +
            "COALESCE(s.name, ba.business_name) AS supplier_name, " +
            "COALESCE(s.city, ba.city) AS supplier_city, " +
            "COALESCE('verified', ba.verification_status) AS verification_status " +
            "FROM quotation_offers qo " +
            "LEFT JOIN shops s ON qo.shop_id = s.id " +
            "LEFT JOIN business_accounts ba ON qo.business_id = ba.id " +
            "WHERE qo.request_id = ? ORDER BY qo.unit_price ASC");
        ps.setInt(1, requestId);
        ResultSet rs = ps.executeQuery();
        List<Map<String, Object>> offers = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> o = new LinkedHashMap<>();
            o.put("id",               rs.getInt("id"));
            o.put("supplierName",     rs.getString("supplier_name"));
            o.put("supplierCity",     rs.getString("supplier_city"));
            o.put("verificationStatus", rs.getString("verification_status"));
            o.put("unitPrice",        rs.getDouble("unit_price"));
            o.put("packSize",         rs.getString("pack_size"));
            o.put("deliveryCharge",   rs.getDouble("delivery_charge"));
            o.put("estimatedDelivery",rs.getString("estimated_delivery"));
            o.put("notes",            rs.getString("notes"));
            o.put("status",           rs.getString("status"));
            o.put("createdAt",        rs.getTimestamp("created_at"));
            offers.add(o);
        }
        return offers;
    }

    // ── Request a Quote ───────────────────────────────────────────────────────
    private void handleRequestQuote(Connection conn, HttpServletRequest req, HttpServletResponse res)
            throws SQLException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO quotation_requests (requester_id,requester_name,requester_email,requester_company," +
            "product_name,quantity,preferred_pack_size,delivery_location,required_delivery_date,additional_requirements) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)");
        ps.setInt(1, user.getId());
        ps.setString(2, req.getParameter("requester_name"));
        ps.setString(3, req.getParameter("requester_email"));
        ps.setString(4, req.getParameter("requester_company"));
        ps.setString(5, req.getParameter("product_name"));
        ps.setInt(6, Integer.parseInt(req.getParameter("quantity")));
        ps.setString(7, req.getParameter("preferred_pack_size"));
        ps.setString(8, req.getParameter("delivery_location"));
        String dd = req.getParameter("required_delivery_date");
        ps.setDate(9, (dd != null && !dd.isEmpty()) ? java.sql.Date.valueOf(dd) : null);
        ps.setString(10, req.getParameter("additional_requirements"));
        ps.executeUpdate();
        res.sendRedirect(req.getContextPath() + "/supplier-compare?action=my-quotes&quoted=true");
    }

    // ── Submit Offer (supplier) ───────────────────────────────────────────────
    private void handleSubmitOffer(Connection conn, HttpServletRequest req, HttpServletResponse res)
            throws SQLException, IOException {
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");
        if (ba == null) { res.sendRedirect(req.getContextPath() + "/business-login.jsp"); return; }

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO quotation_offers (request_id,supplier_type,business_id,unit_price,pack_size," +
            "delivery_charge,estimated_delivery,notes) VALUES (?,?,?,?,?,?,?,?)");
        ps.setInt(1, Integer.parseInt(req.getParameter("request_id")));
        ps.setString(2, "business");
        ps.setInt(3, ba.getId());
        ps.setDouble(4, Double.parseDouble(req.getParameter("unit_price")));
        ps.setString(5, req.getParameter("pack_size"));
        ps.setDouble(6, Double.parseDouble(req.getParameter("delivery_charge")));
        ps.setString(7, req.getParameter("estimated_delivery"));
        ps.setString(8, req.getParameter("notes"));
        ps.executeUpdate();
        res.sendRedirect(req.getContextPath() + "/supplier-compare?action=my-quotes&offered=true");
    }

    // ── Accept Offer (buyer) ──────────────────────────────────────────────────
    private void handleAcceptOffer(Connection conn, HttpServletRequest req, HttpServletResponse res)
            throws SQLException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        int offerId    = Integer.parseInt(req.getParameter("offer_id"));
        int requestId  = Integer.parseInt(req.getParameter("request_id"));

        // Accept this offer, reject others for same request
        PreparedStatement ps1 = conn.prepareStatement(
            "UPDATE quotation_offers SET status='accepted' WHERE id=?");
        ps1.setInt(1, offerId);
        ps1.executeUpdate();

        PreparedStatement ps2 = conn.prepareStatement(
            "UPDATE quotation_offers SET status='rejected' WHERE request_id=? AND id != ?");
        ps2.setInt(1, requestId); ps2.setInt(2, offerId);
        ps2.executeUpdate();

        PreparedStatement ps3 = conn.prepareStatement(
            "UPDATE quotation_requests SET status='closed' WHERE id=? AND requester_id=?");
        ps3.setInt(1, requestId); ps3.setInt(2, user.getId());
        ps3.executeUpdate();

        res.sendRedirect(req.getContextPath() + "/supplier-compare?action=my-quotes&accepted=true");
    }

    // ── Reject Offer (buyer) ──────────────────────────────────────────────────
    private void handleRejectOffer(Connection conn, HttpServletRequest req, HttpServletResponse res)
            throws SQLException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        PreparedStatement ps = conn.prepareStatement(
            "UPDATE quotation_offers SET status='rejected' WHERE id=?");
        ps.setInt(1, Integer.parseInt(req.getParameter("offer_id")));
        ps.executeUpdate();
        res.sendRedirect(req.getContextPath() + "/supplier-compare?action=my-quotes");
    }
}
