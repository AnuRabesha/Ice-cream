<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    User checkoutUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Checkout – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>📋 Checkout</h1>
  <p>Almost there! Fill in your details to confirm your order.</p>
</div>

<div class="section">
  <div class="section-inner">

    <c:if test="${not empty error}">
      <div class="checkout-error"><c:out value="${error}"/></div>
    </c:if>

    <div class="checkout-layout">

      <!-- Left: Form -->
      <div class="checkout-form-col">
        <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">

          <!-- Fulfillment Type -->
          <div class="checkout-card">
            <div class="checkout-card-title">🚚 Delivery Method</div>
            <div class="fulfillment-options">
              <c:choose>
                <c:when test="${not empty cartShop and cartShop.homeDelivery}">
                  <label class="fulfillment-option" id="optDelivery">
                    <input type="radio" name="fulfillment" value="delivery" checked onchange="toggleFulfillment(this.value)"/>
                    <span class="fulfillment-icon">🛵</span>
                    <div>
                      <div class="fulfillment-label">Home Delivery</div>
                      <div class="fulfillment-sub">₹<fmt:formatNumber value="${cartShop.deliveryFee}" maxFractionDigits="0"/> · ${cartShop.deliveryTime}</div>
                    </div>
                  </label>
                </c:when>
                <c:otherwise>
                  <div class="fulfillment-option disabled">
                    <span class="fulfillment-icon">🛵</span>
                    <div>
                      <div class="fulfillment-label" style="color:#999">Home Delivery</div>
                      <div class="fulfillment-sub" style="color:#c62828">Not available in your area</div>
                    </div>
                  </div>
                  <input type="hidden" name="fulfillment" value="pickup"/>
                </c:otherwise>
              </c:choose>

              <c:if test="${not empty cartShop and cartShop.pickupAvailable}">
                <label class="fulfillment-option" id="optPickup">
                  <input type="radio" name="fulfillment" value="pickup"
                    <c:if test="${not cartShop.homeDelivery}">checked</c:if>
                    onchange="toggleFulfillment(this.value)"/>
                  <span class="fulfillment-icon">🏪</span>
                  <div>
                    <div class="fulfillment-label">Pickup</div>
                    <div class="fulfillment-sub">Free · Pick up at ${cartShop.name}</div>
                  </div>
                </label>
              </c:if>
            </div>
          </div>

          <!-- Contact Info -->
          <div class="checkout-card">
            <div class="checkout-card-title">👤 Contact Information</div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Full Name *</label>
                <input type="text" name="customerName" class="form-input"
                  value="<%= checkoutUser != null ? checkoutUser.getName() : "" %>"
                  placeholder="Your full name" required/>
              </div>
              <div class="form-group">
                <label class="form-label">Phone Number *</label>
                <input type="tel" name="customerPhone" class="form-input"
                  value="<%= checkoutUser != null && checkoutUser.getPhone() != null ? checkoutUser.getPhone() : "" %>"
                  placeholder="10-digit mobile number" maxlength="10" required/>
              </div>
            </div>
          </div>

          <!-- Delivery Address -->
          <div class="checkout-card" id="addressSection">
            <div class="checkout-card-title">📍 Delivery Address</div>
            <div class="form-group">
              <label class="form-label">House / Flat / Street *</label>
              <input type="text" name="houseStreet" class="form-input" placeholder="e.g. Flat 4B, Rose Apartments, MG Road"/>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Area / Locality *</label>
                <input type="text" name="area" class="form-input" placeholder="e.g. Bandra West"/>
              </div>
              <div class="form-group">
                <label class="form-label">City *</label>
                <input type="text" name="city" class="form-input" placeholder="e.g. Mumbai"/>
              </div>
            </div>
            <div class="form-group" style="max-width:200px">
              <label class="form-label">PIN Code *</label>
              <input type="text" name="pincode" class="form-input" placeholder="6-digit PIN" maxlength="6"/>
            </div>
            <c:if test="${not empty cartShop and not empty cartShop.deliveryAreas}">
              <div class="delivery-areas-note">
                📦 We deliver to: <strong>${cartShop.deliveryAreas}</strong>
              </div>
            </c:if>
          </div>

          <!-- Delivery Instructions -->
          <div class="checkout-card">
            <div class="checkout-card-title">📝 Delivery Instructions <span style="font-weight:400;color:var(--gray)">(optional)</span></div>
            <textarea name="instructions" class="form-input" rows="3"
              placeholder="e.g. Ring the bell twice, leave at door, call on arrival…"
              style="resize:vertical"></textarea>
          </div>

          <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;font-size:1rem;padding:0.9rem">
            ✅ Confirm Order
          </button>
        </form>
      </div>

      <!-- Right: Order Summary -->
      <div class="checkout-summary-col">
        <div class="cart-summary-card" style="position:sticky;top:80px">
          <div class="summary-title">Order Summary</div>
          <div style="font-size:0.82rem;color:var(--gray);margin-bottom:0.8rem">
            from <strong>${cartShop.name}</strong>
          </div>

          <c:forEach var="item" items="${cartItems}">
            <div class="summary-item">
              <span>${item.name} × ${item.quantity}</span>
              <span>₹<fmt:formatNumber value="${item.subtotal}" maxFractionDigits="2"/></span>
            </div>
          </c:forEach>

          <div class="summary-divider"></div>
          <div class="summary-row">
            <span>Subtotal</span>
            <span>₹<fmt:formatNumber value="${cartSubtotal}" maxFractionDigits="2"/></span>
          </div>
          <div class="summary-row" id="summaryDeliveryRow">
            <span>Delivery fee</span>
            <span id="summaryDeliveryFee">
              <c:choose>
                <c:when test="${not empty cartShop and cartShop.homeDelivery}">
                  ₹<fmt:formatNumber value="${cartShop.deliveryFee}" maxFractionDigits="0"/>
                </c:when>
                <c:otherwise>Free</c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="summary-divider"></div>
          <div class="summary-total" id="summaryTotal">
            <span>Total</span>
            <span id="summaryTotalVal">
              <c:choose>
                <c:when test="${not empty cartShop and cartShop.homeDelivery}">
                  ₹<fmt:formatNumber value="${cartSubtotal + cartShop.deliveryFee}" maxFractionDigits="2"/>
                </c:when>
                <c:otherwise>₹<fmt:formatNumber value="${cartSubtotal}" maxFractionDigits="2"/></c:otherwise>
              </c:choose>
            </span>
          </div>

          <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline" style="width:100%;justify-content:center;margin-top:1rem">
            ← Edit Cart
          </a>
        </div>
      </div>

    </div>
  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
