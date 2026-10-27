<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Ice Cream Cakes – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cakes.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<!-- Hero -->
<div class="page-hero cake-hero">
  <div class="cake-hero-content">
    <h1>🎂 Ice Cream Cake Designs</h1>
    <p>From dreamy birthday cakes to elegant wedding tiers — every cake is crafted with premium ice cream and love.</p>
    <a href="${pageContext.request.contextPath}/cakes?id=17">
      <button class="btn btn-hero-cta">🎨 Design Your Own Cake</button>
    </a>
  </div>
</div>

<!-- Category Filter Tabs -->
<div class="cake-type-bar">
  <div class="cake-type-inner">
    <a href="${pageContext.request.contextPath}/cakes"
       class="cake-type-tab ${empty typeFilter ? 'active' : ''}">🍰 All Cakes</a>
    <c:forEach var="t" items="${cakeTypes}">
      <a href="${pageContext.request.contextPath}/cakes?type=${t.value}"
         class="cake-type-tab ${typeFilter == t.value ? 'active' : ''}">${t.label}</a>
    </c:forEach>
  </div>
</div>

<!-- Gallery Grid -->
<div class="section">
  <div class="section-inner">
    <div class="section-header">
      <div>
        <div class="section-title">
          <c:choose>
            <c:when test="${empty typeFilter}">All Cake <span>Designs</span></c:when>
            <c:otherwise><span style="text-transform:capitalize">${typeFilter}</span> <span>Cakes</span></c:otherwise>
          </c:choose>
        </div>
        <div class="section-subtitle">${cakes.size()} design<c:if test="${cakes.size() != 1}">s</c:if> available</div>
      </div>
    </div>

    <div class="cake-gallery-grid">
      <c:forEach var="cake" items="${cakes}">
        <div class="cake-card" data-type="${cake.cakeType}">

          <!-- Image area -->
          <div class="cake-card-img-wrap">
            <div class="cake-card-img-placeholder ${cake.cakeType}">
              <c:choose>
                <c:when test="${cake.cakeType == 'birthday'}">🎂</c:when>
                <c:when test="${cake.cakeType == 'wedding'}">💍</c:when>
                <c:when test="${cake.cakeType == 'photo'}">📸</c:when>
                <c:when test="${cake.cakeType == 'chocolate'}">🍫</c:when>
                <c:when test="${cake.cakeType == 'cartoon'}">🦄</c:when>
                <c:when test="${cake.cakeType == 'heart'}">❤️</c:when>
                <c:when test="${cake.cakeType == 'anniversary'}">🥂</c:when>
                <c:when test="${cake.cakeType == 'designer'}">✨</c:when>
                <c:otherwise>🎨</c:otherwise>
              </c:choose>
            </div>

            <!-- Badges -->
            <c:if test="${cake.featured}">
              <span class="cake-badge-featured">⭐ Featured</span>
            </c:if>
            <c:if test="${cake.supportsPhoto}">
              <span class="cake-badge-photo">📸 Photo</span>
            </c:if>
            <c:if test="${cake.custom}">
              <span class="cake-badge-custom">🎨 Custom</span>
            </c:if>

            <!-- Type label -->
            <span class="cake-type-label cake-type-${cake.cakeType}">
              <c:choose>
                <c:when test="${cake.cakeType == 'birthday'}">🎂 Birthday</c:when>
                <c:when test="${cake.cakeType == 'wedding'}">💍 Wedding</c:when>
                <c:when test="${cake.cakeType == 'photo'}">📸 Photo</c:when>
                <c:when test="${cake.cakeType == 'chocolate'}">🍫 Chocolate</c:when>
                <c:when test="${cake.cakeType == 'cartoon'}">🦄 Cartoon</c:when>
                <c:when test="${cake.cakeType == 'heart'}">❤️ Heart</c:when>
                <c:when test="${cake.cakeType == 'anniversary'}">🥂 Anniversary</c:when>
                <c:when test="${cake.cakeType == 'designer'}">✨ Designer</c:when>
                <c:otherwise>🎨 Custom</c:otherwise>
              </c:choose>
            </span>
          </div>

          <!-- Card body -->
          <div class="cake-card-body">
            <div class="cake-card-name">${cake.name}</div>
            <div class="cake-card-desc">${cake.description}</div>

            <!-- Flavour & layers info -->
            <div class="cake-card-meta">
              <span>🍦 ${cake.baseFlavour}</span>
              <span>📚 ${cake.layers} Layer<c:if test="${cake.layers > 1}">s</c:if></span>
            </div>

            <!-- Size options preview -->
            <div class="cake-sizes-preview">
              <c:if test="${not empty cake.availableSizes}">
                <c:forEach var="sizeEntry" items="${cake.availableSizes.split(',')}" varStatus="st">
                  <c:set var="sizeParts" value="${sizeEntry.split(':')}"/>
                  <span class="size-chip <c:if test="${st.first}">active</c:if>"
                        data-price="${sizeParts[1]}"
                        data-size="${sizeParts[0]}">
                    ${sizeParts[0]}
                  </span>
                </c:forEach>
              </c:if>
            </div>
          </div>

          <!-- Card footer -->
          <div class="cake-card-footer">
            <div class="cake-price-wrap">
              <span class="cake-price-label">Starting from</span>
              <span class="cake-price">₹${cake.basePrice}</span>
            </div>
            <a href="${pageContext.request.contextPath}/cakes?id=${cake.id}">
              <button class="btn-customize">🎨 Customize Cake</button>
            </a>
          </div>
        </div>
      </c:forEach>
    </div>

    <c:if test="${empty cakes}">
      <div style="text-align:center;padding:4rem;color:var(--gray)">
        <div style="font-size:4rem">🎂</div>
        <h3>No cakes found in this category</h3>
        <a href="${pageContext.request.contextPath}/cakes" class="btn btn-primary" style="margin-top:1rem">View All Cakes</a>
      </div>
    </c:if>
  </div>
</div>

<!-- CTA Banner -->
<div class="section" style="background:var(--white);padding-top:0">
  <div class="section-inner">
    <div class="cake-cta-banner">
      <div>
        <h2>🎨 Can't find what you're looking for?</h2>
        <p>Design a completely custom cake from scratch — choose every detail exactly the way you want it.</p>
      </div>
      <a href="${pageContext.request.contextPath}/cakes?id=17">
        <button class="btn btn-primary" style="font-size:1rem;padding:0.8rem 2rem">Start Designing →</button>
      </a>
    </div>
  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
// Size chip selection on gallery cards
document.querySelectorAll('.cake-sizes-preview').forEach(wrap => {
  wrap.querySelectorAll('.size-chip').forEach(chip => {
    chip.addEventListener('click', function() {
      wrap.querySelectorAll('.size-chip').forEach(c => c.classList.remove('active'));
      this.classList.add('active');
      const priceEl = this.closest('.cake-card').querySelector('.cake-price');
      if (priceEl) priceEl.textContent = '₹' + this.dataset.price;
    });
  });
});
</script>
</body>
</html>
