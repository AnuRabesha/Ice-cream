package com.scoopora.servlet;

import com.scoopora.db.DBConnection;
import com.scoopora.model.Product;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/mood")
public class MoodServlet extends HttpServlet {

    // Maps each mood key → DB mood_tags to match + display metadata
    private static final Map<String, String[]> MOOD_MAP = new LinkedHashMap<>();
    static {
        // key → { dbTag, emoji, title, subtitle, gradient }
        MOOD_MAP.put("chocolate",   new String[]{"chocolate",   "🍫", "Chocolate Lover",          "Deep, rich, and indulgent chocolate treats",       "135deg,#5C3317,#8B5E3C"});
        MOOD_MAP.put("fruit",       new String[]{"fruit",       "🍓", "Fruit Lover",              "Fresh, fruity, and bursting with natural flavour",  "135deg,#FF6B9D,#FFB3C6"});
        MOOD_MAP.put("happy",       new String[]{"happy",       "😄", "Feeling Happy",            "Celebrate with our most joyful scoops",             "135deg,#FFD700,#FF6B9D"});
        MOOD_MAP.put("refreshing",  new String[]{"refreshing",  "🌊", "Want Something Refreshing","Cool down with light, refreshing frozen treats",    "135deg,#4A90D9,#00BCD4"});
        MOOD_MAP.put("adventurous", new String[]{"adventurous", "🌍", "Trying Something New",     "Explore bold, unique, and unexpected flavours",     "135deg,#9B59B6,#FF6B9D"});
        MOOD_MAP.put("dessert",     new String[]{"dessert",     "🍰", "Looking for a Dessert",    "Indulgent dessert-style frozen creations",          "135deg,#7D3C98,#FFB3C6"});
        MOOD_MAP.put("dairy-free",  new String[]{"healthy",     "🌱", "Prefer Dairy-Free Options","Light, healthy, and dairy-free frozen treats",      "135deg,#2E7D32,#66BB6A"});
        MOOD_MAP.put("indulgent",   new String[]{"indulgent",   "✨", "Feeling Indulgent",        "Go all out with our most decadent creations",       "135deg,#5C3317,#9B59B6"});
        MOOD_MAP.put("fun",         new String[]{"fun",         "🎉", "Just Want Fun",            "Playful, colourful, and full of surprises",         "135deg,#FF6B9D,#FFD700"});
        MOOD_MAP.put("sharing",     new String[]{"sharing",     "🤝", "Sharing with Friends",     "Perfect combos and packs for groups",               "135deg,#FF6B9D,#7D3C98"});
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        // Build mood list for the picker UI
        List<Map<String, String>> moods = new ArrayList<>();
        for (Map.Entry<String, String[]> e : MOOD_MAP.entrySet()) {
            Map<String, String> m = new LinkedHashMap<>();
            m.put("key",      e.getKey());
            m.put("tag",      e.getValue()[0]);
            m.put("emoji",    e.getValue()[1]);
            m.put("title",    e.getValue()[2]);
            m.put("subtitle", e.getValue()[3]);
            m.put("gradient", e.getValue()[4]);
            moods.add(m);
        }
        req.setAttribute("moods", moods);

        // If a mood was already selected (e.g. back-navigation), pre-load results
        String selectedMood = req.getParameter("mood");
        if (selectedMood != null && MOOD_MAP.containsKey(selectedMood)) {
            try (Connection conn = DBConnection.getConnection()) {
                String tag = MOOD_MAP.get(selectedMood)[0];
                req.setAttribute("recommendations", getRecommendations(conn, tag));
                req.setAttribute("selectedMood",    selectedMood);
                req.setAttribute("moodMeta",        MOOD_MAP.get(selectedMood));
            } catch (SQLException e) { throw new ServletException(e); }
        }

        req.getRequestDispatcher("/mood-finder.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String mood = req.getParameter("mood");
        if (mood == null || !MOOD_MAP.containsKey(mood)) {
            res.sendRedirect("mood"); return;
        }

        String tag = MOOD_MAP.get(mood)[0];
        try (Connection conn = DBConnection.getConnection()) {
            List<Product> recs = getRecommendations(conn, tag);
            req.setAttribute("recommendations", recs);
            req.setAttribute("selectedMood",    mood);
            req.setAttribute("moodMeta",        MOOD_MAP.get(mood));

            // Rebuild mood list for the page
            List<Map<String, String>> moods = new ArrayList<>();
            for (Map.Entry<String, String[]> e : MOOD_MAP.entrySet()) {
                Map<String, String> m = new LinkedHashMap<>();
                m.put("key",      e.getKey());
                m.put("tag",      e.getValue()[0]);
                m.put("emoji",    e.getValue()[1]);
                m.put("title",    e.getValue()[2]);
                m.put("subtitle", e.getValue()[3]);
                m.put("gradient", e.getValue()[4]);
                moods.add(m);
            }
            req.setAttribute("moods", moods);
        } catch (SQLException e) { throw new ServletException(e); }

        req.getRequestDispatcher("/mood-finder.jsp").forward(req, res);
    }

    // ── DB query: match mood tag, only in-stock products, ordered by bestseller then price ──
    private List<Product> getRecommendations(Connection conn, String tag) throws SQLException {
        List<Product> list = new ArrayList<>();
        // SQLite has no FIND_IN_SET; use LIKE to match the tag within the comma-separated mood_tags column
        String tagPattern = "%" + tag + "%";
        PreparedStatement ps = conn.prepareStatement(
            "SELECT p.*, s.name AS shop_name, s.city AS shop_city, " +
            "       f.name AS flavour_name " +
            "FROM products p " +
            "JOIN shops s ON p.shop_id = s.id " +
            "LEFT JOIN flavours f ON p.flavour_id = f.id " +
            "WHERE p.stock > 0 " +
            "  AND p.category != 'bulk' " +
            "  AND p.mood_tags LIKE ? " +
            "ORDER BY p.is_bestseller DESC, p.price ASC " +
            "LIMIT 12");
        ps.setString(1, tagPattern);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Product p = new Product();
            p.setId(rs.getInt("id"));
            p.setName(rs.getString("name"));
            p.setDescription(rs.getString("description"));
            p.setPrice(rs.getDouble("price"));
            p.setCategory(rs.getString("category"));
            p.setImageUrl(rs.getString("image_url"));
            p.setShopName(rs.getString("shop_name") + " · " + rs.getString("shop_city"));
            p.setBestseller(rs.getInt("is_bestseller") == 1);
            p.setStock(rs.getInt("stock"));
            p.setMoodTags(rs.getString("mood_tags"));
            list.add(p);
        }
        return list;
    }
}
