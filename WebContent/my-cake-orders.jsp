<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>My Cake Orders – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cakes.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>🎂 My Cake Orders</h1>
  <p>Track the status of all your custom cake orders.</p>
</div>

<div class="section">
  <div class="section-inner">

    <c:if test="${param.ordered != null}">
      <div style="background:#e8f5e9;color:#2e7d32;padding:1.2rem 1.5rem;border-radius:12px;margin-bottom:1.5rem;font-weight:600">
        🎉 Your cake order #${param.ordered} has been placed! The shop owner will review and confirm within 24 hours.
      </div>
    </c:if>

    <c:choose>
      <c:when test="${empty myCakeOrders}">
        <div style="text-align:center;padding:4rem;color:var(--gray)">
          <div style="font-size:4rem">🎂</div>
          <h3>No cake orders yet</h3>
          <p>Design your first custom cake!</p>
          <a href="${pageContext.request.contextPath}/cakes" class="btn btn-primary" style="margin-top:1rem">Browse Cake Designs</a>
        </div>
      </c:when>
      <c:otherwise>
        <div style="display:flex;flex-direction:column;gap:1.2rem">
          <c:forEach var="order" items="${myCakeOrders}">
            <div class="dashboard-order-card status-${order.status}">
              <div class="order-card-header">
                <div>
                  <div class="order-id">🎂 Cake Order #${order.id}</div>
                  <div class="order-date">Placed: ${order.createdAt}</div>
                </div>
                <span class="status-badge status-${order.status}">
                  <c:choose>
                    <c:when test="${order.status == 'pending'}">⏳ Pending Review</c:when>
                    <c:when test="${order.status == 'owner_review'}">👀 Under Review</c:when>
                    <c:when test="${order.status == 'confirmed'}">✅ Confirmed</c:when>
                    <c:when test="${order.status == 'preparing'}">👨🍳 Being Prepared</c:when>
                    <c:when test="${order.status == 'ready'}">📦 Ready for Pickup/Delivery</c:when>
                    <c:when test="${order.status == 'delivered'}">🎉 Delivered</c:when>
                    <c:when test="${order.status == 'cancelled'}">❌ Cancelled</c:when>
                  </c:choose>
                </span>
              </div>

              <div class="order-details-grid">
                <div class="order-detail-row"><span>🏪 Shop</span><strong>${order.shopName}</strong></div>
                <div class="order-detail-row"><span>🎂 Design</span><strong>${order.designName}</strong></div>
                <div class="order-detail-row"><span>📏 Size</span><strong>${order.size}</strong></div>
                <div class="order-detail-row"><span>🔷 Shape</span><strong>${order.shape}</strong></div>
                <div class="order-detail-row"><span>🍦 Flavour</span><strong>${order.flavour}</strong></div>
                <div class="order-detail-row"><span>🎨 Colour</span><strong>${order.colour}</strong></div>
                <div class="order-detail-row"><span>🍓 Toppings</span><strong>${order.toppings}</strong></div>
                <c:if test="${not empty order.message}">
                  <div class="order-detail-row"><span>✍️ Message</span><strong>"${order.message}"</strong></div>
                </c:if>
                <div class="order-detail-row"><span>📅 Delivery Date</span><strong>${order.deliveryDate}</strong></div>
                <div class="order-detail-row"><span>🔢 Quantity</span><strong>${order.quantity}</strong></div>
                <div class="order-detail-row"><span>💰 Total Paid</span>
                  <strong style="color:var(--purple-d);font-size:1.1rem">₹${order.finalPrice}</strong>
                </div>
              </div>

              <c:if test="${not empty order.ownerNotes}">
                <div style="background:var(--lavender);border-radius:10px;padding:0.8rem;margin-top:0.8rem;font-size:0.85rem">
                  <strong style="color:var(--purple-d)">📝 Message from Shop:</strong>
                  <p style="margin-top:0.3rem;color:var(--choco)">${order.ownerNotes}</p>
                </div>
              </c:if>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <div style="margin-top:2rem;text-align:center">
      <a href="${pageContext.request.contextPath}/cakes" class="btn btn-outline">🎂 Order Another Cake</a>
    </div>
  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
