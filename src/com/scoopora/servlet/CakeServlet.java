package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.CakeDesign;
import com.scoopora.model.Shop;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/cakes")
public class CakeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");

        // JSON pricing API called by JS
        if ("price".equals(action)) {
            handlePriceCalc(req, res);
            return;
        }

        String idParam = req.getParameter("id");
        String typeFilter = req.getParameter("type");

        try (Connection conn = DBConnection.getConnection()) {
            if (idParam != null) {
                // Single cake detail for customization studio
                CakeDesign cake = getCakeById(conn, Integer.parseInt(idParam));
                if (cake == null) { res.sendError(404); return; }
                req.setAttribute("cake", cake);
                req.setAttribute("shops", getAllShops(conn));
                req.getRequestDispatcher("/cake-customize.jsp").forward(req, res);
            } else {
                // Gallery page
                req.setAttribute("cakes",       getAllCakes(conn, typeFilter));
                req.setAttribute("typeFilter",  typeFilter);
                req.setAttribute("cakeTypes",   getCakeTypes());
                req.getRequestDispatcher("/cakes.jsp").forward(req, res);
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    // ── Price calculation API ─────────────────────────────────────────────────
    private void handlePriceCalc(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json");
        try {
            int designId   = Integer.parseInt(req.getParameter("designId"));
            String size    = req.getParameter("size");       // e.g. "1kg"
            int toppingCnt = Integer.parseInt(req.getParameter("toppings"));
            boolean photo  = "true".equals(req.getParameter("photo"));
            int qty        = Integer.parseInt(req.getParameter("qty"));

            double price;
            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT available_sizes, base_price FROM cake_designs WHERE id=?");
                ps.setInt(1, designId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { res.getWriter().write("{\"price\":0}"); return; }

                String sizesStr = rs.getString("available_sizes");
                price = rs.getDouble("base_price");

                // Find size price from "0.5kg:500,1kg:850,..." string
                if (sizesStr != null && size != null) {
                    for (String entry : sizesStr.split(",")) {
                        String[] parts = entry.trim().split(":");
                        if (parts.length == 2 && parts[0].trim().equalsIgnoreCase(size.trim())) {
                            price = Double.parseDouble(parts[1].trim());
                            break;
                        }
                    }
                }
            }

            // Add-ons
            price += toppingCnt * 50.0;   // ₹50 per extra topping
            if (photo) price += 200.0;    // ₹200 for photo print
            price *= qty;

            res.getWriter().write("{\"price\":" + price + "}");
        } catch (Exception e) {
            res.getWriter().write("{\"price\":0,\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // ── DB helpers ────────────────────────────────────────────────────────────
    private CakeDesign mapCake(ResultSet rs) throws SQLException {
        CakeDesign c = new CakeDesign();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setCakeType(rs.getString("cake_type"));
        c.setDescription(rs.getString("description"));
        c.setBaseFlavour(rs.getString("base_flavour"));
        c.setAvailableFlavours(rs.getString("available_flavours"));
        c.setLayers(rs.getInt("layers"));
        c.setAvailableSizes(rs.getString("available_sizes"));
        c.setAvailableShapes(rs.getString("available_shapes"));
        c.setAvailableColours(rs.getString("available_colours"));
        c.setAvailableToppings(rs.getString("available_toppings"));
        c.setBasePrice(rs.getDouble("base_price"));
        c.setPrice(rs.getDouble("price"));
        c.setImageUrl(rs.getString("image_url"));
        c.setShopId(rs.getInt("shop_id"));
        c.setSupportsPhoto(rs.getInt("supports_photo") == 1);
        c.setCustom(rs.getInt("is_custom") == 1);
        c.setFeatured(rs.getInt("is_featured") == 1);
        return c;
    }

    private List<CakeDesign> getAllCakes(Connection conn, String type) throws SQLException {
        String sql = "SELECT * FROM cake_designs";
        if (type != null && !type.isEmpty()) sql += " WHERE cake_type=?";
        sql += " ORDER BY is_featured DESC, base_price ASC";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (type != null && !type.isEmpty()) ps.setString(1, type);
        ResultSet rs = ps.executeQuery();
        List<CakeDesign> list = new ArrayList<>();
        while (rs.next()) list.add(mapCake(rs));
        return list;
    }

    private CakeDesign getCakeById(Connection conn, int id) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM cake_designs WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        return rs.next() ? mapCake(rs) : null;
    }

    private List<Shop> getAllShops(Connection conn) throws SQLException {
        List<Shop> list = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT id, name, city FROM shops ORDER BY name");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Shop s = new Shop();
            s.setId(rs.getInt("id")); s.setName(rs.getString("name")); s.setCity(rs.getString("city"));
            list.add(s);
        }
        return list;
    }

    private List<Map<String, String>> getCakeTypes() {
        List<Map<String, String>> types = new ArrayList<>();
        String[][] data = {
            {"birthday","🎂 Birthday"},{"wedding","💍 Wedding"},{"photo","📸 Photo"},
            {"chocolate","🍫 Chocolate"},{"cartoon","🦄 Cartoon & Theme"},
            {"heart","❤️ Heart-Shaped"},{"anniversary","🥂 Anniversary"},
            {"designer","✨ Designer"},{"custom","🎨 Custom"}
        };
        for (String[] d : data) {
            Map<String, String> m = new LinkedHashMap<>();
            m.put("value", d[0]); m.put("label", d[1]);
            types.add(m);
        }
        return types;
    }
}
