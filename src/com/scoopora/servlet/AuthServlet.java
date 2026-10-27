package com.scoopora.servlet;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.scoopora.db.DBConnection;
import com.scoopora.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("login".equals(action)) handleLogin(req, res);
        else if ("register".equals(action)) handleRegister(req, res);
        else if ("logout".equals(action)) handleLogout(req, res);
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE email=?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password");
                boolean valid = BCrypt.verifyer().verify(password.toCharArray(), storedHash).verified;
                if (valid) {
                    User user = new User();
                    user.setId(rs.getInt("id")); user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email")); user.setRole(rs.getString("role"));
                    // Invalidate old session before creating a new one (prevents session fixation)
                    req.getSession().invalidate();
                    req.getSession(true).setAttribute("user", user);
                    res.sendRedirect("home");
                    return;
                }
            }
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");
        String role = req.getParameter("role") != null ? req.getParameter("role") : "customer";
        String hashedPassword = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (name, email, password, phone, role) VALUES (?,?,?,?,?)");
            ps.setString(1, name); ps.setString(2, email); ps.setString(3, hashedPassword);
            ps.setString(4, phone); ps.setString(5, role);
            ps.executeUpdate();
            res.sendRedirect("login.jsp?registered=true");
        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("UNIQUE")) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/register.jsp").forward(req, res); return;
            }
            throw new ServletException(e);
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse res) throws IOException {
        req.getSession().invalidate();
        res.sendRedirect("home");
    }
}
