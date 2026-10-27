<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Scoopora – Discover Your Perfect Scoop!</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    /* Hero */
    .hero {
      background: linear-gradient(135deg, #7D3C98 0%, #FF6B9D 60%, #FFB3C6 100%);
      padding: 5rem 2rem 4rem; text-align: center; color: #fff;
      position: relative; overflow: hidden;
    }
    .hero::before {
      content: '🍦🍧🍨🍦🍧🍨🍦🍧';
      position: absolute; top: -10px; left: 0; right: 0;
      font-size: 3rem; opacity: 0.08; letter-spacing: 2rem;
      white-space: nowrap; pointer-events: none;
    }
    .hero h1 { font-size: 3rem; font-weight: 800; margin-bottom: 1rem; line-height: 1.2; }
    .hero p  { font-size: 1.1rem; opacity: 0.92; max-width: 620px; margin: 0 auto 2rem; }
    .hero-btns { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }
    .hero-btns .btn { font-size: 0.95rem; }

    /* Flavour chips */
    .flavour-chips { display: flex; gap: 1rem; flex-wrap: wrap; }
    .flavour-chip {
      background: var(--white); border-radius: var(--radius);
      box-shadow: var(--shadow); padding: 1.2rem 1rem;
      text-align: center; min-width: 130px; flex: 1;
      transition: var(--transition); cursor: pointer;
    }
    .flavour-chip:hover { transform: translateY(-4px); box-shadow: var(--shadow-h); }
    .flavour-chip .chip-icon { font-size: 2.5rem; margin-bottom: 0.4rem; }
    .flavour-chip .chip-name { font-size: 0.85rem; font-weight: 700; color: var(--choco); }
    .flavour-chip .chip-cat  { font-size: 0.72rem; color: var(--gray); text-transform: capitalize; }

    /* Bestseller cards */
    .bestseller-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1.2rem;
    }

    /* Offers banner */
    .offers-banner {
      background: linear-gradient(135deg, var(--choco), var(--choco-l));
      border-radius: var(--radius); padding: 2rem; color: #fff;
      display: flex; align-items: center; justify-content: space-between;
      gap: 1rem; flex-wrap: wrap;
    }
    .offers-banner h3 { font-size: 1.4rem; font-weight: 800; }
    .offers-banner p  { opacity: 0.85; font-size: 0.9rem; margin-top: 0.3rem; }

    /* Partner CTA */
    .partner-cta {
      background: linear-gradient(135deg, var(--purple-d), var(--pink-d));
      border-radius: var(--radius); padding: 3rem 2rem;
      text-align: center; color: #fff;
    }
    .partner-cta h2 { font-size: 1.8rem; font-weight: 800; margin-bottom: 0.5rem; }
    .partner-cta p  { opacity: 0.9; margin-bottom: 1.5rem; }
  </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<!-- ── Hero ── -->
<section class="hero">
  <h1>🍦 Discover Your Perfect Scoop!</h1>
  <p>Explore amazing ice cream shops, discover exciting flavours, customize your dream cake, and order your favourite frozen treats.</p>
  <div class="hero-btns">
    <a href="${pageContext.request.contextPath}/shops">
      <button class="btn btn-primary">🏪 Explore Ice Cream Shops</button>
    </a>
    <a href="${pageContext.request.contextPath}/flavours">
      <button class="btn" style="background:rgba(255,255,255,0.2);color:#fff;border:2px solid rgba(255,255,255,0.6)">🍨 Discover Flavours</button>
    </a>
    <a href="${pageContext.request.contextPath}/cakes">
      <button class="btn" style="background:rgba(255,255,255,0.2);color:#fff;border:2px solid rgba(255,255,255,0.6)">🎂 Design Your Own Cake</button>
    </a>
    <a href="${pageContext.request.contextPath}/bulk">
      <button class="btn btn-choco">📦 Business &amp; Bulk Orders</button>
    </a>
    <a href="${pageContext.request.contextPath}/mood">
      <button class="btn" style="background:rgba(255,255,255,0.15);color:#fff;border:2px solid rgba(255,255,255,0.5)">✨ Find by Mood</button>
    </a>
  </div>
</section>

<!-- ── Popular Shops (2×2 grid, scrollable for more) ── -->
<section class="section" style="background:var(--white)">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <div class="section-title">Popular Ice Cream <span>Shops</span></div>
        <div class="section-subtitle">Top-rated parlours loved by thousands of customers</div>
      </div>
      <a href="${pageContext.request.contextPath}/shops" class="btn btn-outline btn-sm">View All Shops →</a>
    </div>

    <!-- 2-col grid, max-height creates scroll after 2 rows -->
    <div class="shops-scroll-wrap">
      <div class="shops-grid">
        <c:forEach var="shop" items="${featuredShops}">
          <div class="shop-card" onclick="window.location='${pageContext.request.contextPath}/shops?id=${shop.id}'">
            <div class="shop-card-img-placeholder">🍦</div>
            <div class="shop-card-body">
              <div class="shop-card-name"><c:out value="${shop.name}"/></div>
              <div class="shop-card-city">📍 <c:out value="${shop.city}"/></div>
              <div class="shop-card-desc"><c:out value="${shop.description}"/></div>
            </div>
            <div class="shop-card-footer">
              <div class="star-rating">
                <span class="stars">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= shop.rating}">★</c:when>
                      <c:otherwise>☆</c:otherwise>
                    </c:choose>
                  </c:forEach>
                </span>
                <span class="rating-val">${shop.rating}</span>
              </div>
              <span class="delivery-badge badge-delivery">🛵 Delivery</span>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>
  </div>
