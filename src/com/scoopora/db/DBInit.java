package com.scoopora.db;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;

public class DBInit {

    public static void init() {
        String dbPath = System.getProperty("user.home") + "/scoopora.db";
        File dbFile = new File(dbPath);
        if (dbFile.exists()) return; // already initialized

        System.out.println("[DBInit] Creating SQLite database...");
        try (Connection conn = DBConnection.getConnection()) {
            conn.createStatement().execute("PRAGMA foreign_keys = ON");
            InputStream is = DBInit.class.getClassLoader().getResourceAsStream("schema_sqlite.sql");
            if (is == null) throw new RuntimeException("schema_sqlite.sql not found on classpath");
            String sql = new String(is.readAllBytes(), StandardCharsets.UTF_8);
            // Split on semicolons and execute each statement
            for (String stmt : sql.split(";")) {
                String s = stmt.trim();
                if (!s.isEmpty() && !s.startsWith("--")) {
                    conn.createStatement().execute(s);
                }
            }
            System.out.println("[DBInit] Database initialized successfully.");
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize SQLite database", e);
        }
    }
}
