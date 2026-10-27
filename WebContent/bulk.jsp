<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    User bulkUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>B2B Wholesale Marketplace – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<!-- Hero -->
<div class="b2b-hero">
  <div class="b2b-hero-inner">
    <div class="b2b-hero-text">
      <div class="b2b-hero-tag">🏭 Business &amp; Wholesale</div>
      <h1>B2B Ice Cream <span>Marketplace</span></h1>
      <p>Wholesale ice cream tubs, cartons, event packages, and dessert supplies sourced directly from our partner shops. Real prices, real quantities, no middlemen.</p>
      <div class="b2b-hero-badges">
        <span>🍦 Ice Cream Shops</span>
        <span>☕ Cafés</span>
        <span>🏨 Hotels</span>
        <span>🍽 Restaurants</span>
        <span>🎪 Caterers</span>
        <span>🎉 Event Organisers</span>
        <span>🛒 Retailers</span>
      </div>
    </div>
    <div class="b2b-hero-terms">
      <div class="b2b-term-card">
        <div class="b2b-term-icon">🚚</div>
        <div class="b2b-term-label">Delivery</div>
        <div class="b2b-term-val">₹500 flat · Free above ₹10,000</div>
      </div>
      <div class="b2b-term-card">
        <div class="b2b-term-icon">📦</div>
        <div class="b2b-term-label">Min. Order</div>
        <div class="b2b-term-val">As listed per product (MOQ)</div>
      </div>
      <div class="b2b-term-card">
        <div class="b2b-term-icon">💰</div>
        <div class="b2b-term-label">Pricing</div>
        <div class="b2b-term-val">3-tier quantity discounts</div>
      </div>
      <div class="b2b-term-card">
        <div class="b2b-term-icon">🔄</div>
        <div class="b2b-term-label">Repeat Orders</div>
        <div class="b2b-term-val">One-click reorder from history</div>
      </div>
    </div>
  </div>
</div>

<!-- Error / success banners -->
<c:if test="${not empty param.error}">
  <div class="b2b-banner b2b-banner-error">
    <c:choose>
      <c:when test="${param.error == 'moq'}">⚠️ Minimum order quantity for this product is <strong><c:out value="${param.moq}"/></strong> units.</c:when>
      <c:when test="${param.error == 'stock'}">⚠️ Only <strong><c:out value="${param.avail}"/></strong> units available. Please reduce your quantity.</c:when>
      <c:otherwise>⚠️ Something went wrong. Please try again.</c:otherwise>
    </c:choose>
  </div>
</c:if>

