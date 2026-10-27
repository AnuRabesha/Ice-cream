package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/shops")
public class ShopServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        try (Connection conn = DBConnection.getConnection()) {
            if (idParam != null) {
                // --- Detail page ---
                int shopId = Integer.parseInt(idParam);
                Shop shop = getShopById(conn, shopId);
                if (shop == null) { res.sendError(404, "Shop not found"); return; }
                req.setAttribute("shop", shop);
                req.setAttribute("products", getShopProducts(conn, shopId));
                req.setAttribute("reviews", getShopReviews(conn, shopId));
                req.setAttribute("avgRating", getAvgRating(conn, shopId));
                req.getRequestDispatcher("/shop-detail.jsp").forward(req, res);
            } else {
                // --- Listing page ---
                String city   = req.getParameter("city");
                String sort   = req.getParameter("sort");
                int page      = req.getParameter("page") != null ? Integer.parseInt(req.getParameter("page")) : 1;
                int pageSize  = 6;
                int offset    = (page - 1) * pageSize;

                req.setAttribute("shops",      getAllShops(conn, city, sort, pageSize, offset));
                req.setAttribute("totalShops", countShops(conn, city));
                req.setAttribute("cities",     getCities(conn));
                req.setAttribute("currentPage", page);
                req.setAttribute("pageSize",   pageSize);
                req.setAttribute("cityFilter", city);
                req.setAttribute("sortFilter", sort);
                req.getRequestDispatcher("/shops.jsp").forward(req, res);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private Shop mapShop(ResultSet rs) throws SQLException {
        Shop s = new Shop();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setDescription(rs.getString("description"));
        s.setAddress(rs.getString("address"));
        s.setCity(rs.getString("city"));
        s.setRating(rs.getDouble("rating"));
        s.setImageUrl(rs.getString("image_url"));
        s.setFeatured(rs.getInt("is_featured") == 1);
        s.setOpeningHours(rs.getString("opening_hours"));
        s.setPhone(rs.getString("phone"));
        s.setEmail(rs.getString("email"));
        s.setWebsite(rs.getString("website"));
        s.setMapsUrl(rs.getString("maps_url"));
        s.setHomeDelivery(rs.getInt("home_delivery") == 1);
        s.setDeliveryFee(rs.getDouble("delivery_fee"));
        s.setMinOrder(rs.getDouble("min_order"));
        s.setDeliveryTime(rs.getString("delivery_time"));
        try { s.setDeliveryAreas(rs.getString("delivery_areas")); } catch (SQLException ignored) {}
        try { s.setPickupAvailable(rs.getBoolean("pickup_available")); } catch (SQLException ignored) {}
        return s;
    }

    private List<Shop> getAllShops(Connection conn, String city, String sort, int limit, int offset) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM shops WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (city != null && !city.isEmpty()) { sql.append(" AND city=?"); params.add(city); }
        if ("rating".equals(sort))           sql.append(" ORDER BY rating DESC");
        else if ("name".equals(sort))        sql.append(" ORDER BY name ASC");
        else                                 sql.append(" ORDER BY is_featured DESC, rating DESC");
        sql.append(" LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        ResultSet rs = ps.executeQuery();
        List<Shop> list = new ArrayList<>();
        while (rs.next()) list.add(mapShop(rs));
        return list;
    }

    private int countShops(Connection conn, String city) throws SQLException {
        String sql = city != null && !city.isEmpty()
            ? "SELECT COUNT(*) FROM shops WHERE city=?"
            : "SELECT COUNT(*) FROM shops";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (city != null && !city.isEmpty()) ps.setString(1, city);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? rs.getInt(1) : 0;
    }

    private List<String> getCities(Connection conn) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT city FROM shops ORDER BY city");
        ResultSet rs = ps.executeQuery();
        List<String> list = new ArrayList<>();
        while (rs.next()) list.add(rs.getString("city"));
        return list;
    }

    private Shop getShopById(Connection conn, int id) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM shops WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? mapShop(rs) : null;
    }

    private List<Product> getShopProducts(Connection conn, int shopId) throws SQLException {
        List<Product> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT p.*, f.name AS flavour_name FROM products p " +
            "LEFT JOIN flavours f ON p.flavour_id=f.id WHERE p.shop_id=? ORDER BY p.is_bestseller DESC, p.name");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Product p = new Product();
            p.setId(rs.getInt("id")); p.setName(rs.getString("name"));
            p.setDescription(rs.getString("description")); p.setPrice(rs.getDouble("price"));
            p.setCategory(rs.getString("category")); p.setImageUrl(rs.getString("image_url"));
            p.setBestseller(rs.getInt("is_bestseller") == 1); p.setStock(rs.getInt("stock"));
            list.add(p);
        }
        return list;
    }

    private List<Review> getShopReviews(Connection conn, int shopId) throws SQLException {
        List<Review> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT r.*, u.name AS user_name FROM reviews r " +
            "JOIN users u ON r.user_id=u.id WHERE r.shop_id=? ORDER BY r.created_at DESC");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Review r = new Review();
            r.setId(rs.getInt("id")); r.setRating(rs.getInt("rating"));
            r.setComment(rs.getString("comment")); r.setUserName(rs.getString("user_name"));
            r.setCreatedAt(rs.getString("created_at"));
            list.add(r);
        }
        return list;
    }

    private double getAvgRating(Connection conn, int shopId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT AVG(rating) FROM reviews WHERE shop_id=?");
        ps.setInt(1, shopId);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? rs.getDouble(1) : 0;
    }
}
