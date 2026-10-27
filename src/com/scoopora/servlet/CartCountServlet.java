package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/cart-count")
public class CartCountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json");
        User user = (User) req.getSession().getAttribute("user");
        int count = 0;
        if (user != null) {
            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT COALESCE(SUM(quantity),0) FROM cart WHERE user_id=?");
                ps.setInt(1, user.getId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) count = rs.getInt(1);
            } catch (SQLException e) { /* return 0 */ }
        }
        res.getWriter().write("{\"count\":" + count + "}");
    }
}