const subtotal   = ${cartSubtotal};
const deliveryFee = ${not empty cartShop and cartShop.homeDelivery ? cartShop.deliveryFee : 0};

function toggleFulfillment(val) {
  const addrSection = document.getElementById('addressSection');
  const feeEl       = document.getElementById('summaryDeliveryFee');
  const totalEl     = document.getElementById('summaryTotalVal');
  const addrInputs  = addrSection.querySelectorAll('input');

  if (val === 'delivery') {
    addrSection.style.display = '';
    addrInputs.forEach(i => i.required = true);
    feeEl.textContent   = '₹' + deliveryFee.toFixed(0);
    totalEl.textContent = '₹' + (subtotal + deliveryFee).toFixed(2);
  } else {
    addrSection.style.display = 'none';
    addrInputs.forEach(i => { i.required = false; });
    feeEl.textContent   = 'Free';
    totalEl.textContent = '₹' + subtotal.toFixed(2);
  }

  // Highlight selected option
  document.querySelectorAll('.fulfillment-option').forEach(o => o.classList.remove('selected'));
  const radio = document.querySelector('input[name="fulfillment"]:checked');
  if (radio) radio.closest('.fulfillment-option').classList.add('selected');
}

// Init on load
document.addEventListener('DOMContentLoaded', function() {
  const checked = document.querySelector('input[name="fulfillment"]:checked');
  if (checked) toggleFulfillment(checked.value);
  document.querySelectorAll('.fulfillment-option input[type=radio]').forEach(r => {
    r.addEventListener('change', () => toggleFulfillment(r.value));
  });
});
</script>
</body>
</html>
