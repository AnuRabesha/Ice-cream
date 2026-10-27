<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Inventory – Scoopora</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="page-hero" style="padding:2rem">
  <h1>📦 Inventory Management</h1>
  <p>Manage stock levels and monitor low-stock alerts</p>
</div>

<div class="section">
  <div class="section-inner">

    <%-- Low-stock notifications --%>
    <c:if test="${not empty notifications}">
      <div class="inv-alerts-panel">
        <div class="inv-alerts-title">
          🔔 Low Stock Alerts
          <span class="inv-alert-count">${notifications.size()}</span>
        </div>
        <c:forEach var="n" items="${notifications}">
          <div class="inv-alert-row">
            <div>
              <span class="inv-alert-name">${n.productName}</span>
              <span class="inv-alert-detail">
                — only <strong>${n.stock}</strong> left
                (threshold: ${n.threshold})
              </span>
            </div>
            <form action="${pageContext.request.contextPath}/inventory" method="post" style="display:inline">
              <input type="hidden" name="action" value="dismissNotification"/>
              <input type="hidden" name="notifId" value="${n.id}"/>
              <button class="inv-dismiss-btn" type="submit" title="Dismiss">✕</button>
            </form>
          </div>
        </c:forEach>
      </div>
    </c:if>

    <%-- Stock table --%>
    <div class="inv-table-wrap">
      <table class="inv-table">
        <thead>
          <tr>
            <th>Product</th>
            <th>Category</th>
            <th>Price</th>
            <th>Current Stock</th>
            <th>Low-Stock Alert At</th>
            <th>Status</th>
            <th>Update</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="p" items="${products}">
            <tr class="${p.outOfStock ? 'inv-row-oos' : p.lowStock ? 'inv-row-low' : ''}">
              <td class="inv-product-name">${p.name}</td>
              <td><span class="inv-cat-badge">${p.category}</span></td>
              <td>₹<fmt:formatNumber value="${p.price}" maxFractionDigits="0"/></td>
              <td>
                <span class="inv-stock-val ${p.outOfStock ? 'stock-oos' : p.lowStock ? 'stock-low' : 'stock-ok'}">
                  ${p.stock}
                </span>
              </td>
              <td>${p.threshold}</td>
              <td>
                <c:choose>
                  <c:when test="${p.outOfStock}"><span class="stock-badge stock-oos">Out of Stock</span></c:when>
                  <c:when test="${p.lowStock}"><span class="stock-badge stock-low">Low Stock</span></c:when>
                  <c:otherwise><span class="stock-badge stock-ok-badge">In Stock</span></c:otherwise>
                </c:choose>
              </td>
              <td>
                <form action="${pageContext.request.contextPath}/inventory" method="post" class="inv-update-form">
                  <input type="hidden" name="action" value="updateStock"/>
                  <input type="hidden" name="productId" value="${p.id}"/>
                  <input type="number" name="stock" value="${p.stock}" min="0" max="9999"
                         class="inv-input" required title="New stock quantity"/>
                  <input type="number" name="threshold" value="${p.threshold}" min="1" max="999"
                         class="inv-input inv-input-sm" required title="Low-stock alert threshold"/>
                  <button type="submit" class="btn btn-primary btn-sm">Save</button>
                </form>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty products}">
            <tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--gray)">No products found.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>

  </div>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
