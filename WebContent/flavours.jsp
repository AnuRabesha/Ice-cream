<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Ice Cream Varieties – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    .flavours-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 1.5rem;
    }
    .flavour-card {
      background: var(--white); border-radius: var(--radius);
      box-shadow: var(--shadow); padding: 1.5rem 1rem;
      text-align: center; transition: var(--transition); cursor: default;
    }
    .flavour-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-h); }
    .flavour-icon { font-size: 3rem; margin-bottom: 0.6rem; }
    .flavour-name { font-size: 1rem; font-weight: 700; color: var(--choco); margin-bottom: 0.3rem; }
    .flavour-desc { font-size: 0.8rem; color: var(--gray); }
    .flavour-cat  {
      display: inline-block; margin-top: 0.6rem;
      background: var(--lavender); color: var(--purple-d);
      font-size: 0.72rem; font-weight: 700; padding: 0.2rem 0.7rem;
      border-radius: 10px; text-transform: capitalize;
    }
    .trending-badge {
      display: inline-block; background: var(--pink-d); color: #fff;
      font-size: 0.68rem; font-weight: 700; padding: 0.15rem 0.5rem;
      border-radius: 8px; margin-left: 0.4rem;
    }
  </style>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero">
  <h1>🍨 Ice Cream Varieties</h1>
  <p>Explore all the amazing flavours available across Scoopora shops</p>
</div>

<div class="shops-filters">
  <div class="shops-filters-inner">
    <a href="${pageContext.request.contextPath}/flavours" class="filter-btn ${empty categoryFilter ? 'active' : ''}">All</a>
    <a href="${pageContext.request.contextPath}/flavours?category=chocolate" class="filter-btn ${'chocolate' eq categoryFilter ? 'active' : ''}">🍫 Chocolate</a>
    <a href="${pageContext.request.contextPath}/flavours?category=fruit"     class="filter-btn ${'fruit'     eq categoryFilter ? 'active' : ''}">🍓 Fruit</a>
    <a href="${pageContext.request.contextPath}/flavours?category=nut"       class="filter-btn ${'nut'       eq categoryFilter ? 'active' : ''}">🥜 Nut</a>
    <a href="${pageContext.request.contextPath}/flavours?category=exotic"    class="filter-btn ${'exotic'    eq categoryFilter ? 'active' : ''}">🌸 Exotic</a>
    <a href="${pageContext.request.contextPath}/flavours?category=caramel"   class="filter-btn ${'caramel'   eq categoryFilter ? 'active' : ''}">🍮 Caramel</a>
    <a href="${pageContext.request.contextPath}/flavours?category=classic"   class="filter-btn ${'classic'   eq categoryFilter ? 'active' : ''}">🍦 Classic</a>
    <a href="${pageContext.request.contextPath}/flavours?category=fun"       class="filter-btn ${'fun'       eq categoryFilter ? 'active' : ''}">🎉 Fun</a>
  </div>
</div>

<section class="section">
  <div class="section-inner">
    <c:choose>
      <c:when test="${empty flavours}">
        <div class="empty-state">
          <div style="font-size:3rem">🍦</div>
          <h2>No flavours found</h2>
          <p>Try a different category filter.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="flavours-grid">
          <c:forEach var="f" items="${flavours}">
            <div class="flavour-card">
              <div class="flavour-icon">
                <c:choose>
                  <c:when test="${f.category == 'chocolate'}">🍫</c:when>
                  <c:when test="${f.category == 'fruit'}">🍓</c:when>
                  <c:when test="${f.category == 'nut'}">🥜</c:when>
                  <c:when test="${f.category == 'exotic'}">🌸</c:when>
                  <c:when test="${f.category == 'caramel'}">🍮</c:when>
                  <c:when test="${f.category == 'fun'}">🎉</c:when>
                  <c:otherwise>🍦</c:otherwise>
                </c:choose>
              </div>
              <div class="flavour-name">${f.name}</div>
              <div class="flavour-desc">${f.description}</div>
              <span class="flavour-cat">${f.category}</span>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</section>

<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
