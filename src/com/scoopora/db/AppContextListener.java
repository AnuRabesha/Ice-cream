package com.scoopora.db;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class AppContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        DBInit.init();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}
