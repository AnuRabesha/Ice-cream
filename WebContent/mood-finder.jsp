<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Find Your Scoop by Mood – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mood.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<!-- ── Hero ── -->
<div class="mood-hero">
  <div class="mood-hero-bubbles" aria-hidden="true">
    <span>🍦</span><span>🍫</span><span>🍓</span><span>🍧</span>
    <span>🌸</span><span>🍨</span><span>🎉</span><span>🌊</span>
  </div>
  <div class="mood-hero-content">
    <div class="mood-hero-badge">✨ New Feature</div>
    <h1>Find Your Scoop<br/><span>by Mood</span></h1>
    <p>Tell us how you're feeling and we'll find the perfect ice cream for you — from our real, available menu.</p>
  </div>
</div>

<!-- ── Mood Picker ── -->
<div class="mood-picker-section" id="moodPicker">
  <div class="mood-picker-inner">
    <div class="mood-picker-title">
      <c:choose>
        <c:when test="${not empty selectedMood}">
          Change your mood 👇
        </c:when>
        <c:otherwise>
          How are you feeling today? 👇
        </c:otherwise>
      </c:choose>
    </div>

    <form action="${pageContext.request.contextPath}/mood" method="post" id="moodForm">
      <div class="mood-cards-grid">
        <c:forEach var="mood" items="${moods}">
          <label class="mood-card ${selectedMood == mood.key ? 'selected' : ''}"
                 style="--mood-gradient: linear-gradient(${mood.gradient})">
            <input type="radio" name="mood" value="${mood.key}"
                   ${selectedMood == mood.key ? 'checked' : ''}
                   onchange="document.getElementById('moodForm').submit()"/>
            <div class="mood-card-emoji">${mood.emoji}</div>
            <div class="mood-card-title">${mood.title}</div>
            <div class="mood-card-sub">${mood.subtitle}</div>
            <div class="mood-card-check">✓</div>
          </label>
        </c:forEach>
      </div>
    </form>
  </div>
</div>

<!-- ── Results ── -->
<c:if test="${not empty selectedMood}">
  <div class="mood-results-section" id="moodResults">
    <div class="mood-results-inner">

      <!-- Results header -->
      <div class="mood-results-header">
        <div class="mood-results-badge" style="background:linear-gradient(${moodMeta[4]})">
          ${moodMeta[1]} ${moodMeta[2]}
        </div>
        <div class="mood-results-title">
          Your Perfect Scoops
        </div>
        <div class="mood-results-sub">
          ${moodMeta[3]} — ${recommendations.size()} match<c:if test="${recommendations.size() != 1}">es</c:if> found from our live menu
        </div>
      </div>

      <c:choose>
        <c:when test="${empty recommendations}">
          <!-- No results state -->
          <div class="mood-no-results">
            <div class="mood-no-results-icon">🍦</div>
            <h3>No matches right now</h3>
            <p>Our shops are updating their menus. Try a different mood or check back soon!</p>
            <a href="${pageContext.request.contextPath}/shops" class="btn btn-primary">Browse All Shops</a>
          </div>
        </c:when>
        <c:otherwise>
          <!-- Product grid -->
          <div class="mood-products-grid">
            <c:forEach var="p" items="${recommendations}" varStatus="st">
              <div class="mood-product-card" style="animation-delay:${st.index * 0.06}s">

                <!-- Image / emoji placeholder -->
                <div class="mood-product-img">
                  <c:choose>
                    <c:when test="${p.category == 'scoop'}">🍨</c:when>
                    <c:when test="${p.category == 'cone'}">🍦</c:when>
                    <c:when test="${p.category == 'cup'}">🍧</c:when>
                    <c:when test="${p.category == 'combo'}">🎁</c:when>
                    <c:when test="${p.category == 'cake'}">🎂</c:when>
                    <c:otherwise>🍦</c:otherwise>
                  </c:choose>
                </div>

                <!-- Badges -->
                <c:if test="${p.bestseller}">
                  <span class="mood-bestseller-tag">⭐ Bestseller</span>
                </c:if>

                <!-- Mood match tags -->
                <div class="mood-match-tags">
                  <c:forEach var="tag" items="${p.moodTags.split(',')}" varStatus="ts">
                    <c:if test="${ts.index < 3}">
                      <span class="mood-tag">${tag.trim()}</span>
                    </c:if>
                  </c:forEach>
                </div>

                <div class="mood-product-body">
                  <div class="mood-product-name">${p.name}</div>
                  <div class="mood-product-desc">${p.description}</div>
                  <div class="mood-product-shop">🏪 ${p.shopName}</div>

                  <!-- Stock indicator -->
                  <div class="mood-stock-bar">
                    <div class="mood-stock-fill"
                         style="width:${p.stock > 100 ? 100 : p.stock}%"></div>
                  </div>
                  <div class="mood-stock-label">
                    <c:choose>
                      <c:when test="${p.stock > 50}">✅ In Stock</c:when>
                      <c:when test="${p.stock > 10}">⚠️ Limited — ${p.stock} left</c:when>
                      <c:otherwise>🔴 Only ${p.stock} left!</c:otherwise>
                    </c:choose>
                  </div>

                  <div class="mood-product-footer">
                    <span class="mood-product-price">₹${p.price}</span>
                    <div class="mood-product-actions">
                      <a href="${pageContext.request.contextPath}/shops?id=${p.shopId}"
                         class="btn-mood-explore" title="View in shop">👁</a>
                      <form action="${pageContext.request.contextPath}/cart" method="post"
                            style="display:inline" onsubmit="handleCartAdd(event, this)">
                        <input type="hidden" name="action" value="add"/>
                        <input type="hidden" name="productId" value="${p.id}"/>
                        <button class="btn-mood-cart" type="submit"
                                title="Add to cart">🛒 Add</button>
                      </form>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <!-- Explore more CTA -->
          <div class="mood-explore-more">
            <p>Want to explore more options?</p>
            <div style="display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;margin-top:0.8rem">
              <a href="${pageContext.request.contextPath}/shops" class="btn btn-outline">🏪 Browse All Shops</a>
              <a href="${pageContext.request.contextPath}/cakes" class="btn btn-choco">🎂 Explore Cakes</a>
            </div>
          </div>
        </c:otherwise>
      </c:choose>

    </div>
  </div>
