<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Business Dashboard – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    body{background:#f0f2f5;}
    .bd-layout{display:grid;grid-template-columns:240px 1fr;min-height:100vh;}
    .bd-sidebar{background:#1a1a2e;color:#fff;padding:1.5rem 0;position:sticky;top:0;height:100vh;overflow-y:auto;}
    .bd-brand{padding:0 1.5rem 1.5rem;border-bottom:1px solid rgba(255,255,255,0.1);}
    .bd-brand-logo{font-size:1.8rem;font-weight:800;color:#FFB3C6;}
    .bd-brand-sub{font-size:0.72rem;opacity:0.6;margin-top:0.2rem;}
    .bd-biz-info{padding:1.2rem 1.5rem;border-bottom:1px solid rgba(255,255,255,0.1);}
    .bd-biz-logo{width:48px;height:48px;border-radius:10px;background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;font-size:1.5rem;margin-bottom:0.6rem;overflow:hidden;}
    .bd-biz-logo img{width:100%;height:100%;object-fit:cover;}
    .bd-biz-name{font-size:0.9rem;font-weight:700;}
    .bd-biz-type{font-size:0.72rem;opacity:0.6;text-transform:capitalize;margin-top:0.1rem;}
    .verified-badge{display:inline-flex;align-items:center;gap:0.3rem;background:#1b5e20;color:#a5d6a7;border-radius:20px;padding:0.15rem 0.6rem;font-size:0.68rem;font-weight:700;margin-top:0.4rem;}
    .pending-badge{display:inline-flex;align-items:center;gap:0.3rem;background:#e65100;color:#ffe0b2;border-radius:20px;padding:0.15rem 0.6rem;font-size:0.68rem;font-weight:700;margin-top:0.4rem;}
    .rejected-badge{display:inline-flex;align-items:center;gap:0.3rem;background:#b71c1c;color:#ffcdd2;border-radius:20px;padding:0.15rem 0.6rem;font-size:0.68rem;font-weight:700;margin-top:0.4rem;}
    .bd-nav{padding:1rem 0;}
    .bd-nav-item{display:flex;align-items:center;gap:0.8rem;padding:0.7rem 1.5rem;font-size:0.85rem;font-weight:600;color:rgba(255,255,255,0.7);cursor:pointer;transition:all 0.2s;text-decoration:none;}
    .bd-nav-item:hover,.bd-nav-item.active{background:rgba(255,255,255,0.1);color:#fff;}
    .bd-nav-item.active{border-left:3px solid #FFB3C6;}
    .bd-nav-icon{font-size:1.1rem;width:20px;text-align:center;}
    .bd-logout{margin:1rem 1.5rem 0;}
    .bd-logout a{display:block;text-align:center;padding:0.6rem;border-radius:10px;background:rgba(255,255,255,0.08);color:rgba(255,255,255,0.7);font-size:0.82rem;font-weight:600;transition:all 0.2s;}
    .bd-logout a:hover{background:rgba(255,255,255,0.15);color:#fff;}
    .bd-main{padding:2rem;overflow-y:auto;}
    .bd-topbar{display:flex;align-items:center;justify-content:space-between;margin-bottom:2rem;}
    .bd-page-title{font-size:1.4rem;font-weight:800;color:#1a1a2e;}
    .bd-page-sub{font-size:0.85rem;color:var(--gray);margin-top:0.2rem;}
    .stat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:1.2rem;margin-bottom:2rem;}
    .stat-card{background:#fff;border-radius:14px;padding:1.3rem;box-shadow:0 2px 12px rgba(0,0,0,0.07);}
    .stat-icon{font-size:1.8rem;margin-bottom:0.5rem;}
    .stat-val{font-size:1.6rem;font-weight:800;color:#1a1a2e;}
    .stat-label{font-size:0.78rem;color:var(--gray);margin-top:0.2rem;}
    .bd-card{background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,0.07);margin-bottom:1.5rem;}
    .bd-card-header{display:flex;align-items:center;justify-content:space-between;padding:1.2rem 1.5rem;border-bottom:1px solid #f0f0f0;}
    .bd-card-title{font-size:1rem;font-weight:800;color:#1a1a2e;}
    .bd-card-body{padding:1.5rem;}
    .bd-table{width:100%;border-collapse:collapse;font-size:0.85rem;}
    .bd-table th{background:#f8f9fa;color:#555;font-weight:700;padding:0.8rem 1rem;text-align:left;font-size:0.78rem;text-transform:uppercase;letter-spacing:0.4px;}
    .bd-table td{padding:0.85rem 1rem;border-bottom:1px solid #f5f5f5;vertical-align:middle;}
    .bd-table tr:last-child td{border-bottom:none;}
    .bd-table tr:hover td{background:#fafafa;}
    .status-pill{display:inline-block;padding:0.2rem 0.7rem;border-radius:20px;font-size:0.72rem;font-weight:700;text-transform:capitalize;}
    .sp-pending{background:#fff3e0;color:#e65100;}
    .sp-accepted{background:#e8f5e9;color:#2e7d32;}
    .sp-rejected{background:#fce4ec;color:#c62828;}
    .sp-processing{background:#e3f2fd;color:#1565c0;}
    .sp-shipped{background:#f3e5f5;color:#6a1b9a;}
    .sp-delivered{background:#e8f5e9;color:#1b5e20;}
    .sp-cancelled{background:#fce4ec;color:#b71c1c;}
    .sp-draft{background:#f5f5f5;color:#555;}
    .sp-sent{background:#e3f2fd;color:#1565c0;}
    .sp-paid{background:#e8f5e9;color:#2e7d32;}
    .sp-overdue{background:#fce4ec;color:#c62828;}
    .sp-quotation{background:#f3e5f5;color:#6a1b9a;}
    .bd-btn{display:inline-flex;align-items:center;gap:0.4rem;padding:0.5rem 1.1rem;border-radius:20px;font-size:0.8rem;font-weight:700;cursor:pointer;border:none;transition:all 0.2s;}
    .bd-btn-primary{background:#1a1a2e;color:#fff;}
    .bd-btn-primary:hover{background:#0f3460;}
    .bd-btn-outline{background:transparent;border:2px solid #1a1a2e;color:#1a1a2e;}
    .bd-btn-outline:hover{background:#1a1a2e;color:#fff;}
    .bd-btn-sm{padding:0.3rem 0.8rem;font-size:0.75rem;}
    .bd-btn-danger{background:#fce4ec;color:#c62828;border:none;}
    .bd-btn-danger:hover{background:#c62828;color:#fff;}
    .form-row-2{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
    .form-row-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:1rem;}
    .fg{display:flex;flex-direction:column;gap:0.3rem;margin-bottom:0.9rem;}
    .fg label{font-size:0.8rem;font-weight:600;color:#333;}
    .fg input,.fg textarea,.fg select{border:2px solid #e0e0e0;border-radius:8px;padding:0.6rem 0.8rem;font-size:0.88rem;outline:none;font-family:inherit;transition:border-color 0.2s;width:100%;}
    .fg input:focus,.fg textarea:focus,.fg select:focus{border-color:#0f3460;}
    .fg textarea{resize:vertical;min-height:70px;}
    .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:2000;align-items:center;justify-content:center;padding:1rem;}
    .modal-overlay.open{display:flex;}
    .modal{background:#fff;border-radius:16px;width:100%;max-width:560px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);}
    .modal-header{display:flex;justify-content:space-between;align-items:center;padding:1.2rem 1.5rem;border-bottom:1px solid #f0f0f0;position:sticky;top:0;background:#fff;z-index:1;}
    .modal-title{font-size:1rem;font-weight:800;color:#1a1a2e;}
    .modal-close{background:none;border:none;font-size:1.2rem;cursor:pointer;color:#999;padding:0.2rem 0.5rem;border-radius:50%;}
    .modal-close:hover{background:#fce4ec;color:#e53935;}
    .modal-body{padding:1.5rem;}
    .modal-footer{display:flex;gap:0.8rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid #f0f0f0;position:sticky;bottom:0;background:#fff;}
    .alert-success-bar{background:#e8f5e9;color:#2e7d32;border-radius:10px;padding:0.7rem 1rem;font-size:0.85rem;margin-bottom:1.2rem;}
    .prod-img-thumb{width:40px;height:40px;border-radius:8px;object-fit:cover;background:#f0f0f0;}
    .avail-on{color:#2e7d32;font-weight:700;}
    .avail-off{color:#c62828;font-weight:700;}
    .verification-banner{border-radius:12px;padding:1rem 1.5rem;margin-bottom:1.5rem;font-size:0.88rem;font-weight:600;}
    .vb-pending{background:#fff3e0;color:#e65100;border-left:4px solid #ff9800;}
    .vb-verified{background:#e8f5e9;color:#2e7d32;border-left:4px solid #4caf50;}
    .vb-rejected{background:#fce4ec;color:#c62828;border-left:4px solid #f44336;}
    @media(max-width:900px){.bd-layout{grid-template-columns:1fr;}.bd-sidebar{height:auto;position:static;}.stat-grid{grid-template-columns:1fr 1fr;}}
    @media(max-width:600px){.stat-grid{grid-template-columns:1fr;}.form-row-2,.form-row-3{grid-template-columns:1fr;}}
  </style>
</head>
<body>
<div class="bd-layout">

  <%-- SIDEBAR --%>
  <aside class="bd-sidebar">
    <div class="bd-brand">
      <div class="bd-brand-logo">🍦 Scoopora</div>
      <div class="bd-brand-sub">Business Portal</div>
    </div>
    <div class="bd-biz-info">
      <div class="bd-biz-logo">
        <c:choose>
          <c:when test="${not empty businessAccount.logoUrl}">
            <img src="${pageContext.request.contextPath}/${businessAccount.logoUrl}" alt="logo"/>
          </c:when>
          <c:otherwise>🏭</c:otherwise>
        </c:choose>
      </div>
      <div class="bd-biz-name">${businessAccount.businessName}</div>
      <div class="bd-biz-type">${businessAccount.businessType}</div>
      <c:choose>
        <c:when test="${businessAccount.verificationStatus == 'verified'}">
          <span class="verified-badge">✔ Verified</span>
        </c:when>
        <c:when test="${businessAccount.verificationStatus == 'rejected'}">
          <span class="rejected-badge">✖ Rejected</span>
        </c:when>
        <c:otherwise>
          <span class="pending-badge">⏳ Pending Review</span>
        </c:otherwise>
      </c:choose>
    </div>
    <nav class="bd-nav">
      <a href="?tab=overview"  class="bd-nav-item ${tab=='overview'  ? 'active' : ''}"><span class="bd-nav-icon">📊</span> Overview</a>
      <a href="?tab=products"  class="bd-nav-item ${tab=='products'  ? 'active' : ''}"><span class="bd-nav-icon">📦</span> Products</a>
      <a href="?tab=orders"    class="bd-nav-item ${tab=='orders'    ? 'active' : ''}"><span class="bd-nav-icon">🛒</span> Orders</a>
      <a href="?tab=invoices"  class="bd-nav-item ${tab=='invoices'  ? 'active' : ''}"><span class="bd-nav-icon">🧾</span> Invoices</a>
      <a href="?tab=profile"   class="bd-nav-item ${tab=='profile'   ? 'active' : ''}"><span class="bd-nav-icon">⚙️</span> Profile</a>
    </nav>
    <div class="bd-logout">
      <form action="${pageContext.request.contextPath}/business/auth" method="post">
        <input type="hidden" name="action" value="logout"/>
        <button type="submit" style="width:100%;padding:0.6rem;border-radius:10px;background:rgba(255,255,255,0.08);color:rgba(255,255,255,0.7);font-size:0.82rem;font-weight:600;border:none;cursor:pointer;">🚪 Logout</button>
      </form>
    </div>
  </aside>

  <%-- MAIN CONTENT --%>
  <main class="bd-main">

    <%-- Verification Banner --%>
    <c:choose>
      <c:when test="${businessAccount.verificationStatus == 'verified'}">
        <div class="verification-banner vb-verified">✔ Your business is verified. Your verified badge is now visible to buyers.</div>
      </c:when>
      <c:when test="${businessAccount.verificationStatus == 'rejected'}">
        <div class="verification-banner vb-rejected">✖ Verification rejected. ${businessAccount.verificationNotes} Please contact support.</div>
      </c:when>
      <c:otherwise>
        <div class="verification-banner vb-pending">⏳ Your account is under review. You can set up your profile and products while you wait. Verified badge will appear once approved.</div>
      </c:otherwise>
    </c:choose>

    <c:if test="${param.saved == 'true'}">
      <div class="alert-success-bar">✅ Changes saved successfully.</div>
    </c:if>

    <%-- ══ OVERVIEW TAB ══ --%>
    <c:if test="${tab == 'overview'}">
      <div class="bd-topbar">
        <div>
          <div class="bd-page-title">Welcome, ${businessAccount.contactName}!</div>
          <div class="bd-page-sub">${businessAccount.businessName} · ${businessAccount.city}</div>
        </div>
      </div>
      <div class="stat-grid">
        <div class="stat-card"><div class="stat-icon">🛒</div><div class="stat-val">${statTotalOrders}</div><div class="stat-label">Total Orders</div></div>
        <div class="stat-card"><div class="stat-icon">⏳</div><div class="stat-val">${statPendingOrders}</div><div class="stat-label">Pending Orders</div></div>
        <div class="stat-card"><div class="stat-icon">📦</div><div class="stat-val">${statActiveProducts}</div><div class="stat-label">Active Products</div></div>
        <div class="stat-card"><div class="stat-icon">💰</div><div class="stat-val">₹<fmt:formatNumber value="${statRevenue}" pattern="#,##0"/></div><div class="stat-label">Total Revenue</div></div>
      </div>

      <%-- Recent Orders --%>
      <div class="bd-card">
        <div class="bd-card-header">
          <span class="bd-card-title">Recent Orders</span>
          <a href="?tab=orders" class="bd-btn bd-btn-outline bd-btn-sm">View All</a>
        </div>
        <div style="overflow-x:auto;">
          <table class="bd-table">
            <thead><tr><th>#</th><th>Buyer</th><th>Product</th><th>Qty</th><th>Amount</th><th>Type</th><th>Status</th></tr></thead>
            <tbody>
              <c:forEach var="o" items="${orders}" end="4">
                <tr>
                  <td>#${o.id}</td>
                  <td>${o.buyerName}<br/><small style="color:#999">${o.buyerCompany}</small></td>
                  <td>${o.productName}</td>
                  <td>${o.quantity}</td>
                  <td>₹<fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/></td>
                  <td><span class="status-pill sp-${o.orderType}">${o.orderType}</span></td>
                  <td><span class="status-pill sp-${o.status}">${o.status}</span></td>
                </tr>
              </c:forEach>
              <c:if test="${empty orders}"><tr><td colspan="7" style="text-align:center;color:#999;padding:2rem;">No orders yet.</td></tr></c:if>
            </tbody>
          </table>
        </div>
      </div>
    </c:if>

    <%-- ══ PRODUCTS TAB ══ --%>
    <c:if test="${tab == 'products'}">
      <div class="bd-topbar">
        <div><div class="bd-page-title">Products</div><div class="bd-page-sub">Manage your product catalogue</div></div>
        <button class="bd-btn bd-btn-primary" onclick="document.getElementById('addProductModal').classList.add('open')">+ Add Product</button>
      </div>
      <div class="bd-card">
        <div style="overflow-x:auto;">
          <table class="bd-table">
            <thead><tr><th>Image</th><th>Name</th><th>Category</th><th>Pack Size</th><th>Price</th><th>MOQ</th><th>Stock</th><th>Available</th><th>Actions</th></tr></thead>
            <tbody>
              <c:forEach var="p" items="${products}">
                <tr>
                  <td><c:choose><c:when test="${not empty p.imageUrl}"><img src="${pageContext.request.contextPath}/${p.imageUrl}" class="prod-img-thumb" alt=""/></c:when><c:otherwise><div class="prod-img-thumb" style="display:flex;align-items:center;justify-content:center;">🍦</div></c:otherwise></c:choose></td>
                  <td style="font-weight:700">${p.name}</td>
                  <td>${p.category}</td>
                  <td>${p.packSize}</td>
                  <td>₹<fmt:formatNumber value="${p.wholesalePrice}" pattern="#,##0.00"/></td>
                  <td>${p.moq}</td>
                  <td>${p.stock}</td>
                  <td><c:choose><c:when test="${p.isAvailable}"><span class="avail-on">✔ Yes</span></c:when><c:otherwise><span class="avail-off">✖ No</span></c:otherwise></c:choose></td>
                  <td>
                    <button class="bd-btn bd-btn-outline bd-btn-sm" onclick="openEditProduct(${p.id},'${p.name}','${p.category}','${p.packSize}',${p.wholesalePrice},${p.moq},${p.stock},${p.isAvailable},'${p.description}')">Edit</button>
                    <form method="post" action="${pageContext.request.contextPath}/business/dashboard" style="display:inline" onsubmit="return confirm('Delete this product?')">
                      <input type="hidden" name="action" value="delete_product"/>
                      <input type="hidden" name="product_id" value="${p.id}"/>
                      <input type="hidden" name="redirect_tab" value="products"/>
                      <button type="submit" class="bd-btn bd-btn-danger bd-btn-sm">Delete</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty products}"><tr><td colspan="9" style="text-align:center;color:#999;padding:2rem;">No products yet. Add your first product!</td></tr></c:if>
            </tbody>
          </table>
        </div>
      </div>

      <%-- Add Product Modal --%>
      <div class="modal-overlay" id="addProductModal">
        <div class="modal">
          <div class="modal-header">
            <span class="modal-title">Add New Product</span>
            <button class="modal-close" onclick="document.getElementById('addProductModal').classList.remove('open')">✕</button>
          </div>
          <form method="post" action="${pageContext.request.contextPath}/business/dashboard" enctype="multipart/form-data">
            <input type="hidden" name="action" value="add_product"/>
            <input type="hidden" name="redirect_tab" value="products"/>
            <div class="modal-body">
              <div class="form-row-2">
                <div class="fg"><label>Product Name *</label><input type="text" name="name" required/></div>
                <div class="fg"><label>Category</label><input type="text" name="category" placeholder="e.g. Ice Cream Tub"/></div>
              </div>
              <div class="fg"><label>Description</label><textarea name="description"></textarea></div>
              <div class="form-row-2">
                <div class="fg"><label>Pack Size *</label><input type="text" name="pack_size" placeholder="e.g. 4L tub, carton of 24" required/></div>
                <div class="fg"><label>Wholesale Price (₹) *</label><input type="number" name="wholesale_price" step="0.01" min="0" required/></div>
              </div>
              <div class="form-row-2">
                <div class="fg"><label>Min. Order Qty (MOQ) *</label><input type="number" name="moq" min="1" value="1" required/></div>
                <div class="fg"><label>Stock *</label><input type="number" name="stock" min="0" value="0" required/></div>
              </div>
              <div class="fg"><label>Product Image</label><input type="file" name="image" accept="image/*"/></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="bd-btn bd-btn-outline" onclick="document.getElementById('addProductModal').classList.remove('open')">Cancel</button>
              <button type="submit" class="bd-btn bd-btn-primary">Add Product</button>
            </div>
          </form>
        </div>
      </div>

      <%-- Edit Product Modal --%>
      <div class="modal-overlay" id="editProductModal">
        <div class="modal">
          <div class="modal-header">
            <span class="modal-title">Edit Product</span>
            <button class="modal-close" onclick="document.getElementById('editProductModal').classList.remove('open')">✕</button>
          </div>
          <form method="post" action="${pageContext.request.contextPath}/business/dashboard" enctype="multipart/form-data">
            <input type="hidden" name="action" value="update_product"/>
            <input type="hidden" name="redirect_tab" value="products"/>
            <input type="hidden" name="product_id" id="editProdId"/>
            <div class="modal-body">
              <div class="form-row-2">
                <div class="fg"><label>Product Name *</label><input type="text" name="name" id="editProdName" required/></div>
                <div class="fg"><label>Category</label><input type="text" name="category" id="editProdCat"/></div>
              </div>
              <div class="fg"><label>Description</label><textarea name="description" id="editProdDesc"></textarea></div>
              <div class="form-row-2">
                <div class="fg"><label>Pack Size *</label><input type="text" name="pack_size" id="editProdPack" required/></div>
                <div class="fg"><label>Wholesale Price (₹) *</label><input type="number" name="wholesale_price" id="editProdPrice" step="0.01" min="0" required/></div>
              </div>
              <div class="form-row-2">
                <div class="fg"><label>MOQ *</label><input type="number" name="moq" id="editProdMoq" min="1" required/></div>
                <div class="fg"><label>Stock *</label><input type="number" name="stock" id="editProdStock" min="0" required/></div>
              </div>
              <div class="fg"><label style="display:flex;align-items:center;gap:0.5rem;cursor:pointer;"><input type="checkbox" name="is_available" id="editProdAvail"/> Available for orders</label></div>
              <div class="fg"><label>Replace Image</label><input type="file" name="image" accept="image/*"/></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="bd-btn bd-btn-outline" onclick="document.getElementById('editProductModal').classList.remove('open')">Cancel</button>
              <button type="submit" class="bd-btn bd-btn-primary">Save Changes</button>
            </div>
          </form>
        </div>
      </div>
    </c:if>

    <%-- ══ ORDERS TAB ══ --%>
    <c:if test="${tab == 'orders'}">
      <div class="bd-topbar">
        <div><div class="bd-page-title">Orders &amp; Quotations</div><div class="bd-page-sub">Manage incoming bulk orders and quotation requests</div></div>
      </div>
      <div class="bd-card">
        <div style="overflow-x:auto;">
          <table class="bd-table">
            <thead><tr><th>#</th><th>Buyer</th><th>Product</th><th>Qty</th><th>Total</th><th>Type</th><th>Status</th><th>Date</th><th>Action</th></tr></thead>
            <tbody>
              <c:forEach var="o" items="${orders}">
                <tr>
                  <td>#${o.id}</td>
                  <td>
                    <strong>${o.buyerName}</strong><br/>
                    <small style="color:#999">${o.buyerCompany}</small><br/>
                    <small style="color:#999">${o.buyerPhone}</small>
                  </td>
                  <td>${o.productName}</td>
                  <td>${o.quantity}</td>
                  <td>₹<fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/></td>
                  <td><span class="status-pill sp-${o.orderType}">${o.orderType}</span></td>
                  <td><span class="status-pill sp-${o.status}">${o.status}</span></td>
                  <td><fmt:formatDate value="${o.createdAt}" pattern="dd MMM yyyy"/></td>
                  <td>
                    <button class="bd-btn bd-btn-outline bd-btn-sm" onclick="openUpdateOrder(${o.id},'${o.status}','${o.sellerNotes}')">Update</button>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty orders}"><tr><td colspan="9" style="text-align:center;color:#999;padding:2rem;">No orders received yet.</td></tr></c:if>
            </tbody>
          </table>
        </div>
      </div>

      <%-- Update Order Modal --%>
      <div class="modal-overlay" id="updateOrderModal">
        <div class="modal">
          <div class="modal-header">
            <span class="modal-title">Update Order</span>
            <button class="modal-close" onclick="document.getElementById('updateOrderModal').classList.remove('open')">✕</button>
          </div>
          <form method="post" action="${pageContext.request.contextPath}/business/dashboard">
            <input type="hidden" name="action" value="update_order"/>
            <input type="hidden" name="redirect_tab" value="orders"/>
            <input type="hidden" name="order_id" id="updateOrderId"/>
            <div class="modal-body">
              <div class="fg">
                <label>Order Status</label>
                <select name="status" id="updateOrderStatus">
                  <option value="pending">Pending</option>
                  <option value="accepted">Accepted</option>
                  <option value="rejected">Rejected</option>
                  <option value="processing">Processing</option>
                  <option value="shipped">Shipped</option>
                  <option value="delivered">Delivered</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>
              <div class="fg"><label>Notes to Buyer</label><textarea name="seller_notes" id="updateOrderNotes" placeholder="Add any notes for the buyer..."></textarea></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="bd-btn bd-btn-outline" onclick="document.getElementById('updateOrderModal').classList.remove('open')">Cancel</button>
              <button type="submit" class="bd-btn bd-btn-primary">Save</button>
            </div>
          </form>
        </div>
      </div>
    </c:if>

    <%-- ══ INVOICES TAB ══ --%>
    <c:if test="${tab == 'invoices'}">
      <div class="bd-topbar">
        <div><div class="bd-page-title">Invoices</div><div class="bd-page-sub">Create and track invoices for your orders</div></div>
        <button class="bd-btn bd-btn-primary" onclick="document.getElementById('createInvoiceModal').classList.add('open')">+ Create Invoice</button>
      </div>
      <div class="bd-card">
        <div style="overflow-x:auto;">
          <table class="bd-table">
            <thead><tr><th>Invoice #</th><th>Order #</th><th>Buyer</th><th>Amount</th><th>Tax</th><th>Total</th><th>Status</th><th>Due Date</th></tr></thead>
            <tbody>
              <c:forEach var="inv" items="${invoices}">
                <tr>
                  <td style="font-weight:700">${inv.invoiceNumber}</td>
                  <td>#${inv.orderId}</td>
                  <td>${inv.buyerName}<br/><small style="color:#999">${inv.buyerCompany}</small></td>
                  <td>₹<fmt:formatNumber value="${inv.amount}" pattern="#,##0.00"/></td>
                  <td>₹<fmt:formatNumber value="${inv.taxAmount}" pattern="#,##0.00"/></td>
                  <td style="font-weight:800">₹<fmt:formatNumber value="${inv.totalAmount}" pattern="#,##0.00"/></td>
                  <td><span class="status-pill sp-${inv.status}">${inv.status}</span></td>
                  <td><fmt:formatDate value="${inv.dueDate}" pattern="dd MMM yyyy"/></td>
                </tr>
              </c:forEach>
              <c:if test="${empty invoices}"><tr><td colspan="8" style="text-align:center;color:#999;padding:2rem;">No invoices yet.</td></tr></c:if>
            </tbody>
          </table>
        </div>
      </div>

      <div class="modal-overlay" id="createInvoiceModal">
        <div class="modal">
          <div class="modal-header">
            <span class="modal-title">Create Invoice</span>
            <button class="modal-close" onclick="document.getElementById('createInvoiceModal').classList.remove('open')">✕</button>
          </div>
          <form method="post" action="${pageContext.request.contextPath}/business/dashboard">
            <input type="hidden" name="action" value="create_invoice"/>
            <input type="hidden" name="redirect_tab" value="invoices"/>
            <div class="modal-body">
              <div class="fg"><label>Order ID *</label><input type="number" name="order_id" required placeholder="Enter order #"/></div>
              <div class="form-row-2">
                <div class="fg"><label>Amount (₹) *</label><input type="number" name="amount" step="0.01" min="0" required/></div>
                <div class="fg"><label>Tax Amount (₹)</label><input type="number" name="tax_amount" step="0.01" min="0" value="0"/></div>
              </div>
              <div class="fg"><label>Due Date</label><input type="date" name="due_date"/></div>
              <div class="fg"><label>Notes</label><textarea name="notes" placeholder="Payment terms, bank details..."></textarea></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="bd-btn bd-btn-outline" onclick="document.getElementById('createInvoiceModal').classList.remove('open')">Cancel</button>
              <button type="submit" class="bd-btn bd-btn-primary">Create Invoice</button>
            </div>
          </form>
        </div>
      </div>
    </c:if>

    <%-- ══ PROFILE TAB ══ --%>
    <c:if test="${tab == 'profile'}">
      <div class="bd-topbar">
        <div><div class="bd-page-title">Company Profile</div><div class="bd-page-sub">Manage your business details and logo</div></div>
      </div>
      <div class="bd-card">
        <div class="bd-card-body">
          <form method="post" action="${pageContext.request.contextPath}/business/auth" enctype="multipart/form-data">
            <input type="hidden" name="action" value="profile"/>
            <div style="display:flex;align-items:center;gap:1.5rem;margin-bottom:1.5rem;padding-bottom:1.5rem;border-bottom:1px solid #f0f0f0;">
              <div style="width:80px;height:80px;border-radius:14px;overflow:hidden;background:#f0f0f0;display:flex;align-items:center;justify-content:center;font-size:2.5rem;flex-shrink:0;">
                <c:choose>
                  <c:when test="${not empty businessAccount.logoUrl}"><img src="${pageContext.request.contextPath}/${businessAccount.logoUrl}" style="width:100%;height:100%;object-fit:cover;" alt="logo"/></c:when>
                  <c:otherwise>🏭</c:otherwise>
                </c:choose>
              </div>
              <div class="fg" style="flex:1;margin:0;">
                <label>Upload Logo</label>
                <input type="file" name="logo" accept="image/*"/>
                <small style="color:#999;font-size:0.75rem;">Max 5MB. JPG/PNG recommended.</small>
              </div>
            </div>
            <div class="form-row-2">
              <div class="fg"><label>Business Name *</label><input type="text" name="business_name" value="${businessAccount.businessName}" required/></div>
              <div class="fg"><label>Phone</label><input type="text" name="phone" value="${businessAccount.phone}"/></div>
            </div>
            <div class="fg"><label>Address</label><input type="text" name="address" value="${businessAccount.address}"/></div>
            <div class="form-row-3">
              <div class="fg"><label>City</label><input type="text" name="city" value="${businessAccount.city}"/></div>
              <div class="fg"><label>State</label><input type="text" name="state" value="${businessAccount.state}"/></div>
              <div class="fg"><label>PIN Code</label><input type="text" name="pincode" value="${businessAccount.pincode}"/></div>
            </div>
            <div class="fg"><label>Website</label><input type="url" name="website" value="${businessAccount.website}"/></div>
            <div class="fg"><label>Business Description</label><textarea name="description">${businessAccount.description}</textarea></div>
            <div class="form-row-2">
              <div class="fg"><label>Delivery Areas (comma-separated)</label><input type="text" name="delivery_areas" value="${businessAccount.deliveryAreas}" placeholder="Mumbai, Delhi, Pune..."/></div>
              <div class="fg"><label>Estimated Delivery Time</label><input type="text" name="delivery_time" value="${businessAccount.deliveryTime}" placeholder="3-7 business days"/></div>
            </div>
            <div style="display:flex;gap:0.5rem;padding:0.8rem;background:#f8f9fa;border-radius:10px;margin-bottom:1rem;font-size:0.82rem;color:#555;">
              <span>📧 ${businessAccount.email}</span>
              <span style="margin-left:1rem;">🏢 ${businessAccount.businessType}</span>
              <c:if test="${not empty businessAccount.gstNumber}"><span style="margin-left:1rem;">GST: ${businessAccount.gstNumber}</span></c:if>
            </div>
            <button type="submit" class="bd-btn bd-btn-primary">Save Profile</button>
          </form>
        </div>
      </div>
    </c:if>

  </main>
</div>

<script>
function openEditProduct(id, name, cat, pack, price, moq, stock, avail, desc) {
  document.getElementById('editProdId').value    = id;
  document.getElementById('editProdName').value  = name;
  document.getElementById('editProdCat').value   = cat;
  document.getElementById('editProdPack').value  = pack;
  document.getElementById('editProdPrice').value = price;
  document.getElementById('editProdMoq').value   = moq;
  document.getElementById('editProdStock').value = stock;
  document.getElementById('editProdAvail').checked = avail;
  document.getElementById('editProdDesc').value  = desc;
  document.getElementById('editProductModal').classList.add('open');
}
function openUpdateOrder(id, status, notes) {
  document.getElementById('updateOrderId').value = id;
  document.getElementById('updateOrderStatus').value = status;
  document.getElementById('updateOrderNotes').value  = notes || '';
  document.getElementById('updateOrderModal').classList.add('open');
}
document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
  overlay.addEventListener('click', function(e) {
    if (e.target === overlay) overlay.classList.remove('open');
  });
});
</script>
</body>
</html>
