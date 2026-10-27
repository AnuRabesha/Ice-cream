<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>My Orders – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>📦 My Orders</h1>
  <p>Track your ice cream orders</p>
</div>

<div class="section">
  <div class="section-inner" style="max-width:860px">

    <c:choose>
      <c:when test="${empty orders}">
        <div class="empty-state">
          <div style="font-size:4rem">📦</div>
          <h2>No orders yet</h2>
          <p>Your order history will appear here once you place an order.</p>
          <a href="${pageContext.request.contextPath}/shops" class="btn btn-primary" style="margin-top:1rem">Start Shopping</a>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="order" items="${orders}">
          <div class="order-card">
            <div class="order-card-header">
              <div>
                <div class="order-id">Order #${order.id}</div>
                <div class="order-meta">
                  <c:if test="${not empty order.shopName}">🍦 ${order.shopName} &nbsp;·&nbsp;</c:if>
                  📅 ${order.date}
                </div>
              </div>
              <div style="text-align:right">
                <span class="order-status status-${order.status}">${order.status}</span>
                <div class="order-fulfillment">
                  <c:choose>
                    <c:when test="${order.fulfillmentType == 'pickup'}">🏪 Pickup</c:when>
                    <c:otherwise>🛵 Delivery</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>

            <div class="order-items-list">
              <c:forEach var="item" items="${order.items}">
                <div class="order-item-row">
                  <span>${item.name} × ${item.quantity}</span>
                  <span>₹<fmt:formatNumber value="${item.unitPrice * item.quantity}" maxFractionDigits="2"/></span>
                </div>
              </c:forEach>
            </div>

            <div class="order-card-footer">
              <div>
                <c:if test="${order.fulfillmentType == 'delivery' and not empty order.address}">
                  <div class="order-address">📍 <c:out value="${order.address}"/></div>
                </c:if>
                <c:if test="${not empty order.instructions}">
                  <div class="order-address" style="color:var(--gray)">📝 <c:out value="${order.instructions}"/></div>
                </c:if>
                <c:if test="${order.cancellable}">
                  <form action="${pageContext.request.contextPath}/orders" method="post" style="margin-top:0.5rem"
                        onsubmit="return confirm('Cancel this order? Stock will be restored.')">
                    <input type="hidden" name="action" value="cancel"/>
                    <input type="hidden" name="orderId" value="${order.id}"/>
                    <button type="submit" class="btn-cancel-order">✕ Cancel Order</button>
                  </form>
                </c:if>
              </div>
              <div class="order-total-wrap">
                <c:if test="${order.deliveryFee > 0}">
                  <div style="font-size:0.8rem;color:var(--gray)">
                    Subtotal: ₹<fmt:formatNumber value="${order.total - order.deliveryFee}" maxFractionDigits="2"/>
                    + Delivery: ₹<fmt:formatNumber value="${order.deliveryFee}" maxFractionDigits="0"/>
                  </div>
                </c:if>
                <div class="order-total">₹<fmt:formatNumber value="${order.total}" maxFractionDigits="2"/></div>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>

  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
