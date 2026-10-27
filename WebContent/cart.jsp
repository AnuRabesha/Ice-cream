<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>My Cart – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>🛒 My Cart</h1>
  <p>Review your items before checkout</p>
</div>

<div class="section">
  <div class="section-inner">

    <c:choose>
      <c:when test="${empty cartItems}">
        <div class="empty-state">
          <div style="font-size:4rem">🛒</div>
          <h2>Your cart is empty</h2>
          <p>Browse our shops and add some delicious ice cream!</p>
          <a href="${pageContext.request.contextPath}/shops" class="btn btn-primary" style="margin-top:1rem">Explore Shops</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="cart-layout">

          <!-- Cart Items -->
          <div class="cart-items-col">
            <c:if test="${not empty cartShop}">
              <div class="cart-shop-banner">
                🍦 Items from <strong>${cartShop.name}</strong>
              </div>
            </c:if>

            <c:forEach var="item" items="${cartItems}">
              <div class="cart-item-card ${item.outOfStock ? 'cart-item-oos' : ''}">
                <div class="cart-item-img">
                  <c:choose>
                    <c:when test="${not empty item.imageUrl}">
                      <img src="${pageContext.request.contextPath}/${item.imageUrl}" alt="${item.name}"
                           onerror="this.style.display='none';this.nextElementSibling.style.display='flex'"/>
                      <div style="display:none;width:100%;height:100%;align-items:center;justify-content:center;font-size:2rem">🍦</div>
                    </c:when>
                    <c:otherwise><div style="display:flex;align-items:center;justify-content:center;font-size:2rem;height:100%">🍦</div></c:otherwise>
                  </c:choose>
                </div>

                <div class="cart-item-info">
                  <div class="cart-item-name">${item.name}</div>
                  <div class="cart-item-price">₹<fmt:formatNumber value="${item.price}" maxFractionDigits="2"/></div>
                  <c:choose>
                    <c:when test="${item.outOfStock}">
                      <div class="stock-badge stock-oos">Out of Stock</div>
                    </c:when>
                    <c:when test="${item.lowStock}">
                      <div class="stock-badge stock-low">Only ${item.stock} left!</div>
                    </c:when>
                    <c:when test="${item.qtyExceeded}">
                      <div class="stock-badge stock-low">Only ${item.stock} available — qty adjusted</div>
                    </c:when>
                  </c:choose>
                </div>

                <div class="cart-item-controls">
                  <c:choose>
                    <c:when test="${item.outOfStock}">
                      <span class="qty-btn" style="opacity:0.3;cursor:not-allowed">−</span>
                      <span class="qty-val">0</span>
                      <span class="qty-btn" style="opacity:0.3;cursor:not-allowed">+</span>
                    </c:when>
                    <c:otherwise>
                      <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                        <input type="hidden" name="action" value="update"/>
                        <input type="hidden" name="productId" value="${item.productId}"/>
                        <input type="hidden" name="qty" value="${item.quantity - 1}"/>
                        <button class="qty-btn" type="submit">−</button>
                      </form>
                      <span class="qty-val">${item.quantity}</span>
                      <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                        <input type="hidden" name="action" value="update"/>
                        <input type="hidden" name="productId" value="${item.productId}"/>
                        <input type="hidden" name="qty" value="${item.quantity + 1}"/>
                        <button class="qty-btn" type="submit"
                          <c:if test="${item.quantity >= item.stock}">disabled title="Maximum available quantity"</c:if>>+</button>
                      </form>
                    </c:otherwise>
                  </c:choose>
                </div>

                <div class="cart-item-subtotal">
                  <c:choose>
                    <c:when test="${item.outOfStock}"><span style="color:#ccc">—</span></c:when>
                    <c:otherwise>₹<fmt:formatNumber value="${item.subtotal}" maxFractionDigits="2"/></c:otherwise>
                  </c:choose>
                </div>

                <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                  <input type="hidden" name="action" value="remove"/>
                  <input type="hidden" name="productId" value="${item.productId}"/>
                  <button class="cart-remove-btn" type="submit" title="Remove">✕</button>
                </form>
              </div>
            </c:forEach>
          </div>

          <!-- Order Summary -->
          <div class="cart-summary-col">
            <div class="cart-summary-card">
              <div class="summary-title">Order Summary</div>

              <div class="summary-row">
                <span>Subtotal</span>
                <span>₹<fmt:formatNumber value="${cartSubtotal}" maxFractionDigits="2"/></span>
              </div>

              <c:if test="${not empty cartShop and cartShop.homeDelivery}">
                <div class="summary-row" style="color:var(--gray);font-size:0.85rem">
                  <span>Delivery fee</span>
                  <span>₹<fmt:formatNumber value="${cartShop.deliveryFee}" maxFractionDigits="0"/></span>
                </div>
                <div class="summary-note">⏱ Est. delivery: ${cartShop.deliveryTime}</div>
              </c:if>
              <c:if test="${not empty cartShop and not cartShop.homeDelivery}">
                <div class="summary-note" style="color:#c62828">❌ Delivery not available — Pickup only</div>
              </c:if>
              <c:if test="${not empty cartShop and cartShop.minOrder > cartSubtotal}">
                <div class="summary-note" style="color:#e65100">
                  ⚠️ Min. order ₹<fmt:formatNumber value="${cartShop.minOrder}" maxFractionDigits="0"/>
                  — add ₹<fmt:formatNumber value="${cartShop.minOrder - cartSubtotal}" maxFractionDigits="0"/> more
                </div>
              </c:if>

              <div class="summary-divider"></div>
              <div class="summary-total">
                <span>Total</span>
                <c:choose>
                  <c:when test="${not empty cartShop and cartShop.homeDelivery}">
                    <span>₹<fmt:formatNumber value="${cartSubtotal + cartShop.deliveryFee}" maxFractionDigits="2"/></span>
                  </c:when>
                  <c:otherwise>
                    <span>₹<fmt:formatNumber value="${cartSubtotal}" maxFractionDigits="2"/></span>
                  </c:otherwise>
                </c:choose>
              </div>

              <%-- Disable checkout if any item is out of stock or below min order --%>
              <c:set var="hasOos" value="false"/>
              <c:forEach var="item" items="${cartItems}">
                <c:if test="${item.outOfStock}"><c:set var="hasOos" value="true"/></c:if>
              </c:forEach>

              <c:choose>
                <c:when test="${hasOos}">
                  <button class="btn btn-primary" disabled
                    style="width:100%;justify-content:center;margin-top:1rem;opacity:0.5;cursor:not-allowed"
                    title="Remove out-of-stock items to proceed">
                    Remove Out-of-Stock Items First
                  </button>
                </c:when>
                <c:when test="${not empty cartShop and cartSubtotal < cartShop.minOrder}">
                  <button class="btn btn-primary" disabled
                    style="width:100%;justify-content:center;margin-top:1rem;opacity:0.5;cursor:not-allowed">
                    Proceed to Checkout →
                  </button>
                </c:when>
                <c:otherwise>
                  <a href="${pageContext.request.contextPath}/checkout"
                     class="btn btn-primary" style="width:100%;justify-content:center;margin-top:1rem">
                    Proceed to Checkout →
                  </a>
                </c:otherwise>
              </c:choose>

              <a href="${pageContext.request.contextPath}/shops"
                 class="btn btn-outline" style="width:100%;justify-content:center;margin-top:0.6rem">
                ← Continue Shopping
              </a>
            </div>
          </div>

        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
