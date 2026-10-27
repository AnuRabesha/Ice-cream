package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.Flavour;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/flavours")
public class FlavoursServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String category = req.getParameter("category");
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM flavours";
            if (category != null && !category.isEmpty()) sql += " WHERE category=?";
            sql += " ORDER BY is_trending DESC, name ASC";
            PreparedStatement ps = conn.prepareStatement(sql);
            if (category != null && !category.isEmpty()) ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            List<Flavour> flavours = new ArrayList<>();
            while (rs.next()) {
                Flavour f = new Flavour();
                f.setId(rs.getInt("id")); f.setName(rs.getString("name"));
                f.setDescription(rs.getString("description")); f.setCategory(rs.getString("category"));
                f.setImageUrl(rs.getString("image_url"));
                flavours.add(f);
            }
            req.setAttribute("flavours", flavours);
            req.setAttribute("categoryFilter", category);
        } catch (SQLException e) { throw new ServletException(e); }
        req.getRequestDispatcher("/flavours.jsp").forward(req, res);
    }
}
