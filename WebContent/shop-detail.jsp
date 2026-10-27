<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${shop.name} – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<%@ include file="navbar.jsp" %>

<!-- ── Shop Hero Banner ── -->
<div class="shop-detail-hero">
  <div class="shop-detail-hero-inner">
    <div class="shop-logo-wrap">🍦</div>
    <div class="shop-hero-info">
      <div class="shop-hero-name"><c:out value="${shop.name}"/></div>
      <div class="shop-hero-city">📍 <c:out value="${shop.address}"/>, <c:out value="${shop.city}"/></div>
      <div class="shop-hero-desc"><c:out value="${shop.description}"/></div>
      <div class="shop-hero-badges">
        <span class="hero-badge">⭐ ${shop.rating} Rating</span>
        <c:if test="${shop.homeDelivery}">
          <span class="hero-badge">🛵 Home Delivery</span>
          <span class="hero-badge">⏱ ${shop.deliveryTime}</span>
        </c:if>
        <c:if test="${not shop.homeDelivery}">
          <span class="hero-badge">🚶 Dine-in Only</span>
        </c:if>
        <span class="hero-badge">📦 ${fn:length(products)} Items</span>
      </div>
    </div>
  </div>
</div>

<!-- ── Body ── -->
<div class="shop-detail-body">
  <div class="shop-detail-grid">

    <!-- LEFT: Products + Reviews -->
    <div>

      <!-- Products Section -->
      <div class="products-section">
        <div class="section-header" style="margin-bottom:1rem">
          <div>
            <div class="section-title">Our <span>Menu</span></div>
            <div class="section-subtitle">${fn:length(products)} items available</div>
          </div>
        </div>

        <!-- Category Filter Tabs -->
        <div class="products-filter" id="catFilter">
          <button class="filter-btn active" data-cat="all">All</button>
          <button class="filter-btn" data-cat="scoop">Scoops</button>
          <button class="filter-btn" data-cat="cone">Cones</button>
          <button class="filter-btn" data-cat="cup">Cups</button>
          <button class="filter-btn" data-cat="combo">Combos</button>
          <button class="filter-btn" data-cat="bulk">Bulk</button>
        </div>

        <div class="products-grid" id="productsGrid">
          <c:forEach var="p" items="${products}">
            <div class="product-card" data-cat="${p.category}">
              <div class="product-img-placeholder">
                <c:choose>
                  <c:when test="${p.category == 'scoop'}">🍨</c:when>
                  <c:when test="${p.category == 'cone'}">🍦</c:when>
                  <c:when test="${p.category == 'cup'}">🍧</c:when>
                  <c:when test="${p.category == 'cake'}">🎂</c:when>
                  <c:when test="${p.category == 'combo'}">🎁</c:when>
                  <c:otherwise>📦</c:otherwise>
                </c:choose>
              </div>

              <c:if test="${p.bestseller}">
                <span class="bestseller-tag">⭐ Bestseller</span>
              </c:if>
              <c:if test="${p.stock == 0}">
                <span class="out-of-stock-tag">Out of Stock</span>
              </c:if>

              <div class="product-body">
                <div class="product-name"><c:out value="${p.name}"/></div>
                <div class="product-desc"><c:out value="${p.description}"/>
                <div style="font-size:0.75rem;color:var(--gray);margin-bottom:0.6rem">
                  <c:choose>
                    <c:when test="${p.stock == 0}">
                      <span style="color:#c62828;font-weight:700">📦 Out of Stock</span>
                    </c:when>
                    <c:when test="${p.stock <= 10}">
                      <span style="color:#e65100;font-weight:700">⚠️ Only ${p.stock} left!</span>
                    </c:when>
                    <c:otherwise>
                      <span>📦 ${p.stock} in stock</span>
                    </c:otherwise>
                  </c:choose>
                  &nbsp;|&nbsp;
                  🏷 <span style="text-transform:capitalize">${p.category}</span>
                </div>
                <div class="product-footer">
                  <span class="product-price">₹${p.price}</span>
                  <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                    <input type="hidden" name="action" value="add"/>
                    <input type="hidden" name="productId" value="${p.id}"/>
                    <button class="btn-add-cart" type="submit"
                      <c:if test="${p.stock == 0}">disabled</c:if>>
                      <c:choose>
                        <c:when test="${p.stock == 0}">Sold Out</c:when>
                        <c:otherwise>+ Add</c:otherwise>
                      </c:choose>
                    </button>
                  </form>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>

        <c:if test="${empty products}">
          <div style="text-align:center;padding:3rem;color:var(--gray)">
            <div style="font-size:3rem">🍦</div>
            <p>No products listed yet for this shop.</p>
          </div>
        </c:if>
      </div>

      <!-- Reviews Section -->
      <div class="reviews-section">
        <div class="section-header" style="margin-bottom:1rem">
          <div>
            <div class="section-title">Customer <span>Reviews</span></div>
            <c:if test="${avgRating > 0}">
              <div class="section-subtitle">
                Average rating:
                <strong style="color:var(--purple-d)">
                  <fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/> / 5
                </strong>
                &nbsp;(${fn:length(reviews)} review<c:if test="${fn:length(reviews) != 1}">s</c:if>)
              </div>
            </c:if>
          </div>
        </div>

        <!-- Submit Review Form -->
        <c:choose>
          <c:when test="${not empty sessionScope.user}">
            <div class="review-form-card">
              <h3>✍️ Write a Review</h3>
              <form action="${pageContext.request.contextPath}/reviews" method="post">
                <input type="hidden" name="action" value="submit"/>
                <input type="hidden" name="shopId" value="${shop.id}"/>
                <div class="star-picker" id="starPicker">
                  <span data-val="1">★</span><span data-val="2">★</span>
                  <span data-val="3">★</span><span data-val="4">★</span>
                  <span data-val="5">★</span>
                </div>
                <input type="hidden" name="rating" id="ratingInput" value="5"/>
                <textarea name="comment" placeholder="Share your experience…" required></textarea>
                <br/><br/>
                <button class="btn btn-primary btn-sm" type="submit">Submit Review</button>
              </form>
            </div>
          </c:when>
          <c:otherwise>
            <div style="background:var(--lavender);border-radius:var(--radius);padding:1rem;margin-bottom:1.5rem;text-align:center">
              <a href="${pageContext.request.contextPath}/login.jsp" style="color:var(--purple-d);font-weight:700">
                Login to write a review
              </a>
            </div>
          </c:otherwise>
        </c:choose>

        <!-- Review Cards -->
        <c:choose>
          <c:when test="${empty reviews}">
            <div style="text-align:center;padding:2rem;color:var(--gray)">
              <p>No reviews yet. Be the first to review!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="rev" items="${reviews}">
              <div class="review-card">
                <div class="review-header">
                  <div>
                    <div class="reviewer-name">👤 <c:out value="${rev.userName}"/></div>
                    <div class="review-stars">
                      <c:forEach begin="1" end="${rev.rating}" var="s">★</c:forEach>
                      <c:forEach begin="${rev.rating + 1}" end="5" var="s">☆</c:forEach>
                      <span style="font-size:0.8rem;color:var(--gray);margin-left:0.3rem">${rev.rating}/5</span>
                    </div>
                  </div>
                  <div class="review-date">${rev.createdAt}</div>
                </div>
                <div class="review-comment">"<c:out value="${rev.comment}"/>"</div>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </div><!-- end left col -->

    <!-- RIGHT: Info Sidebar -->
    <div>
      <div class="shop-info-card">
        <div style="font-size:1rem;font-weight:800;color:var(--choco);margin-bottom:1rem">
          📋 Shop Information
        </div>

        <div class="info-row">
          <span class="info-icon">📍</span>
          <div>
            <div class="info-label">Address</div>
            <div class="info-value">${shop.address}, ${shop.city}</div>
            <c:if test="${not empty shop.mapsUrl}">
              <a href="${shop.mapsUrl}" target="_blank" class="maps-btn">
                🗺 Get Directions
              </a>
            </c:if>
          </div>
        </div>

        <div class="info-row">
          <span class="info-icon">🕐</span>
          <div>
            <div class="info-label">Opening Hours</div>
            <div class="info-value">${shop.openingHours}</div>
          </div>
        </div>

        <c:if test="${not empty shop.phone}">
          <div class="info-row">
            <span class="info-icon">📞</span>
            <div>
              <div class="info-label">Phone</div>
              <div class="info-value">
                <a href="tel:${shop.phone}">${shop.phone}</a>
              </div>
            </div>
          </div>
        </c:if>

        <c:if test="${not empty shop.email}">
          <div class="info-row">
            <span class="info-icon">✉️</span>
            <div>
              <div class="info-label">Email</div>
              <div class="info-value">
                <a href="mailto:${shop.email}">${shop.email}</a>
              </div>
            </div>
          </div>
        </c:if>

        <div class="info-row">
          <span class="info-icon">🛵</span>
          <div>
            <div class="info-label">Home Delivery</div>
            <div class="info-value">
              <c:choose>
                <c:when test="${shop.homeDelivery}">
                  <span style="color:#2e7d32;font-weight:700">✅ Available</span>
                </c:when>
                <c:otherwise>
                  <span style="color:#c62828;font-weight:700">❌ Not Available</span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <c:if test="${shop.homeDelivery}">
          <div class="info-row">
            <span class="info-icon">💰</span>
            <div>
              <div class="info-label">Delivery Fee</div>
              <div class="info-value">₹<fmt:formatNumber value="${shop.deliveryFee}" maxFractionDigits="0"/></div>
            </div>
          </div>
          <div class="info-row">
            <span class="info-icon">🛒</span>
            <div>
              <div class="info-label">Minimum Order</div>
              <div class="info-value">₹<fmt:formatNumber value="${shop.minOrder}" maxFractionDigits="0"/></div>
            </div>
          </div>
          <div class="info-row">
            <span class="info-icon">⏱</span>
            <div>
              <div class="info-label">Estimated Delivery</div>
              <div class="info-value">${shop.deliveryTime}</div>
            </div>
          </div>
        </c:if>

        <div class="info-row">
          <span class="info-icon">⭐</span>
          <div>
            <div class="info-label">Overall Rating</div>
            <div class="info-value" style="font-size:1.1rem;font-weight:800;color:var(--purple-d)">
              ${shop.rating} / 5.0
              <span style="color:#FFB800;font-size:1rem">
                <c:forEach begin="1" end="5" var="i">
                  <c:choose>
                    <c:when test="${i <= shop.rating}">★</c:when>
                    <c:otherwise>☆</c:otherwise>
                  </c:choose>
                </c:forEach>
              </span>
            </div>
          </div>
        </div>

        <div style="margin-top:1rem">
          <a href="${pageContext.request.contextPath}/shops" class="btn btn-outline" style="width:100%;justify-content:center">
            ← Back to All Shops
          </a>
        </div>
      </div>
    </div><!-- end right col -->

  </div>
