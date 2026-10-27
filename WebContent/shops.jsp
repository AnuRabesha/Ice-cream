<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.Shop, java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Explore Ice Cream Shops – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<%@ include file="navbar.jsp" %>

<!-- Page Hero -->
<div class="page-hero">
  <h1>🍦 Explore Ice Cream Shops</h1>
  <p>Discover the best ice cream parlours near you — rated, reviewed, and ready to scoop!</p>
</div>

<!-- Filters Bar -->
<div class="shops-filters">
  <div class="shops-filters-inner">
    <form method="get" action="${pageContext.request.contextPath}/shops"
          style="display:flex;gap:0.8rem;align-items:center;flex-wrap:wrap;width:100%">

      <label style="font-size:0.85rem;font-weight:600;color:var(--choco)">Filter by City:</label>
      <select name="city" class="filter-select" onchange="this.form.submit()">
        <option value="">All Cities</option>
        <c:forEach var="c" items="${cities}">
          <option value="${c}" <c:if test="${c == cityFilter}">selected</c:if>>${c}</option>
        </c:forEach>
      </select>

      <label style="font-size:0.85rem;font-weight:600;color:var(--choco)">Sort by:</label>
      <select name="sort" class="filter-select" onchange="this.form.submit()">
        <option value=""       <c:if test="${empty sortFilter}">selected</c:if>>Featured</option>
        <option value="rating" <c:if test="${sortFilter=='rating'}">selected</c:if>>Top Rated</option>
        <option value="name"   <c:if test="${sortFilter=='name'}">selected</c:if>>Name A–Z</option>
      </select>

      <c:if test="${not empty cityFilter}">
        <input type="hidden" name="city" value="${cityFilter}"/>
      </c:if>

      <span class="results-count">${totalShops} shop<c:if test="${totalShops != 1}">s</c:if> found</span>
    </form>
  </div>
</div>

<!-- Shops Grid -->
<div class="section">
  <div class="section-inner">

    <c:choose>
      <c:when test="${empty shops}">
        <div style="text-align:center;padding:4rem 0;color:var(--gray)">
          <div style="font-size:4rem;margin-bottom:1rem">🍦</div>
          <h3>No shops found</h3>
          <p>Try a different city or clear the filter.</p>
          <a href="${pageContext.request.contextPath}/shops" class="btn btn-primary" style="margin-top:1rem">View All Shops</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="shops-listing-grid">
          <c:forEach var="shop" items="${shops}">
            <a href="${pageContext.request.contextPath}/shops?id=${shop.id}" style="display:contents">
              <div class="shop-card">
                <!-- Shop Image -->
                <div class="shop-card-img-placeholder">🍦</div>

                <div class="shop-card-body">
                  <div class="shop-card-name">${shop.name}</div>
                  <div class="shop-card-city">📍 ${shop.address}, ${shop.city}</div>
                  <div class="shop-card-desc">${shop.description}</div>

                  <!-- Opening hours preview -->
                  <div style="font-size:0.78rem;color:var(--gray);margin-bottom:0.4rem">
                    🕐 ${shop.openingHours}
                  </div>
                </div>

                <div class="shop-card-footer">
                  <div class="star-rating">
                    <span class="stars">
                      <c:set var="r" value="${shop.rating}"/>
                      <c:forEach begin="1" end="5" var="i">
                        <c:choose>
                          <c:when test="${i <= r}">★</c:when>
                          <c:otherwise>☆</c:otherwise>
                        </c:choose>
                      </c:forEach>
                    </span>
                    <span class="rating-val">${shop.rating}</span>
                  </div>

                  <c:choose>
                    <c:when test="${shop.homeDelivery}">
                      <span class="delivery-badge badge-delivery">🛵 Delivery ${shop.deliveryTime}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="delivery-badge badge-no-delivery">🚶 Dine-in Only</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </a>
          </c:forEach>
        </div>

        <!-- Pagination -->
        <c:set var="totalPages" value="${(totalShops + pageSize - 1) / pageSize}"/>
        <c:if test="${totalPages > 1}">
          <div class="pagination">
            <c:forEach begin="1" end="${totalPages}" var="p">
              <a href="${pageContext.request.contextPath}/shops?page=${p}<c:if test="${not empty cityFilter}">&city=${cityFilter}</c:if><c:if test="${not empty sortFilter}">&sort=${sortFilter}</c:if>">
                <button class="page-btn <c:if test="${p == currentPage}">active</c:if>">${p}</button>
              </a>
            </c:forEach>
          </div>
        </c:if>
      </c:otherwise>
    </c:choose>

  </div>
</div>

<!-- Toast -->
<div class="toast" id="toast"></div>

<%@ include file="footer.jsp" %>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