<div class="section">
  <div class="section-inner">

    <!-- Filters -->
    <form method="get" action="${pageContext.request.contextPath}/bulk" class="b2b-filters">
      <select name="category" class="filter-select" onchange="this.form.submit()">
        <option value="">All Categories</option>
        <option value="tub"            ${selectedCategory == 'tub'            ? 'selected' : ''}>🍦 Ice Cream Tubs</option>
        <option value="carton"         ${selectedCategory == 'carton'         ? 'selected' : ''}>📦 Wholesale Cartons</option>
        <option value="pack"           ${selectedCategory == 'pack'           ? 'selected' : ''}>🎁 Family &amp; Party Packs</option>
        <option value="cone_supply"    ${selectedCategory == 'cone_supply'    ? 'selected' : ''}>🍦 Cone Supplies</option>
        <option value="cup_supply"     ${selectedCategory == 'cup_supply'     ? 'selected' : ''}>🥤 Cup Supplies</option>
        <option value="topping"        ${selectedCategory == 'topping'        ? 'selected' : ''}>🍫 Toppings &amp; Sauces</option>
        <option value="event_package"  ${selectedCategory == 'event_package'  ? 'selected' : ''}>🎉 Event Packages</option>
        <option value="dessert_supply" ${selectedCategory == 'dessert_supply' ? 'selected' : ''}>🍮 Dessert Supplies</option>
      </select>
      <select name="shopId" class="filter-select" onchange="this.form.submit()">
        <option value="">All Suppliers</option>
        <c:forEach var="sup" items="${suppliers}">
          <option value="${sup.id}" ${selectedShop == sup.id.toString() ? 'selected' : ''}>${sup.name} — ${sup.city}</option>
        </c:forEach>
      </select>
      <span class="results-count">${products.size()} product<c:if test="${products.size() != 1}">s</c:if></span>
      <c:if test="${not empty selectedCategory or not empty selectedShop}">
        <a href="${pageContext.request.contextPath}/bulk" class="btn btn-outline btn-sm">✕ Clear</a>
      </c:if>
    </form>

    <!-- Product Catalog -->
    <c:choose>
      <c:when test="${empty products}">
        <div class="empty-state">
          <div style="font-size:3rem">📦</div>
          <h2>No products found</h2>
          <p>Try a different category or supplier filter.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="b2b-grid">
          <c:forEach var="p" items="${products}">
            <div class="b2b-card" id="product-${p.id}">
              <div class="b2b-card-img">
                <c:choose>
                  <c:when test="${not empty p.imageUrl}">
                    <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="${p.name}"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'"/>
                    <div style="display:none;width:100%;height:100%;align-items:center;justify-content:center;font-size:3rem">
                      <c:choose>
                        <c:when test="${p.category=='tub'}">🍦</c:when>
                        <c:when test="${p.category=='carton'}">📦</c:when>
                        <c:when test="${p.category=='event_package'}">🎉</c:when>
                        <c:when test="${p.category=='topping'}">🍫</c:when>
                        <c:when test="${p.category=='cone_supply'}">🍦</c:when>
                        <c:when test="${p.category=='cup_supply'}">🥤</c:when>
                        <c:otherwise>🛒</c:otherwise>
                      </c:choose>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div style="display:flex;align-items:center;justify-content:center;font-size:3rem;height:100%">
                      <c:choose>
                        <c:when test="${p.category=='tub'}">🍦</c:when>
                        <c:when test="${p.category=='carton'}">📦</c:when>
                        <c:when test="${p.category=='event_package'}">🎉</c:when>
                        <c:when test="${p.category=='topping'}">🍫</c:when>
                        <c:otherwise>🛒</c:otherwise>
                      </c:choose>
                    </div>
                  </c:otherwise>
                </c:choose>
                <span class="b2b-cat-tag">${p.category.replace('_',' ')}</span>
              </div>

              <div class="b2b-card-body">
                <div class="b2b-supplier">🏪 ${p.shopName} · ${p.shopCity}</div>
                <div class="b2b-product-name">${p.name}</div>
                <div class="b2b-product-desc">${p.description}</div>

                <!-- Tier Pricing Table -->
                <div class="b2b-tier-table">
                  <div class="b2b-tier-head">
                    <span>Quantity</span><span>Unit Price</span><span>Savings</span>
                  </div>
                  <div class="b2b-tier-row b2b-tier-base">
                    <span>1–${p.tier1Qty - 1} ${p.unitLabel}</span>
                    <span>₹<fmt:formatNumber value="${p.basePrice}" maxFractionDigits="0"/></span>
                    <span class="b2b-tier-save">—</span>
                  </div>
                  <div class="b2b-tier-row">
                    <span>${p.tier1Qty}–${p.tier2Qty - 1} ${p.unitLabel}</span>
                    <span class="b2b-tier-price">₹<fmt:formatNumber value="${p.tier1Price}" maxFractionDigits="0"/></span>
                    <span class="b2b-tier-save">
                      Save <fmt:formatNumber value="${(p.basePrice - p.tier1Price) / p.basePrice * 100}" maxFractionDigits="0"/>%
                    </span>
                  </div>
                  <div class="b2b-tier-row">
                    <span>${p.tier2Qty}–${p.tier3Qty - 1} ${p.unitLabel}</span>
                    <span class="b2b-tier-price">₹<fmt:formatNumber value="${p.tier2Price}" maxFractionDigits="0"/></span>
                    <span class="b2b-tier-save">
                      Save <fmt:formatNumber value="${(p.basePrice - p.tier2Price) / p.basePrice * 100}" maxFractionDigits="0"/>%
                    </span>
                  </div>
                  <div class="b2b-tier-row b2b-tier-best">
                    <span>${p.tier3Qty}+ ${p.unitLabel}</span>
                    <span class="b2b-tier-price">₹<fmt:formatNumber value="${p.tier3Price}" maxFractionDigits="0"/></span>
                    <span class="b2b-tier-save">
                      Save <fmt:formatNumber value="${(p.basePrice - p.tier3Price) / p.basePrice * 100}" maxFractionDigits="0"/>% ⭐
                    </span>
                  </div>
                </div>

                <div class="b2b-meta-row">
                  <span class="b2b-moq-badge">MOQ: ${p.moq} units</span>
                  <c:choose>
                    <c:when test="${p.stock == 0}">
                      <span class="stock-badge stock-oos">Out of Stock</span>
                    </c:when>
                    <c:when test="${p.stock <= 20}">
                      <span class="stock-badge stock-low">Only ${p.stock} left</span>
                    </c:when>
                    <c:otherwise>
                      <span class="stock-badge stock-ok-badge">${p.stock} available</span>
                    </c:otherwise>
                  </c:choose>
                </div>

                  <c:choose>
                    <c:when test="${p.stock == 0}">
                      <button class="btn btn-outline btn-sm" disabled style="width:100%;opacity:0.5;cursor:not-allowed">Out of Stock</button>
                    </c:when>
                    <c:otherwise>
                      <button class="btn btn-primary btn-sm" style="width:100%"
                              data-id="${p.id}"
                              data-name="<c:out value='${p.name}'/>"
                              data-moq="${p.moq}" data-stock="${p.stock}"
                              data-base="${p.basePrice}"
                              data-t1q="${p.tier1Qty}" data-t1p="${p.tier1Price}"
                              data-t2q="${p.tier2Qty}" data-t2p="${p.tier2Price}"
                              data-t3q="${p.tier3Qty}" data-t3p="${p.tier3Price}"
                              data-label="<c:out value='${p.unitLabel}'/>"
                              onclick="openOrderModalFromBtn(this)">
                        📋 Place Wholesale Order
                      </button>
                    </c:otherwise>
                  </c:choose>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <!-- Order History -->
    <c:if test="${not empty myOrders}">
      <div style="margin-top:3rem">
        <div class="section-header">
          <div>
            <div class="section-title">My <span>Bulk Orders</span></div>
            <div class="section-subtitle">Your wholesale order history</div>
          </div>
        </div>
        <div class="b2b-history-table-wrap">
          <table class="b2b-history-table">
            <thead>
              <tr>
                <th>#</th><th>Product</th><th>Supplier</th><th>Qty</th>
                <th>Unit Price</th><th>Delivery</th><th>Total</th><th>Status</th><th>Date</th><th>Action</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="o" items="${myOrders}">
                <tr>
                  <td style="color:var(--gray);font-size:0.8rem">#${o.id}</td>
                  <td>
                    <div style="font-weight:700;font-size:0.88rem;color:var(--choco)">${o.productName}</div>
                    <div style="font-size:0.75rem;color:var(--gray)">${o.unitLabel}</div>
                  </td>
                  <td style="font-size:0.85rem">${o.shopName}</td>
                  <td style="font-weight:700">${o.quantity}</td>
                  <td>₹<fmt:formatNumber value="${o.unitPrice}" maxFractionDigits="0"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${o.deliveryFee == 0}"><span style="color:#2e7d32;font-weight:700">Free</span></c:when>
                      <c:otherwise>₹<fmt:formatNumber value="${o.deliveryFee}" maxFractionDigits="0"/></c:otherwise>
                    </c:choose>
                  </td>
                  <td style="font-weight:800;color:var(--purple-d)">₹<fmt:formatNumber value="${o.totalPrice}" maxFractionDigits="0"/></td>
                  <td><span class="order-status status-${o.status}">${o.status}</span></td>
                  <td style="font-size:0.78rem;color:var(--gray)">${o.date}</td>
                  <td>
                    <form action="${pageContext.request.contextPath}/bulk" method="post">
                      <input type="hidden" name="action" value="repeat"/>
                      <input type="hidden" name="orderId" value="${o.id}"/>
                      <button type="submit" class="b2b-repeat-btn" title="Repeat this order">🔄 Repeat</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>
    </c:if>

    <!-- Login prompt for guests -->
    <c:if test="${empty sessionScope.user}">
      <div class="b2b-login-prompt">
        <div style="font-size:2rem">🔐</div>
        <p><a href="${pageContext.request.contextPath}/login.jsp" style="color:var(--purple-d);font-weight:700">Login</a>
           or <a href="${pageContext.request.contextPath}/register.jsp" style="color:var(--purple-d);font-weight:700">Register</a>
           to place wholesale orders and view your order history.</p>
      </div>
    </c:if>

  </div>
