package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet({"/home", "/scoopy-world"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try (Connection conn = DBConnection.getConnection()) {
            req.setAttribute("featuredShops", getFeaturedShops(conn));
            req.setAttribute("trendingFlavours", getTrendingFlavours(conn));
            req.setAttribute("bestsellerProducts", getBestsellerProducts(conn));
            req.setAttribute("recentReviews", getRecentReviews(conn));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        String path = req.getServletPath();
        String view = "/scoopy-world".equals(path) ? "/scoopy-world.jsp" : "/index.jsp";
        req.getRequestDispatcher(view).forward(req, res);
    }

    private List<Shop> getFeaturedShops(Connection conn) throws SQLException {
        List<Shop> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT * FROM shops WHERE is_featured=1 ORDER BY rating DESC LIMIT 6");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Shop s = new Shop();
            s.setId(rs.getInt("id")); s.setName(rs.getString("name"));
            s.setDescription(rs.getString("description")); s.setCity(rs.getString("city"));
            s.setRating(rs.getDouble("rating")); s.setImageUrl(rs.getString("image_url"));
            s.setHomeDelivery(rs.getInt("home_delivery") == 1);
            s.setDeliveryTime(rs.getString("delivery_time"));
            list.add(s);
        }
        return list;
    }

    private List<Flavour> getTrendingFlavours(Connection conn) throws SQLException {
        List<Flavour> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM flavours WHERE is_trending=1 LIMIT 8");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Flavour f = new Flavour();
            f.setId(rs.getInt("id")); f.setName(rs.getString("name"));
            f.setDescription(rs.getString("description")); f.setCategory(rs.getString("category"));
            f.setImageUrl(rs.getString("image_url"));
            list.add(f);
        }
        return list;
    }

    private List<Product> getBestsellerProducts(Connection conn) throws SQLException {
        List<Product> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT p.*, s.name AS shop_name FROM products p JOIN shops s ON p.shop_id=s.id WHERE p.is_bestseller=1 LIMIT 8");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Product p = new Product();
            p.setId(rs.getInt("id")); p.setName(rs.getString("name"));
            p.setDescription(rs.getString("description")); p.setPrice(rs.getDouble("price"));
            p.setCategory(rs.getString("category")); p.setImageUrl(rs.getString("image_url"));
            p.setShopName(rs.getString("shop_name"));
            list.add(p);
        }
        return list;
    }

    private List<Review> getRecentReviews(Connection conn) throws SQLException {
        List<Review> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT r.*, u.name AS user_name, s.name AS shop_name FROM reviews r " +
            "JOIN users u ON r.user_id=u.id JOIN shops s ON r.shop_id=s.id ORDER BY r.created_at DESC LIMIT 6");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Review r = new Review();
            r.setId(rs.getInt("id")); r.setRating(rs.getInt("rating"));
            r.setComment(rs.getString("comment")); r.setUserName(rs.getString("user_name"));
            r.setShopName(rs.getString("shop_name")); r.setCreatedAt(rs.getString("created_at"));
            list.add(r);
        }
        return list;
    }
}
