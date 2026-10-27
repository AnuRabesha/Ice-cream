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

@WebServlet("/reviews")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action  = req.getParameter("action");
        String shopParam = req.getParameter("shopId");
        String sort    = req.getParameter("sort");
        User   user    = (User) req.getSession().getAttribute("user");

        try (Connection conn = DBConnection.getConnection()) {

            Integer shopId = (shopParam != null) ? Integer.parseInt(shopParam) : null;

            // Stats
            req.setAttribute("shopList",    getShopList(conn));
            req.setAttribute("stats",       getStats(conn, shopId));
            req.setAttribute("distribution",getRatingDistribution(conn, shopId));
            req.setAttribute("reviews",     getReviews(conn, shopId, sort));
            req.setAttribute("shopFilter",  shopId);
            req.setAttribute("sortFilter",  sort);

            // Eligibility: has the logged-in user purchased from this shop and not yet reviewed?
            if (user != null && shopId != null) {
                req.setAttribute("canReview",    canReview(conn, user.getId(), shopId));
                req.setAttribute("existingReview", getExistingReview(conn, user.getId(), shopId));
            }
        } catch (SQLException e) { throw new ServletException(e); }

        req.getRequestDispatcher("/reviews.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { res.sendRedirect("login.jsp"); return; }

        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            switch (action == null ? "" : action) {
                case "submit":  submitReview(req, res, conn, user);  break;
                case "edit":    editReview(req, res, conn, user);    break;
                case "delete":  deleteReview(req, res, conn, user);  break;
                case "report":  reportReview(req, res, conn);        break;
                case "ownerReply": handleOwnerReply(req, res, conn, user); break;
                default:        res.sendRedirect("reviews");
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    // ── Submit ────────────────────────────────────────────────────────────────
    private void submitReview(HttpServletRequest req, HttpServletResponse res,
                              Connection conn, User user) throws SQLException, IOException, ServletException {
        int shopId  = Integer.parseInt(req.getParameter("shopId"));
        int rating  = Integer.parseInt(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        // Duplicate guard
        if (getExistingReview(conn, user.getId(), shopId) != null) {
            res.sendRedirect("reviews?shopId=" + shopId + "&error=duplicate"); return;
        }

        // Verified purchase check
        boolean verified = hasDeliveredOrder(conn, user.getId(), shopId);
        Integer orderId  = getDeliveredOrderId(conn, user.getId(), shopId);

        // Photo upload
        String photoUrl = handlePhotoUpload(req);

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO reviews (user_id,shop_id,rating,comment,photo_url,is_verified_purchase,order_id) " +
            "VALUES (?,?,?,?,?,?,?)");
        ps.setInt(1, user.getId()); ps.setInt(2, shopId); ps.setInt(3, rating);
        ps.setString(4, comment); ps.setString(5, photoUrl);
        ps.setInt(6, verified ? 1 : 0);
        if (orderId != null) ps.setInt(7, orderId); else ps.setNull(7, Types.INTEGER);
        ps.executeUpdate();

        // Recalculate shop average rating
        updateShopRating(conn, shopId);
        res.sendRedirect("reviews?shopId=" + shopId + "&submitted=true");
    }

    // ── Edit ──────────────────────────────────────────────────────────────────
    private void editReview(HttpServletRequest req, HttpServletResponse res,
                            Connection conn, User user) throws SQLException, IOException, ServletException {
        int reviewId = Integer.parseInt(req.getParameter("reviewId"));
        int shopId   = Integer.parseInt(req.getParameter("shopId"));
        int rating   = Integer.parseInt(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        // Ownership check
        PreparedStatement own = conn.prepareStatement("SELECT user_id FROM reviews WHERE id=?");
        own.setInt(1, reviewId);
        ResultSet rs = own.executeQuery();
        if (!rs.next() || rs.getInt("user_id") != user.getId()) {
            res.sendRedirect("reviews?shopId=" + shopId + "&error=unauthorized"); return;
        }

        String photoUrl = handlePhotoUpload(req);
        if (photoUrl != null) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE reviews SET rating=?,comment=?,photo_url=?,is_edited=1 WHERE id=? AND user_id=?");
            ps.setInt(1,rating); ps.setString(2,comment); ps.setString(3,photoUrl);
            ps.setInt(4,reviewId); ps.setInt(5,user.getId()); ps.executeUpdate();
        } else {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE reviews SET rating=?,comment=?,is_edited=1 WHERE id=? AND user_id=?");
            ps.setInt(1,rating); ps.setString(2,comment);
            ps.setInt(3,reviewId); ps.setInt(4,user.getId()); ps.executeUpdate();
        }
        updateShopRating(conn, shopId);
        res.sendRedirect("reviews?shopId=" + shopId + "&edited=true");
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    private void deleteReview(HttpServletRequest req, HttpServletResponse res,
                              Connection conn, User user) throws SQLException, IOException {
        int reviewId = Integer.parseInt(req.getParameter("reviewId"));
        int shopId   = Integer.parseInt(req.getParameter("shopId"));

        PreparedStatement ps = conn.prepareStatement(
            "DELETE FROM reviews WHERE id=? AND user_id=?");
        ps.setInt(1, reviewId); ps.setInt(2, user.getId()); ps.executeUpdate();
        updateShopRating(conn, shopId);
        res.sendRedirect("reviews?shopId=" + shopId + "&deleted=true");
    }

    // ── Report ────────────────────────────────────────────────────────────────
    private void reportReview(HttpServletRequest req, HttpServletResponse res,
                              Connection conn) throws SQLException, IOException {
        int reviewId = Integer.parseInt(req.getParameter("reviewId"));
        int shopId   = Integer.parseInt(req.getParameter("shopId"));
        PreparedStatement ps = conn.prepareStatement("UPDATE reviews SET is_reported=1 WHERE id=?");
        ps.setInt(1, reviewId); ps.executeUpdate();
        res.sendRedirect("reviews?shopId=" + shopId + "&reported=true");
    }

    // ── Owner Reply ───────────────────────────────────────────────────────────
    private void handleOwnerReply(HttpServletRequest req, HttpServletResponse res,
                                  Connection conn, User user) throws SQLException, IOException {
        if (user == null || !"business".equals(user.getRole())) {
            res.sendRedirect("login.jsp"); return;
        }
        int reviewId = Integer.parseInt(req.getParameter("reviewId"));
        int shopId   = Integer.parseInt(req.getParameter("shopId"));
        String reply = req.getParameter("reply");

        // Verify this review belongs to owner's shop
        PreparedStatement check = conn.prepareStatement(
            "SELECT r.id FROM reviews r JOIN shops s ON r.shop_id=s.id " +
            "WHERE r.id=? AND s.owner_id=?");
        check.setInt(1, reviewId); check.setInt(2, user.getId());
        if (!check.executeQuery().next()) { res.sendRedirect("reviews"); return; }

        PreparedStatement ps = conn.prepareStatement(
            "UPDATE reviews SET owner_reply=?, owner_reply_at=CURRENT_TIMESTAMP WHERE id=?");
        ps.setString(1, reply); ps.setInt(2, reviewId); ps.executeUpdate();
        res.sendRedirect("reviews?shopId=" + shopId + "&replied=true");
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private List<Review> getReviews(Connection conn, Integer shopId, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, u.name AS user_name, s.name AS shop_name " +
            "FROM reviews r JOIN users u ON r.user_id=u.id JOIN shops s ON r.shop_id=s.id " +
            "WHERE r.is_reported=0");
        if (shopId != null) sql.append(" AND r.shop_id=?");
        if ("highest".equals(sort))  sql.append(" ORDER BY r.rating DESC, r.created_at DESC");
        else if ("lowest".equals(sort)) sql.append(" ORDER BY r.rating ASC, r.created_at DESC");
        else sql.append(" ORDER BY r.created_at DESC");

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        if (shopId != null) ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        List<Review> list = new ArrayList<>();
        while (rs.next()) list.add(mapReview(rs));
        return list;
    }

    private Map<String, Object> getStats(Connection conn, Integer shopId) throws SQLException {
        String sql = "SELECT COUNT(*) AS total, AVG(rating) AS avg, " +
            "SUM(is_verified_purchase) AS verified FROM reviews WHERE is_reported=0";
        if (shopId != null) sql += " AND shop_id=?";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (shopId != null) ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        Map<String, Object> m = new LinkedHashMap<>();
        if (rs.next()) {
            m.put("total",    rs.getInt("total"));
            m.put("avg",      rs.getDouble("avg"));
            m.put("verified", rs.getInt("verified"));
        }
        return m;
    }

    private Map<Integer, Integer> getRatingDistribution(Connection conn, Integer shopId) throws SQLException {
        String sql = "SELECT rating, COUNT(*) AS cnt FROM reviews WHERE is_reported=0";
        if (shopId != null) sql += " AND shop_id=?";
        sql += " GROUP BY rating ORDER BY rating DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (shopId != null) ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        Map<Integer, Integer> dist = new LinkedHashMap<>();
        for (int i = 5; i >= 1; i--) dist.put(i, 0);
        while (rs.next()) dist.put(rs.getInt("rating"), rs.getInt("cnt"));
        return dist;
    }

    private List<Map<String, Object>> getShopList(Connection conn) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM shops ORDER BY name");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", rs.getInt("id")); m.put("name", rs.getString("name"));
            list.add(m);
        }
        return list;
    }

    private Review getExistingReview(Connection conn, int userId, int shopId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT r.*, u.name AS user_name, s.name AS shop_name " +
            "FROM reviews r JOIN users u ON r.user_id=u.id JOIN shops s ON r.shop_id=s.id " +
            "WHERE r.user_id=? AND r.shop_id=?");
        ps.setInt(1, userId); ps.setInt(2, shopId);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? mapReview(rs) : null;
    }

    private boolean canReview(Connection conn, int userId, int shopId) throws SQLException {
        // Must have a delivered order from this shop
        PreparedStatement ps = conn.prepareStatement(
            "SELECT o.id FROM orders o JOIN order_items oi ON o.id=oi.order_id " +
            "JOIN products p ON oi.product_id=p.id " +
            "WHERE o.user_id=? AND p.shop_id=? AND o.status='delivered' LIMIT 1");
        ps.setInt(1, userId); ps.setInt(2, shopId);
        return ps.executeQuery().next();
    }

    private boolean hasDeliveredOrder(Connection conn, int userId, int shopId) throws SQLException {
        return canReview(conn, userId, shopId);
    }

    private Integer getDeliveredOrderId(Connection conn, int userId, int shopId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT o.id FROM orders o JOIN order_items oi ON o.id=oi.order_id " +
            "JOIN products p ON oi.product_id=p.id " +
            "WHERE o.user_id=? AND p.shop_id=? AND o.status='delivered' LIMIT 1");
        ps.setInt(1, userId); ps.setInt(2, shopId);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? rs.getInt("id") : null;
    }

    private void updateShopRating(Connection conn, int shopId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE shops SET rating = (SELECT ROUND(AVG(rating),1) FROM reviews " +
            "WHERE shop_id=? AND is_reported=0) WHERE id=?");
        ps.setInt(1, shopId); ps.setInt(2, shopId); ps.executeUpdate();
    }

    private String handlePhotoUpload(HttpServletRequest req) throws ServletException {
        try {
            Part photo = req.getPart("reviewPhoto");
            if (photo == null || photo.getSize() == 0) return null;
            String fileName = "review_" + System.currentTimeMillis() + "_" +
                              Paths.get(photo.getSubmittedFileName()).getFileName();
            String uploadDir = getServletContext().getRealPath("/uploads/reviews/");
            new File(uploadDir).mkdirs();
            photo.write(uploadDir + fileName);
            return "uploads/reviews/" + fileName;
        } catch (IOException | ServletException e) {
            throw new ServletException("Photo upload failed", e);
        }
    }

    private Review mapReview(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setShopId(rs.getInt("shop_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setUserName(rs.getString("user_name"));
        r.setShopName(rs.getString("shop_name"));
        r.setCreatedAt(rs.getString("created_at"));
        r.setPhotoUrl(rs.getString("photo_url"));
        r.setOwnerReply(rs.getString("owner_reply"));
        r.setOwnerReplyAt(rs.getString("owner_reply_at"));
        r.setVerifiedPurchase(rs.getInt("is_verified_purchase") == 1);
        r.setReported(rs.getInt("is_reported") == 1);
        r.setEdited(rs.getInt("is_edited") == 1);
        int oid = rs.getInt("order_id");
        if (!rs.wasNull()) r.setOrderId(oid);
        return r;
    }
}