</c:if>

<!-- ── How It Works ── (shown when no mood selected) -->
<c:if test="${empty selectedMood}">
  <div class="mood-how-section">
    <div class="mood-how-inner">
      <div class="section-title" style="text-align:center;margin-bottom:2rem">
        How It <span>Works</span>
      </div>
      <div class="mood-how-steps">
        <div class="mood-how-step">
          <div class="how-step-num">1</div>
          <div class="how-step-icon">😊</div>
          <div class="how-step-title">Pick Your Mood</div>
          <div class="how-step-desc">Choose how you're feeling right now from our mood cards above.</div>
        </div>
        <div class="mood-how-arrow">→</div>
        <div class="mood-how-step">
          <div class="how-step-num">2</div>
          <div class="how-step-icon">🔍</div>
          <div class="how-step-title">We Find Matches</div>
          <div class="how-step-desc">Our system searches real, in-stock products that match your mood.</div>
        </div>
        <div class="mood-how-arrow">→</div>
        <div class="mood-how-step">
          <div class="how-step-num">3</div>
          <div class="how-step-icon">🛒</div>
          <div class="how-step-title">Add to Cart</div>
          <div class="how-step-desc">Add your perfect scoop directly to cart or explore the full shop.</div>
        </div>
      </div>
    </div>
  </div>
</c:if>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
// Smooth scroll to results after form submit
window.addEventListener('load', () => {
  const results = document.getElementById('moodResults');
  if (results) {
    setTimeout(() => results.scrollIntoView({ behavior: 'smooth', block: 'start' }), 200);
  }
});

// Cart add with toast feedback (no page reload)
function handleCartAdd(e, form) {
  e.preventDefault();
  const btn = form.querySelector('button');
  const original = btn.innerHTML;
  btn.innerHTML = '✅ Added!';
  btn.disabled = true;
  btn.style.background = '#2e7d32';

  fetch(form.action, { method: 'POST', body: new FormData(form) })
    .then(() => {
      showToast('🛒 Added to cart!');
      // Refresh badge
      fetch('${pageContext.request.contextPath}/cart-count')
        .then(r => r.json())
        .then(d => {
          const badge = document.getElementById('cartBadge');
          if (badge) badge.textContent = d.count || 0;
        });
      setTimeout(() => {
        btn.innerHTML = original;
        btn.disabled = false;
        btn.style.background = '';
      }, 2000);
    })
    .catch(() => { form.submit(); });
}
</script>
</body>
</html>