</div>

<!-- Order Modal -->
<div class="b2b-modal-overlay" id="orderModal" onclick="if(event.target===this)closeModal()">
  <div class="b2b-modal">
    <div class="b2b-modal-header">
      <div class="b2b-modal-title" id="modalTitle">Place Wholesale Order</div>
      <button class="b2b-modal-close" onclick="closeModal()">✕</button>
    </div>

    <c:choose>
      <c:when test="${empty sessionScope.user}">
        <div style="padding:2rem;text-align:center">
          <p>Please <a href="${pageContext.request.contextPath}/login.jsp" style="color:var(--purple-d);font-weight:700">login</a> to place a wholesale order.</p>
        </div>
      </c:when>
      <c:otherwise>
        <form action="${pageContext.request.contextPath}/bulk" method="post" id="bulkOrderForm">
          <input type="hidden" name="action" value="order"/>
          <input type="hidden" name="productId" id="modalProductId"/>

          <div class="b2b-modal-body">

            <!-- Live price calculator -->
            <div class="b2b-price-calc" id="priceCalc">
              <div class="b2b-calc-row">
                <span>Unit price</span>
                <span id="calcUnitPrice">—</span>
              </div>
              <div class="b2b-calc-row">
                <span>Subtotal</span>
                <span id="calcSubtotal">—</span>
              </div>
              <div class="b2b-calc-row">
                <span>Delivery fee</span>
                <span id="calcDelivery">₹500</span>
              </div>
              <div class="b2b-calc-row b2b-calc-total">
                <span>Total</span>
                <span id="calcTotal">—</span>
              </div>
              <div id="calcTierNote" class="b2b-tier-note"></div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Business Type *</label>
                <select name="businessType" class="form-input" required id="modalBizType">
                  <option value="">Select type…</option>
                  <option value="ice_cream_shop" <c:if test="${repeatOrder.businessType == 'ice_cream_shop'}">selected</c:if>>🍦 Ice Cream Shop</option>
                  <option value="cafe"           <c:if test="${repeatOrder.businessType == 'cafe'}">selected</c:if>>☕ Café</option>
                  <option value="hotel"          <c:if test="${repeatOrder.businessType == 'hotel'}">selected</c:if>>🏨 Hotel</option>
                  <option value="restaurant"     <c:if test="${repeatOrder.businessType == 'restaurant'}">selected</c:if>>🍽 Restaurant</option>
                  <option value="caterer"        <c:if test="${repeatOrder.businessType == 'caterer'}">selected</c:if>>🎪 Caterer</option>
                  <option value="event_organizer"<c:if test="${repeatOrder.businessType == 'event_organizer'}">selected</c:if>>🎉 Event Organiser</option>
                  <option value="retailer"       <c:if test="${repeatOrder.businessType == 'retailer'}">selected</c:if>>🛒 Retailer</option>
                  <option value="other"          <c:if test="${repeatOrder.businessType == 'other'}">selected</c:if>>Other</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Business Name</label>
                <input type="text" name="businessName" class="form-input"
                       value="${repeatOrder.businessName}" placeholder="Your business name"/>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Quantity * <span id="moqHint" style="color:var(--gray);font-weight:400"></span></label>
              <input type="number" name="quantity" id="modalQty" class="form-input"
                     value="${not empty repeatOrder.quantity ? repeatOrder.quantity : ''}"
                     placeholder="Enter quantity" min="1" required oninput="recalcPrice()"/>
            </div>

            <div class="form-group">
              <label class="form-label">Delivery Address *</label>
              <input type="text" name="deliveryAddress" class="form-input"
                     placeholder="Street / building / area" required/>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">City *</label>
                <input type="text" name="deliveryCity" class="form-input"
                       value="${repeatOrder.deliveryCity}" placeholder="City" required/>
              </div>
              <div class="form-group">
                <label class="form-label">PIN Code *</label>
                <input type="text" name="deliveryPincode" class="form-input"
                       placeholder="6-digit PIN" maxlength="6" required/>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Notes <span style="color:var(--gray);font-weight:400">(optional)</span></label>
              <textarea name="notes" class="form-input" rows="2"
                        placeholder="Flavour preferences, delivery instructions, special requirements…"
                        style="resize:vertical">${repeatOrder.notes}</textarea>
            </div>

          </div>

          <div class="b2b-modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeModal()">Cancel</button>
            <button type="submit" class="btn btn-primary">✅ Confirm Wholesale Order</button>
          </div>
        </form>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
