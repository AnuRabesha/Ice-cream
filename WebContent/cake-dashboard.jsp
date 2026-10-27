<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Cake Orders Dashboard – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cakes.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>🎂 Cake Orders Dashboard</h1>
  <p>Review, confirm, and manage all custom cake orders for your shop.</p>
</div>

<div class="section">
  <div class="section-inner">

    <c:if test="${param.updated != null}">
      <div class="alert-success" style="background:#e8f5e9;color:#2e7d32;padding:1rem;border-radius:12px;margin-bottom:1.5rem">
        ✅ Order #${param.updated} status updated successfully.
      </div>
    </c:if>

    <c:choose>
      <c:when test="${empty cakeOrders}">
        <div style="text-align:center;padding:4rem;color:var(--gray)">
          <div style="font-size:4rem">🎂</div>
          <h3>No cake orders yet</h3>
          <p>Custom cake orders from customers will appear here.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="dashboard-orders-grid">
          <c:forEach var="order" items="${cakeOrders}">
            <div class="dashboard-order-card status-${order.status}">
              <div class="order-card-header">
                <div>
                  <div class="order-id">Order #${order.id}</div>
                  <div class="order-date">${order.createdAt}</div>
                </div>
                <span class="status-badge status-${order.status}">
                  <c:choose>
                    <c:when test="${order.status == 'pending'}">⏳ Pending Review</c:when>
                    <c:when test="${order.status == 'owner_review'}">👀 Under Review</c:when>
                    <c:when test="${order.status == 'confirmed'}">✅ Confirmed</c:when>
                    <c:when test="${order.status == 'preparing'}">👨‍🍳 Preparing</c:when>
                    <c:when test="${order.status == 'ready'}">📦 Ready</c:when>
                    <c:when test="${order.status == 'delivered'}">🎉 Delivered</c:when>
                    <c:when test="${order.status == 'cancelled'}">❌ Cancelled</c:when>
                  </c:choose>
                </span>
              </div>

              <div class="order-details-grid">
                <div class="order-detail-row"><span>👤 Customer</span><strong>${order.customerName}</strong></div>
                <div class="order-detail-row"><span>📞 Phone</span><strong>${order.customerPhone}</strong></div>
                <div class="order-detail-row"><span>🎂 Design</span><strong>${order.designName}</strong></div>
                <div class="order-detail-row"><span>📏 Size</span><strong>${order.size}</strong></div>
                <div class="order-detail-row"><span>🔷 Shape</span><strong>${order.shape}</strong></div>
                <div class="order-detail-row"><span>🍦 Flavour</span><strong>${order.flavour}</strong></div>
                <div class="order-detail-row"><span>🎨 Colour</span><strong>${order.colour}</strong></div>
                <div class="order-detail-row"><span>🍓 Toppings</span><strong>${order.toppings}</strong></div>
                <c:if test="${not empty order.message}">
                  <div class="order-detail-row"><span>✍️ Message</span><strong>"${order.message}"</strong></div>
                </c:if>
                <c:if test="${not empty order.photo}">
                  <div class="order-detail-row">
                    <span>📸 Photo</span>
                    <a href="${pageContext.request.contextPath}/${order.photo}" target="_blank" style="color:var(--purple-d)">View Photo</a>
                  </div>
                </c:if>
                <div class="order-detail-row"><span>📅 Delivery Date</span><strong>${order.deliveryDate}</strong></div>
                <div class="order-detail-row"><span>📍 Address</span><strong>${order.deliveryAddress}</strong></div>
                <div class="order-detail-row"><span>🔢 Qty</span><strong>${order.quantity}</strong></div>
                <div class="order-detail-row"><span>💰 Total</span>
                  <strong style="color:var(--purple-d);font-size:1.1rem">₹${order.finalPrice}</strong>
                </div>
              </div>

              <!-- Update Status Form -->
              <form action="${pageContext.request.contextPath}/custom-cake" method="post" class="status-update-form">
                <input type="hidden" name="action" value="updateStatus"/>
                <input type="hidden" name="orderId" value="${order.id}"/>
                <div class="status-form-row">
                  <select name="status" class="filter-select">
                    <option value="pending"       ${order.status=='pending'?'selected':''}>⏳ Pending</option>
                    <option value="owner_review"  ${order.status=='owner_review'?'selected':''}>👀 Under Review</option>
                    <option value="confirmed"     ${order.status=='confirmed'?'selected':''}>✅ Confirmed</option>
                    <option value="preparing"     ${order.status=='preparing'?'selected':''}>👨‍🍳 Preparing</option>
                    <option value="ready"         ${order.status=='ready'?'selected':''}>📦 Ready</option>
                    <option value="delivered"     ${order.status=='delivered'?'selected':''}>🎉 Delivered</option>
                    <option value="cancelled"     ${order.status=='cancelled'?'selected':''}>❌ Cancelled</option>
                  </select>
                  <button type="submit" class="btn btn-primary btn-sm">Update</button>
                </div>
                <textarea name="ownerNotes" class="studio-textarea" rows="2"
                          placeholder="Notes to customer (optional)…">${order.ownerNotes}</textarea>
              </form>
            </div>
          </c:forEach>
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