</section>

<!-- ── Trending Flavours ── -->
<section class="section">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <div class="section-title">Trending <span>Flavours</span></div>
        <div class="section-subtitle">What everyone is scooping right now</div>
      </div>
      <a href="${pageContext.request.contextPath}/flavours" class="btn btn-outline btn-sm">All Flavours →</a>
    </div>
    <div class="flavour-chips">
      <c:set var="icons" value="🍫,🥭,🍓,🍵,🍪,🧁,🍮,🌸"/>
      <c:forEach var="f" items="${trendingFlavours}" varStatus="st">
        <div class="flavour-chip">
          <div class="chip-icon">
            <c:choose>
              <c:when test="${f.category == 'chocolate'}">🍫</c:when>
              <c:when test="${f.category == 'fruit'}">🍓</c:when>
              <c:when test="${f.category == 'nut'}">🥜</c:when>
              <c:when test="${f.category == 'exotic'}">🌸</c:when>
              <c:when test="${f.category == 'caramel'}">🍮</c:when>
              <c:otherwise>🍦</c:otherwise>
            </c:choose>
          </div>
          <div class="chip-name"><c:out value="${f.name}"/></div>
          <div class="chip-cat"><c:out value="${f.category}"/></div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>

<!-- ── Best-Selling Products ── -->
<section class="section" style="background:var(--white)">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <div class="section-title">Best-Selling <span>Products</span></div>
        <div class="section-subtitle">Customer favourites across all shops</div>
      </div>
    </div>
    <div class="bestseller-grid">
      <c:forEach var="p" items="${bestsellerProducts}">
        <div class="product-card">
          <div class="product-img-placeholder">
            <c:choose>
              <c:when test="${p.category == 'scoop'}">🍨</c:when>
              <c:when test="${p.category == 'cone'}">🍦</c:when>
              <c:when test="${p.category == 'cup'}">🍧</c:when>
              <c:when test="${p.category == 'combo'}">🎁</c:when>
              <c:otherwise>🍦</c:otherwise>
            </c:choose>
          </div>
          <span class="bestseller-tag">⭐ Bestseller</span>
          <div class="product-body">
            <div class="product-name"><c:out value="${p.name}"/></div>
            <div class="product-desc"><c:out value="${p.description}"/></div>
            <div style="font-size:0.75rem;color:var(--gray);margin-bottom:0.5rem">🏪 <c:out value="${p.shopName}"/></div>
            <div class="product-footer">
              <span class="product-price">₹${p.price}</span>
              <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                <input type="hidden" name="action" value="add"/>
                <input type="hidden" name="productId" value="${p.id}"/>
                <button class="btn-add-cart" type="submit">+ Add</button>
              </form>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>

<!-- ── Special Offers ── -->
<section class="section">
  <div class="section-inner">
    <div class="section-title" style="margin-bottom:1.5rem">Special <span style="color:var(--purple-d)">Offers</span> &amp; Combos</div>
    <div class="offers-banner">
      <div>
        <h3>🎉 Family Combo Deal</h3>
        <p>Get 4 scoops of any flavour for just ₹450. Mix and match your favourites!</p>
      </div>
      <a href="${pageContext.request.contextPath}/shops">
        <button class="btn" style="background:#fff;color:var(--choco);font-weight:700">Order Now →</button>
      </a>
    </div>
    <div style="margin-top:1rem;background:linear-gradient(135deg,var(--purple-d),var(--pink-d))" class="offers-banner">
      <div>
        <h3>🍦 First Order Discount</h3>
        <p>New customers get 15% off their first order. Use code: SCOOP15</p>
      </div>
      <a href="${pageContext.request.contextPath}/register.jsp">
        <button class="btn" style="background:#fff;color:var(--purple-d);font-weight:700">Sign Up Free →</button>
      </a>
    </div>
  </div>
</section>

<!-- ── Customer Reviews ── -->
<section class="section" style="background:var(--white)">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <div class="section-title">What Customers <span>Say</span></div>
        <div class="section-subtitle">Real reviews from real ice cream lovers</div>
      </div>
      <a href="${pageContext.request.contextPath}/shops" class="btn btn-outline btn-sm">See All Reviews →</a>
    </div>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:1.2rem">
      <c:forEach var="rev" items="${recentReviews}">
        <div class="review-card">
          <div class="review-header">
            <div>
              <div class="reviewer-name">👤 <c:out value="${rev.userName}"/></div>
              <div style="font-size:0.78rem;color:var(--gray)">at <c:out value="${rev.shopName}"/></div>
            </div>
            <div class="review-stars">
              <c:forEach begin="1" end="${rev.rating}" var="s">★</c:forEach>
            </div>
          </div>
          <div class="review-comment">"<c:out value="${rev.comment}"/>"</div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>

<!-- ── Become a Partner ── -->
<section class="section">
  <div class="section-inner">
    <div class="partner-cta">
      <h2>🤝 Become a Scoopora Partner</h2>
      <p>List your ice cream shop, reach thousands of customers, and grow your business with our platform.</p>
      <a href="${pageContext.request.contextPath}/register.jsp">
        <button class="btn" style="background:#fff;color:var(--purple-d);font-weight:800;font-size:1rem">
          Register Your Shop →
        </button>
      </a>
    </div>
  </div>
</section>

<div class="toast" id="toast"></div>

<%@ include file="footer.jsp" %>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
