<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User navUser = (User) session.getAttribute("user");
    String currentPage = request.getServletPath();
    String navDisplayName = "";
    if (navUser != null && navUser.getName() != null) {
        String firstName = navUser.getName().split(" ")[0];
        navDisplayName = firstName.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#x27;");
    }
%>
<nav class="navbar">
  <div class="nav-inner">
    <a href="${pageContext.request.contextPath}/home" class="nav-logo">
      <span class="logo-icon">🍦</span>
      <span>Scoopora</span>
    </a>

    <ul class="nav-links" id="navLinks">
      <li><a href="${pageContext.request.contextPath}/home"   class="<%= "/home".equals(currentPage) ? "active" : "" %>">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/shops"  class="<%= "/shops".equals(currentPage) ? "active" : "" %>">Explore Shops</a></li>
      <li><a href="${pageContext.request.contextPath}/flavours" class="<%= "/flavours".equals(currentPage) ? "active" : "" %>">Ice Cream Varieties</a></li>
      <li><a href="${pageContext.request.contextPath}/cakes" class="<%= "/cakes".equals(currentPage) ? "active" : "" %>">Ice Cream Cakes</a></li>
      <li><a href="${pageContext.request.contextPath}/mood" class="<%= "/mood".equals(currentPage) ? "active" : "" %>" style="color:var(--pink-d);font-weight:700">✨ Mood Finder</a></li>
      <li><a href="${pageContext.request.contextPath}/shops">Reviews</a></li>
      <li><a href="${pageContext.request.contextPath}/bulk">Bulk Orders</a></li>
      <% if (navUser != null) { %>
      <li><a href="${pageContext.request.contextPath}/orders">My Orders</a></li>
      <% if ("business".equals(navUser.getRole()) || "admin".equals(navUser.getRole())) { %>
      <li><a href="${pageContext.request.contextPath}/inventory" style="color:var(--purple-d);font-weight:700">📦 Inventory</a></li>
      <% } %>
      <% } %>
    </ul>

    <div class="nav-actions">
      <form class="nav-search" action="${pageContext.request.contextPath}/search" method="get">
        <input type="text" name="q" placeholder="Search shops, flavours…" />
        <button type="submit">🔍</button>
      </form>

      <% if (navUser != null) { %>
        <form action="${pageContext.request.contextPath}/cart" method="get" style="display:inline">
          <button class="btn-cart" type="submit" title="Cart">🛒
            <span class="cart-badge" id="cartBadge">0</span>
          </button>
        </form>
        <form action="${pageContext.request.contextPath}/auth" method="post" style="display:inline">
          <input type="hidden" name="action" value="logout"/>
          <button class="btn-login" type="submit">👋 <%= navDisplayName %></button>
        </form>
      <% } else { %>
        <a href="${pageContext.request.contextPath}/login.jsp">
          <button class="btn-login">Login / Sign Up</button>
        </a>
      <% } %>
    </div>

    <button class="hamburger" onclick="document.getElementById('navLinks').classList.toggle('open')">☰</button>
  </div>
</nav>
