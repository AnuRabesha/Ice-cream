package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String query = req.getParameter("q");
        if (query == null || query.trim().isEmpty()) { res.sendRedirect("home"); return; }
        String like = "%" + query.trim() + "%";
        try (Connection conn = DBConnection.getConnection()) {
            req.setAttribute("shops", searchShops(conn, like));
            req.setAttribute("products", searchProducts(conn, like));
            req.setAttribute("flavours", searchFlavours(conn, like));
            req.setAttribute("query", query);
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/search.jsp").forward(req, res);
    }

    private List<Shop> searchShops(Connection conn, String like) throws SQLException {
        List<Shop> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM shops WHERE name LIKE ? OR city LIKE ? OR description LIKE ?");
        ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Shop s = new Shop();
            s.setId(rs.getInt("id")); s.setName(rs.getString("name"));
            s.setCity(rs.getString("city")); s.setRating(rs.getDouble("rating"));
            s.setImageUrl(rs.getString("image_url")); s.setDescription(rs.getString("description"));
            list.add(s);
        }
        return list;
    }

    private List<Product> searchProducts(Connection conn, String like) throws SQLException {
        List<Product> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT p.*, s.name AS shop_name FROM products p JOIN shops s ON p.shop_id=s.id WHERE p.name LIKE ? OR p.description LIKE ?");
        ps.setString(1, like); ps.setString(2, like);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Product p = new Product();
            p.setId(rs.getInt("id")); p.setName(rs.getString("name"));
            p.setPrice(rs.getDouble("price")); p.setImageUrl(rs.getString("image_url"));
            p.setShopName(rs.getString("shop_name")); p.setCategory(rs.getString("category"));
            list.add(p);
        }
        return list;
    }

    private List<Flavour> searchFlavours(Connection conn, String like) throws SQLException {
        List<Flavour> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM flavours WHERE name LIKE ? OR category LIKE ?");
        ps.setString(1, like); ps.setString(2, like);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Flavour f = new Flavour();
            f.setId(rs.getInt("id")); f.setName(rs.getString("name"));
            f.setCategory(rs.getString("category")); f.setImageUrl(rs.getString("image_url"));
            list.add(f);
        }
        return list;
    }
}
