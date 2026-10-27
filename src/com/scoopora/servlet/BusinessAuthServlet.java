package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.BusinessAccount;
import at.favre.lib.crypto.bcrypt.BCrypt;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/business/auth")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class BusinessAuthServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        switch (action == null ? "" : action) {
            case "register":  handleRegister(req, res); break;
            case "login":     handleLogin(req, res);    break;
            case "logout":    handleLogout(req, res);   break;
            case "profile":   handleProfile(req, res);  break;
            default: res.sendRedirect(req.getContextPath() + "/business-login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/business-login.jsp");
    }

    // ── Register ──────────────────────────────────────────────────────────────
    private void handleRegister(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String contactName  = req.getParameter("contact_name");
        String email        = req.getParameter("email");
        String rawPassword  = req.getParameter("password");
        String phone        = req.getParameter("phone");
        String businessName = req.getParameter("business_name");
        String businessType = req.getParameter("business_type");
        String address      = req.getParameter("address");
        String city         = req.getParameter("city");
        String state        = req.getParameter("state");
        String pincode      = req.getParameter("pincode");
        String gst          = req.getParameter("gst_number");
        String pan          = req.getParameter("pan_number");
        String website      = req.getParameter("website");
        String description  = req.getParameter("description");

        String hashedPassword = BCrypt.withDefaults().hashToString(12, rawPassword.toCharArray());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO business_accounts (contact_name,email,password,phone,business_name,business_type," +
                "address,city,state,pincode,gst_number,pan_number,website,description) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            ps.setString(1, contactName); ps.setString(2, email);        ps.setString(3, hashedPassword);
            ps.setString(4, phone);       ps.setString(5, businessName); ps.setString(6, businessType);
            ps.setString(7, address);     ps.setString(8, city);         ps.setString(9, state);
            ps.setString(10, pincode);    ps.setString(11, gst);         ps.setString(12, pan);
            ps.setString(13, website);    ps.setString(14, description);
            ps.executeUpdate();
            res.sendRedirect(req.getContextPath() + "/business-login.jsp?registered=true");
        } catch (SQLIntegrityConstraintViolationException e) {
            req.setAttribute("error", "Email already registered.");
            req.getRequestDispatcher("/business-register.jsp").forward(req, res);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String email       = req.getParameter("email");
        String rawPassword = req.getParameter("password");
        if (email == null || rawPassword == null) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/business-login.jsp").forward(req, res);
            return;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM business_accounts WHERE email=? AND is_active=1")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    BCrypt.Result result = BCrypt.verifyer().verify(rawPassword.toCharArray(), storedHash);
                    if (result.verified) {
                        // Invalidate old session before creating a new one (prevents session fixation)
                        req.getSession().invalidate();
                        req.getSession(true).setAttribute("businessAccount", mapRow(rs));
                        res.sendRedirect(req.getContextPath() + "/business/dashboard");
                        return;
                    }
                }
            }
            req.setAttribute("error", "Invalid credentials or account inactive.");
            req.getRequestDispatcher("/business-login.jsp").forward(req, res);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ── Logout ────────────────────────────────────────────────────────────────
    private void handleLogout(HttpServletRequest req, HttpServletResponse res) throws IOException {
        req.getSession().invalidate();
        res.sendRedirect(req.getContextPath() + "/business-login.jsp");
    }

    // ── Update Profile / Logo ─────────────────────────────────────────────────
    private void handleProfile(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        BusinessAccount ba = (BusinessAccount) req.getSession().getAttribute("businessAccount");
        if (ba == null) { res.sendRedirect(req.getContextPath() + "/business-login.jsp"); return; }

        String businessName  = req.getParameter("business_name");
        String phone         = req.getParameter("phone");
        String address       = req.getParameter("address");
        String city          = req.getParameter("city");
        String state         = req.getParameter("state");
        String pincode       = req.getParameter("pincode");
        String website       = req.getParameter("website");
        String description   = req.getParameter("description");
        String deliveryAreas = req.getParameter("delivery_areas");
        String deliveryTime  = req.getParameter("delivery_time");

        String logoUrl = ba.getLogoUrl();
        Part logoPart = req.getPart("logo");
        if (logoPart != null && logoPart.getSize() > 0) {
            String uploadDir = getServletContext().getRealPath("/images/business/");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            String fileName = "logo_" + ba.getId() + "_" + System.currentTimeMillis() + ".jpg";
            logoPart.write(uploadDir + File.separator + fileName);
            logoUrl = "images/business/" + fileName;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE business_accounts SET business_name=?,phone=?,address=?,city=?,state=?,pincode=?," +
                "website=?,description=?,delivery_areas=?,delivery_time=?,logo_url=? WHERE id=?")) {
            ps.setString(1, businessName); ps.setString(2, phone);        ps.setString(3, address);
            ps.setString(4, city);         ps.setString(5, state);        ps.setString(6, pincode);
            ps.setString(7, website);      ps.setString(8, description);
            ps.setString(9, deliveryAreas); ps.setString(10, deliveryTime);
            ps.setString(11, logoUrl);     ps.setInt(12, ba.getId());
            ps.executeUpdate();

            try (PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM business_accounts WHERE id=?")) {
                ps2.setInt(1, ba.getId());
                try (ResultSet rs = ps2.executeQuery()) {
                    if (rs.next()) req.getSession().setAttribute("businessAccount", mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        res.sendRedirect(req.getContextPath() + "/business/dashboard?tab=profile&saved=true");
    }

    // ── Helper ────────────────────────────────────────────────────────────────
    static BusinessAccount mapRow(ResultSet rs) throws SQLException {
        BusinessAccount ba = new BusinessAccount();
        ba.setId(rs.getInt("id"));
        ba.setContactName(rs.getString("contact_name"));
        ba.setEmail(rs.getString("email"));
        ba.setPhone(rs.getString("phone"));
        ba.setBusinessName(rs.getString("business_name"));
        ba.setBusinessType(rs.getString("business_type"));
        ba.setLogoUrl(rs.getString("logo_url"));
        ba.setAddress(rs.getString("address"));
        ba.setCity(rs.getString("city"));
        ba.setState(rs.getString("state"));
        ba.setPincode(rs.getString("pincode"));
        ba.setGstNumber(rs.getString("gst_number"));
        ba.setPanNumber(rs.getString("pan_number"));
        ba.setWebsite(rs.getString("website"));
        ba.setDescription(rs.getString("description"));
        ba.setDeliveryAreas(rs.getString("delivery_areas"));
        ba.setDeliveryTime(rs.getString("delivery_time"));
        ba.setVerificationStatus(rs.getString("verification_status"));
        ba.setVerificationNotes(rs.getString("verification_notes"));
        ba.setActive(rs.getInt("is_active") == 1);
        return ba;
    }
}