</div>

<div class="toast" id="toast"></div>

<%@ include file="footer.jsp" %>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
// Category filter tabs
document.querySelectorAll('#catFilter .filter-btn').forEach(btn => {
  btn.addEventListener('click', function() {
    document.querySelectorAll('#catFilter .filter-btn').forEach(b => b.classList.remove('active'));
    this.classList.add('active');
    const cat = this.dataset.cat;
    document.querySelectorAll('#productsGrid .product-card').forEach(card => {
      card.style.display = (cat === 'all' || card.dataset.cat === cat) ? '' : 'none';
    });
  });
});

// Star picker
const stars = document.querySelectorAll('#starPicker span');
const ratingInput = document.getElementById('ratingInput');
if (stars.length) {
  stars.forEach(s => {
    s.addEventListener('mouseover', function() {
      const v = +this.dataset.val;
      stars.forEach(x => x.classList.toggle('active', +x.dataset.val <= v));
    });
    s.addEventListener('click', function() {
      ratingInput.value = this.dataset.val;
    });
  });
  document.getElementById('starPicker').addEventListener('mouseleave', function() {
    const cur = +ratingInput.value;
    stars.forEach(x => x.classList.toggle('active', +x.dataset.val <= cur));
  });
  // init highlight
  stars.forEach(x => x.classList.toggle('active', +x.dataset.val <= 5));
}
</script>
</body>
</html>
