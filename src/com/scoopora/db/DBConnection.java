package com.scoopora.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:sqlite:" +
        System.getProperty("user.home") + "/scoopora.db";

    static {
        try {
            Class.forName("org.sqlite.JDBC");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("SQLite JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(URL);
        // Enable foreign key enforcement (SQLite requires this per connection)
        conn.createStatement().execute("PRAGMA foreign_keys = ON");
        return conn;
    }
}