let _moq=1, _stock=0, _base=0, _t1q=0, _t1p=0, _t2q=0, _t2p=0, _t3q=0, _t3p=0, _label='';

function openOrderModalFromBtn(btn) {
  openOrderModal(
    btn.dataset.id, btn.dataset.name,
    +btn.dataset.moq, +btn.dataset.stock, +btn.dataset.base,
    +btn.dataset.t1q, +btn.dataset.t1p,
    +btn.dataset.t2q, +btn.dataset.t2p,
    +btn.dataset.t3q, +btn.dataset.t3p,
    btn.dataset.label
  );
}

function openOrderModal(id, name, moq, stock, base, t1q, t1p, t2q, t2p, t3q, t3p, label) {
  _moq=moq; _stock=stock; _base=base;
  _t1q=t1q; _t1p=t1p; _t2q=t2q; _t2p=t2p; _t3q=t3q; _t3p=t3p; _label=label;
  document.getElementById('modalProductId').value = id;
  document.getElementById('modalTitle').textContent = name;
  document.getElementById('moqHint').textContent = '(min ' + moq + ', max ' + stock + ')';
  const qtyEl = document.getElementById('modalQty');
  if (!qtyEl.value || +qtyEl.value < moq) qtyEl.value = moq;
  qtyEl.min = moq; qtyEl.max = stock;
  recalcPrice();
  document.getElementById('orderModal').classList.add('open');
}

function closeModal() {
  document.getElementById('orderModal').classList.remove('open');
}

function resolveUnitPrice(qty) {
  if (qty >= _t3q) return _t3p;
  if (qty >= _t2q) return _t2p;
  if (qty >= _t1q) return _t1p;
  return _base;
}

function recalcPrice() {
  const qty = parseInt(document.getElementById('modalQty').value) || 0;
  if (qty < 1) return;
  const unit     = resolveUnitPrice(qty);
  const subtotal = unit * qty;
  const delivery = subtotal >= 10000 ? 0 : 500;
  const total    = subtotal + delivery;

  document.getElementById('calcUnitPrice').textContent = '₹' + unit.toLocaleString('en-IN');
  document.getElementById('calcSubtotal').textContent  = '₹' + subtotal.toLocaleString('en-IN');
  document.getElementById('calcDelivery').textContent  = delivery === 0 ? 'Free 🎉' : '₹500';
  document.getElementById('calcTotal').textContent     = '₹' + total.toLocaleString('en-IN');

  let note = '';
  if (qty < _t1q)       note = 'Order ' + _t1q + '+ to unlock wholesale pricing';
  else if (qty < _t2q)  note = 'Order ' + _t2q + '+ for better pricing';
  else if (qty < _t3q)  note = 'Order ' + _t3q + '+ for best pricing ⭐';
  else                  note = '⭐ Best price tier active!';
  document.getElementById('calcTierNote').textContent = note;
}

// Auto-open modal for repeat order
<c:if test="${not empty repeatOrder}">
(function() {
  // Find the product card and trigger modal
  const pid = ${repeatOrder.productId};
  const btn = document.querySelector('#product-' + pid + ' button.btn-primary');
  if (btn) btn.click();
})();
</c:if>
</script>
</body>
</html>
