<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Compare Suppliers – Scoopora B2B</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    body{background:#f0f2f5;}
    .sc-hero{background:linear-gradient(135deg,#1a1a2e,#0f3460);padding:3rem 2rem;color:#fff;text-align:center;}
    .sc-hero h1{font-size:2.2rem;font-weight:800;margin-bottom:0.5rem;}
    .sc-hero h1 span{color:#FFB3C6;}
    .sc-hero p{font-size:0.95rem;opacity:0.85;max-width:560px;margin:0 auto 1.2rem;}
    .sc-tabs{display:flex;justify-content:center;gap:0.8rem;flex-wrap:wrap;}
    .sc-tab{padding:0.5rem 1.4rem;border-radius:24px;font-size:0.85rem;font-weight:700;cursor:pointer;border:2px solid rgba(255,255,255,0.3);color:rgba(255,255,255,0.8);background:transparent;transition:all 0.2s;text-decoration:none;}
    .sc-tab.active,.sc-tab:hover{background:#fff;color:#1a1a2e;border-color:#fff;}
    .sc-body{max-width:1400px;margin:0 auto;padding:2rem;}
    .sc-filters{background:#fff;border-radius:14px;padding:1.2rem 1.5rem;box-shadow:0 2px 12px rgba(0,0,0,0.07);margin-bottom:1.5rem;}
    .sc-filter-row{display:flex;align-items:flex-end;gap:1rem;flex-wrap:wrap;}
    .sc-fg{display:flex;flex-direction:column;gap:0.3rem;}
    .sc-fg label{font-size:0.75rem;font-weight:700;color:#555;text-transform:uppercase;letter-spacing:0.4px;}
    .sc-fg select,.sc-fg input{border:2px solid #e0e0e0;border-radius:8px;padding:0.5rem 0.8rem;font-size:0.85rem;outline:none;font-family:inherit;min-width:140px;}
    .sc-fg select:focus,.sc-fg input:focus{border-color:#0f3460;}
    .sc-btn{padding:0.55rem 1.2rem;border-radius:20px;font-size:0.82rem;font-weight:700;cursor:pointer;border:none;transition:all 0.2s;}
    .sc-btn-primary{background:#1a1a2e;color:#fff;}
    .sc-btn-primary:hover{background:#0f3460;}
    .sc-btn-outline{background:transparent;border:2px solid #1a1a2e;color:#1a1a2e;}
    .sc-btn-outline:hover{background:#1a1a2e;color:#fff;}
    .sc-btn-sm{padding:0.3rem 0.8rem;font-size:0.75rem;}
    .sc-btn-green{background:#2e7d32;color:#fff;}
    .sc-btn-green:hover{background:#1b5e20;}
    .sc-btn-red{background:#fce4ec;color:#c62828;border:none;}
    .sc-btn-red:hover{background:#c62828;color:#fff;}
    .results-info{font-size:0.85rem;color:#666;margin-bottom:1rem;}
    .compare-wrap{overflow-x:auto;background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,0.07);}
    .compare-table{width:100%;border-collapse:collapse;font-size:0.85rem;min-width:900px;}
    .compare-table thead tr{background:#1a1a2e;}
    .compare-table th{color:rgba(255,255,255,0.85);padding:0.9rem 1rem;text-align:left;font-size:0.78rem;text-transform:uppercase;letter-spacing:0.4px;white-space:nowrap;}
    .compare-table td{padding:0.9rem 1rem;border-bottom:1px solid #f0f0f0;vertical-align:middle;}
    .compare-table tr:last-child td{border-bottom:none;}
    .compare-table tr:hover td{background:#fafafa;}
    .supplier-cell{display:flex;align-items:center;gap:0.7rem;}
    .supplier-thumb{width:36px;height:36px;border-radius:8px;background:#f0f0f0;display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;overflow:hidden;}
    .supplier-thumb img{width:100%;height:100%;object-fit:cover;}
    .supplier-name{font-weight:700;color:#1a1a2e;font-size:0.88rem;}
    .supplier-city{font-size:0.75rem;color:#999;}
    .verified-pill{display:inline-flex;align-items:center;gap:0.25rem;background:#e8f5e9;color:#2e7d32;border-radius:20px;padding:0.15rem 0.55rem;font-size:0.68rem;font-weight:700;}
    .pending-pill{background:#fff3e0;color:#e65100;border-radius:20px;padding:0.15rem 0.55rem;font-size:0.68rem;font-weight:700;}
    .price-cell{font-size:1rem;font-weight:800;color:#0f3460;}
    .stock-ok{color:#2e7d32;font-weight:700;}
    .stock-low{color:#e65100;font-weight:700;}
    .stock-oos{color:#c62828;font-weight:700;}
    .free-delivery{color:#2e7d32;font-weight:700;}
    .compare-checkbox{width:18px;height:18px;cursor:pointer;accent-color:#0f3460;}
    .compare-bar{position:sticky;bottom:0;background:#1a1a2e;color:#fff;padding:0.9rem 1.5rem;display:flex;align-items:center;justify-content:space-between;border-radius:14px 14px 0 0;box-shadow:0 -4px 20px rgba(0,0,0,0.2);transition:all 0.3s;}
    .compare-bar.hidden{display:none;}
    .compare-bar-info{font-size:0.9rem;font-weight:600;}
    .compare-bar-actions{display:flex;gap:0.8rem;}
    .highlight-row td{background:#f0f4ff !important;}
    .best-price-tag{background:#0f3460;color:#fff;border-radius:10px;padding:0.1rem 0.5rem;font-size:0.68rem;font-weight:700;margin-left:0.4rem;}
    .alert-bar{border-radius:10px;padding:0.7rem 1.2rem;font-size:0.85rem;font-weight:600;margin-bottom:1.2rem;}
    .alert-success{background:#e8f5e9;color:#2e7d32;}
    .alert-info{background:#e3f2fd;color:#1565c0;}
    @media(max-width:700px){.sc-filter-row{flex-direction:column;}.sc-fg select,.sc-fg input{min-width:100%;width:100%;}}
  </style>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="sc-hero">
  <h1>Compare <span>Suppliers</span></h1>
  <p>Side-by-side comparison of verified manufacturers, wholesalers, and distributors. Filter, sort, and request quotes instantly.</p>
  <div class="sc-tabs">
    <a href="${pageContext.request.contextPath}/supplier-compare" class="sc-tab ${action != 'my-quotes' ? 'active' : ''}">🔍 Compare Suppliers</a>
    <a href="${pageContext.request.contextPath}/supplier-compare?action=my-quotes" class="sc-tab ${action == 'my-quotes' ? 'active' : ''}">📋 My Quotations</a>
  </div>
</div>

<div class="sc-body">

<c:if test="${param.quoted == 'true'}"><div class="alert-bar alert-success">✅ Quote request submitted! Suppliers will respond shortly.</div></c:if>
<c:if test="${param.offered == 'true'}"><div class="alert-bar alert-success">✅ Your offer has been submitted to the buyer.</div></c:if>
<c:if test="${param.accepted == 'true'}"><div class="alert-bar alert-success">✅ Offer accepted! The supplier will be in touch.</div></c:if>

<%-- ══ COMPARE TAB ══ --%>
<c:if test="${action != 'my-quotes'}">

  <%-- Filters --%>
  <div class="sc-filters">
    <form method="get" action="${pageContext.request.contextPath}/supplier-compare" id="filterForm">
      <div class="sc-filter-row">
        <div class="sc-fg">
          <label>Category</label>
          <select name="category" onchange="document.getElementById('filterForm').submit()">
            <option value="">All Categories</option>
            <option value="tub"            ${selectedCategory=='tub'?'selected':''}>🍦 Ice Cream Tubs</option>
            <option value="carton"         ${selectedCategory=='carton'?'selected':''}>📦 Cartons</option>
            <option value="pack"           ${selectedCategory=='pack'?'selected':''}>🎁 Packs</option>
            <option value="cone_supply"    ${selectedCategory=='cone_supply'?'selected':''}>🍦 Cone Supply</option>
            <option value="cup_supply"     ${selectedCategory=='cup_supply'?'selected':''}>🥤 Cup Supply</option>
            <option value="topping"        ${selectedCategory=='topping'?'selected':''}>🍫 Toppings</option>
            <option value="event_package"  ${selectedCategory=='event_package'?'selected':''}>🎉 Event Packages</option>
            <option value="dessert_supply" ${selectedCategory=='dessert_supply'?'selected':''}>🍮 Dessert Supply</option>
          </select>
        </div>
        <div class="sc-fg">
          <label>Sort By</label>
          <select name="sort" onchange="document.getElementById('filterForm').submit()">
            <option value="">Supplier Name</option>
            <option value="price_asc"   ${selectedSort=='price_asc'?'selected':''}>Price: Low → High</option>
            <option value="price_desc"  ${selectedSort=='price_desc'?'selected':''}>Price: High → Low</option>
            <option value="moq_asc"     ${selectedSort=='moq_asc'?'selected':''}>MOQ: Low → High</option>
            <option value="stock_desc"  ${selectedSort=='stock_desc'?'selected':''}>Stock: High → Low</option>
          </select>
        </div>
        <div class="sc-fg">
          <label>Max Price (₹)</label>
          <input type="number" name="maxPrice" value="${filterMaxPrice}" placeholder="e.g. 2000" min="0"/>
        </div>
        <div class="sc-fg">
          <label>Max MOQ</label>
          <input type="number" name="maxMoq" value="${filterMaxMoq}" placeholder="e.g. 10" min="1"/>
        </div>
        <div class="sc-fg">
          <label>Min Stock</label>
          <input type="number" name="minStock" value="${filterMinStock}" placeholder="e.g. 20" min="0"/>
        </div>
        <div class="sc-fg">
          <label>Verified Only</label>
          <select name="verified" onchange="document.getElementById('filterForm').submit()">
            <option value="">All Suppliers</option>
            <option value="true" ${filterVerified=='true'?'selected':''}>✔ Verified Only</option>
          </select>
        </div>
        <button type="submit" class="sc-btn sc-btn-primary">Apply</button>
        <a href="${pageContext.request.contextPath}/supplier-compare" class="sc-btn sc-btn-outline">Reset</a>
      </div>
    </form>
  </div>

  <div class="results-info">${compareRows.size()} supplier listing<c:if test="${compareRows.size() != 1}">s</c:if> found</div>

  <c:choose>
    <c:when test="${empty compareRows}">
      <div style="text-align:center;padding:4rem;color:#999;background:#fff;border-radius:14px;">
        <div style="font-size:3rem">🔍</div>
        <p style="margin-top:0.8rem;font-size:1rem;">No suppliers match your filters. Try adjusting them.</p>
      </div>
    </c:when>
    <c:otherwise>
      <%-- Find best price for highlight --%>
      <c:set var="bestPrice" value="999999999"/>
      <c:forEach var="r" items="${compareRows}">
        <c:if test="${r.wholesalePrice < bestPrice}"><c:set var="bestPrice" value="${r.wholesalePrice}"/></c:if>
      </c:forEach>

      <div class="compare-wrap">
        <table class="compare-table" id="compareTable">
          <thead>
            <tr>
              <th><input type="checkbox" id="selectAll" title="Select all" onchange="toggleAll(this)"/></th>
              <th>Supplier</th>
              <th>Verification</th>
              <th>Product</th>
              <th>Pack Size</th>
              <th>Wholesale Price</th>
              <th>MOQ</th>
              <th>Stock</th>
              <th>Delivery Charge</th>
              <th>Est. Delivery</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="r" items="${compareRows}">
              <tr class="${r.wholesalePrice == bestPrice ? 'highlight-row' : ''}" data-id="${r.srcType}-${r.productId}">
                <td><input type="checkbox" class="compare-checkbox row-check" value="${r.srcType}-${r.productId}" onchange="updateCompareBar()"/></td>
                <td>
                  <div class="supplier-cell">
                    <div class="supplier-thumb">
                      <c:choose>
                        <c:when test="${not empty r.imageUrl}"><img src="${pageContext.request.contextPath}/${r.imageUrl}" alt=""/></c:when>
                        <c:otherwise>🏭</c:otherwise>
                      </c:choose>
                    </div>
                    <div>
                      <div class="supplier-name">${r.supplierName}</div>
                      <div class="supplier-city">📍 ${r.supplierCity}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${r.verificationStatus == 'verified'}"><span class="verified-pill">✔ Verified</span></c:when>
                    <c:otherwise><span class="pending-pill">⏳ Pending</span></c:otherwise>
                  </c:choose>
                </td>
                <td style="font-weight:700;color:#1a1a2e;">${r.productName}</td>
                <td style="color:#555;">${r.packSize}</td>
                <td>
                  <span class="price-cell">₹<fmt:formatNumber value="${r.wholesalePrice}" pattern="#,##0.00"/></span>
                  <c:if test="${r.wholesalePrice == bestPrice}"><span class="best-price-tag">Best</span></c:if>
                </td>
                <td style="font-weight:700;">${r.moq}</td>
                <td>
                  <c:choose>
                    <c:when test="${r.stock == 0}"><span class="stock-oos">Out of Stock</span></c:when>
                    <c:when test="${r.stock <= 20}"><span class="stock-low">${r.stock} left</span></c:when>
                    <c:otherwise><span class="stock-ok">${r.stock}</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${r.deliveryCharge == 0}"><span class="free-delivery">Free</span></c:when>
                    <c:otherwise>₹<fmt:formatNumber value="${r.deliveryCharge}" pattern="#,##0"/></c:otherwise>
                  </c:choose>
                </td>
                <td style="color:#555;font-size:0.82rem;">${not empty r.deliveryTime ? r.deliveryTime : '—'}</td>
                <td>
                  <button class="sc-btn sc-btn-primary sc-btn-sm"
                    onclick="openQuoteModal('${r.productName}','${r.packSize}')">Request Quote</button>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <%-- Sticky compare bar --%>
      <div class="compare-bar hidden" id="compareBar">
        <div class="compare-bar-info"><span id="compareCount">0</span> suppliers selected for comparison</div>
        <div class="compare-bar-actions">
          <button class="sc-btn sc-btn-outline" style="color:#fff;border-color:#fff;" onclick="clearCompare()">Clear</button>
          <button class="sc-btn" style="background:#FFB3C6;color:#1a1a2e;" onclick="showSideBySide()">Side-by-Side View</button>
        </div>
      </div>
    </c:otherwise>
  </c:choose>

  <%-- Request a Quote Section --%>
  <div style="margin-top:2.5rem;background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,0.07);overflow:hidden;">
    <div style="background:#1a1a2e;padding:1.2rem 1.5rem;">
      <div style="font-size:1.1rem;font-weight:800;color:#FFB3C6;">📋 Request a Bulk Quote</div>
      <div style="font-size:0.82rem;color:rgba(255,255,255,0.7);margin-top:0.2rem;">Send your requirements to all relevant suppliers and compare their offers</div>
    </div>
    <div style="padding:1.5rem;">
      <c:choose>
        <c:when test="${empty sessionScope.user}">
          <div style="text-align:center;padding:2rem;color:#666;">
            <p>Please <a href="${pageContext.request.contextPath}/login.jsp" style="color:#0f3460;font-weight:700;">login</a> to request a quote.</p>
          </div>
        </c:when>
        <c:otherwise>
          <form method="post" action="${pageContext.request.contextPath}/supplier-compare" id="quoteForm">
            <input type="hidden" name="action" value="request_quote"/>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
              <div class="sc-fg"><label>Your Name *</label><input type="text" name="requester_name" id="qfName" required/></div>
              <div class="sc-fg"><label>Email *</label><input type="email" name="requester_email" id="qfEmail" required/></div>
              <div class="sc-fg"><label>Company Name</label><input type="text" name="requester_company"/></div>
              <div class="sc-fg"><label>Product Required *</label><input type="text" name="product_name" id="qfProduct" required placeholder="e.g. Vanilla Ice Cream Tub"/></div>
              <div class="sc-fg"><label>Quantity *</label><input type="number" name="quantity" min="1" required placeholder="e.g. 50"/></div>
              <div class="sc-fg"><label>Preferred Pack Size</label><input type="text" name="preferred_pack_size" id="qfPack" placeholder="e.g. 4L tub"/></div>
              <div class="sc-fg"><label>Delivery Location *</label><input type="text" name="delivery_location" required placeholder="City, State"/></div>
              <div class="sc-fg"><label>Required Delivery Date</label><input type="date" name="required_delivery_date"/></div>
            </div>
            <div class="sc-fg" style="margin-top:0.5rem;">
              <label>Additional Requirements</label>
              <textarea name="additional_requirements" rows="3" style="border:2px solid #e0e0e0;border-radius:8px;padding:0.6rem 0.8rem;font-size:0.88rem;outline:none;font-family:inherit;resize:vertical;width:100%;" placeholder="Flavour preferences, certifications needed, cold chain requirements..."></textarea>
            </div>
            <button type="submit" class="sc-btn sc-btn-primary" style="margin-top:0.5rem;">📤 Send Quote Request to Suppliers</button>
          </form>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

</c:if>

<%-- ══ MY QUOTATIONS TAB ══ --%>
<c:if test="${action == 'my-quotes'}">

  <%-- BUYER: My Requests + Offers --%>
  <c:if test="${not empty sessionScope.user}">
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:1.2rem;">
      <div style="font-size:1.2rem;font-weight:800;color:#1a1a2e;">My Quote Requests</div>
    </div>
    <c:choose>
      <c:when test="${empty myRequests}">
        <div style="text-align:center;padding:3rem;background:#fff;border-radius:14px;color:#999;">
          <div style="font-size:2.5rem;">📋</div>
          <p style="margin-top:0.8rem;">No quote requests yet. <a href="${pageContext.request.contextPath}/supplier-compare" style="color:#0f3460;font-weight:700;">Request a quote</a> from the compare page.</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="qr" items="${myRequests}">
          <div style="background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,0.07);margin-bottom:1.5rem;overflow:hidden;">
            <div style="background:#f8f9fa;padding:1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #f0f0f0;">
              <div>
                <span style="font-weight:800;color:#1a1a2e;">${qr.productName}</span>
                <span style="margin-left:1rem;font-size:0.82rem;color:#666;">Qty: ${qr.quantity} · ${qr.preferredPackSize} · ${qr.deliveryLocation}</span>
                <c:if test="${not empty qr.requiredDeliveryDate}">
                  <span style="margin-left:0.8rem;font-size:0.8rem;color:#666;">By: <fmt:formatDate value="${qr.requiredDeliveryDate}" pattern="dd MMM yyyy"/></span>
                </c:if>
              </div>
              <span style="padding:0.2rem 0.8rem;border-radius:20px;font-size:0.75rem;font-weight:700;
                background:${qr.status=='open'?'#e3f2fd':'#e8f5e9'};
                color:${qr.status=='open'?'#1565c0':'#2e7d32'};">${qr.status}</span>
            </div>
            <div style="padding:1.2rem 1.5rem;">
              <c:choose>
                <c:when test="${empty qr.offers}">
                  <p style="color:#999;font-size:0.88rem;">⏳ Waiting for supplier offers...</p>
                </c:when>
                <c:otherwise>
                  <div style="font-size:0.82rem;font-weight:700;color:#555;margin-bottom:0.8rem;text-transform:uppercase;letter-spacing:0.4px;">${qr.offers.size()} Offer(s) Received — sorted by price</div>
                  <div style="overflow-x:auto;">
                    <table style="width:100%;border-collapse:collapse;font-size:0.85rem;min-width:700px;">
                      <thead><tr style="background:#f0f4ff;">
                        <th style="padding:0.7rem 1rem;text-align:left;font-size:0.75rem;text-transform:uppercase;color:#555;">Supplier</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Verification</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Unit Price</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Pack Size</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Delivery</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Est. Time</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Status</th>
                        <th style="padding:0.7rem 1rem;text-align:left;">Action</th>
                      </tr></thead>
                      <tbody>
                        <c:forEach var="off" items="${qr.offers}" varStatus="vs">
                          <tr style="border-bottom:1px solid #f5f5f5;${vs.index==0?'background:#f0fff4;':''}">
                            <td style="padding:0.8rem 1rem;font-weight:700;">
                              ${off.supplierName}
                              <c:if test="${vs.index==0}"><span style="background:#2e7d32;color:#fff;border-radius:10px;padding:0.1rem 0.5rem;font-size:0.68rem;font-weight:700;margin-left:0.4rem;">Best</span></c:if>
                              <div style="font-size:0.75rem;color:#999;">${off.supplierCity}</div>
                            </td>
                            <td style="padding:0.8rem 1rem;">
                              <c:choose>
                                <c:when test="${off.verificationStatus=='verified'}"><span class="verified-pill">✔ Verified</span></c:when>
                                <c:otherwise><span class="pending-pill">⏳ Pending</span></c:otherwise>
                              </c:choose>
                            </td>
                            <td style="padding:0.8rem 1rem;font-weight:800;color:#0f3460;">₹<fmt:formatNumber value="${off.unitPrice}" pattern="#,##0.00"/></td>
                            <td style="padding:0.8rem 1rem;color:#555;">${off.packSize}</td>
                            <td style="padding:0.8rem 1rem;">
                              <c:choose>
                                <c:when test="${off.deliveryCharge==0}"><span style="color:#2e7d32;font-weight:700;">Free</span></c:when>
                                <c:otherwise>₹<fmt:formatNumber value="${off.deliveryCharge}" pattern="#,##0"/></c:otherwise>
                              </c:choose>
                            </td>
                            <td style="padding:0.8rem 1rem;font-size:0.82rem;color:#555;">${off.estimatedDelivery}</td>
                            <td style="padding:0.8rem 1rem;">
                              <c:choose>
                                <c:when test="${off.status=='accepted'}"><span style="background:#e8f5e9;color:#2e7d32;border-radius:20px;padding:0.2rem 0.7rem;font-size:0.72rem;font-weight:700;">✔ Accepted</span></c:when>
                                <c:when test="${off.status=='rejected'}"><span style="background:#fce4ec;color:#c62828;border-radius:20px;padding:0.2rem 0.7rem;font-size:0.72rem;font-weight:700;">✖ Rejected</span></c:when>
                                <c:otherwise><span style="background:#fff3e0;color:#e65100;border-radius:20px;padding:0.2rem 0.7rem;font-size:0.72rem;font-weight:700;">Pending</span></c:otherwise>
                              </c:choose>
                            </td>
                            <td style="padding:0.8rem 1rem;">
                              <c:if test="${off.status=='pending' && qr.status=='open'}">
                                <form method="post" action="${pageContext.request.contextPath}/supplier-compare" style="display:inline;">
                                  <input type="hidden" name="action" value="accept_offer"/>
                                  <input type="hidden" name="offer_id" value="${off.id}"/>
                                  <input type="hidden" name="request_id" value="${qr.id}"/>
                                  <button type="submit" class="sc-btn sc-btn-green sc-btn-sm">✔ Accept</button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/supplier-compare" style="display:inline;margin-left:0.4rem;">
                                  <input type="hidden" name="action" value="reject_offer"/>
                                  <input type="hidden" name="offer_id" value="${off.id}"/>
                                  <button type="submit" class="sc-btn sc-btn-red sc-btn-sm">✖ Reject</button>
                                </form>
                              </c:if>
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </c:if>

  <%-- SUPPLIER: Open Requests to Respond To --%>
  <c:if test="${not empty sessionScope.businessAccount}">
    <div style="margin-top:2rem;font-size:1.2rem;font-weight:800;color:#1a1a2e;margin-bottom:1.2rem;">Open Quote Requests from Buyers</div>
    <c:choose>
      <c:when test="${empty openRequests}">
        <div style="text-align:center;padding:3rem;background:#fff;border-radius:14px;color:#999;">
          <div style="font-size:2.5rem;">📭</div>
          <p style="margin-top:0.8rem;">No open quote requests at the moment.</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="qr" items="${openRequests}">
          <div style="background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,0.07);margin-bottom:1.2rem;padding:1.3rem 1.5rem;">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:1rem;flex-wrap:wrap;">
              <div>
                <div style="font-weight:800;color:#1a1a2e;font-size:1rem;">${qr.productName}</div>
                <div style="font-size:0.82rem;color:#666;margin-top:0.3rem;">
                  Qty: <strong>${qr.quantity}</strong> ·
                  Pack: <strong>${not empty qr.preferredPackSize ? qr.preferredPackSize : 'Any'}</strong> ·
                  Deliver to: <strong>${qr.deliveryLocation}</strong>
                  <c:if test="${not empty qr.requiredDeliveryDate}"> · By: <strong><fmt:formatDate value="${qr.requiredDeliveryDate}" pattern="dd MMM yyyy"/></strong></c:if>
                </div>
                <c:if test="${not empty qr.additionalReqs}">
                  <div style="font-size:0.8rem;color:#888;margin-top:0.3rem;">📝 ${qr.additionalReqs}</div>
                </c:if>
                <div style="font-size:0.78rem;color:#aaa;margin-top:0.3rem;">From: ${qr.requesterName} · ${qr.requesterCompany}</div>
              </div>
              <c:choose>
                <c:when test="${qr.alreadyOffered}">
                  <span style="background:#e8f5e9;color:#2e7d32;border-radius:20px;padding:0.3rem 1rem;font-size:0.8rem;font-weight:700;white-space:nowrap;">✔ Offer Submitted</span>
                </c:when>
                <c:otherwise>
                  <button class="sc-btn sc-btn-primary" onclick="openOfferModal(${qr.id},'${qr.productName}','${qr.preferredPackSize}')">Submit Offer</button>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </c:if>

  <c:if test="${empty sessionScope.user && empty sessionScope.businessAccount}">
    <div style="text-align:center;padding:3rem;background:#fff;border-radius:14px;color:#666;">
      <p>Please <a href="${pageContext.request.contextPath}/login.jsp" style="color:#0f3460;font-weight:700;">login as a buyer</a> or <a href="${pageContext.request.contextPath}/business-login.jsp" style="color:#0f3460;font-weight:700;">login as a supplier</a> to view quotations.</p>
    </div>
  </c:if>

</c:if>

</div><%-- end sc-body --%>

<%-- Side-by-Side Modal --%>
<div style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:3000;align-items:center;justify-content:center;padding:1rem;" id="sideBySideModal">
  <div style="background:#fff;border-radius:16px;width:100%;max-width:900px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:1.2rem 1.5rem;border-bottom:1px solid #f0f0f0;position:sticky;top:0;background:#fff;">
      <span style="font-size:1rem;font-weight:800;color:#1a1a2e;">Side-by-Side Comparison</span>
      <button onclick="document.getElementById('sideBySideModal').style.display='none'" style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:#999;">✕</button>
    </div>
    <div style="padding:1.5rem;overflow-x:auto;">
      <table id="sideBySideTable" style="width:100%;border-collapse:collapse;font-size:0.85rem;"></table>
    </div>
  </div>
</div>

<%-- Request Quote Modal (pre-filled from table button) --%>
<div style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:2000;align-items:center;justify-content:center;padding:1rem;" id="quoteModal">
  <div style="background:#fff;border-radius:16px;width:100%;max-width:500px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:1.2rem 1.5rem;border-bottom:1px solid #f0f0f0;">
      <span style="font-size:1rem;font-weight:800;color:#1a1a2e;">Request a Quote</span>
      <button onclick="document.getElementById('quoteModal').style.display='none'" style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:#999;">✕</button>
    </div>
    <div style="padding:1.5rem;">
      <c:choose>
        <c:when test="${empty sessionScope.user}">
          <p style="text-align:center;color:#666;">Please <a href="${pageContext.request.contextPath}/login.jsp" style="color:#0f3460;font-weight:700;">login</a> to request a quote.</p>
        </c:when>
        <c:otherwise>
          <form method="post" action="${pageContext.request.contextPath}/supplier-compare">
            <input type="hidden" name="action" value="request_quote"/>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.8rem;">
              <div class="sc-fg"><label>Your Name *</label><input type="text" name="requester_name" required/></div>
              <div class="sc-fg"><label>Email *</label><input type="email" name="requester_email" required/></div>
              <div class="sc-fg"><label>Company</label><input type="text" name="requester_company"/></div>
              <div class="sc-fg"><label>Product *</label><input type="text" name="product_name" id="modalQfProduct" required/></div>
              <div class="sc-fg"><label>Quantity *</label><input type="number" name="quantity" min="1" required/></div>
              <div class="sc-fg"><label>Pack Size</label><input type="text" name="preferred_pack_size" id="modalQfPack"/></div>
              <div class="sc-fg"><label>Delivery Location *</label><input type="text" name="delivery_location" required/></div>
              <div class="sc-fg"><label>Required By</label><input type="date" name="required_delivery_date"/></div>
            </div>
            <div class="sc-fg" style="margin-top:0.5rem;">
              <label>Additional Requirements</label>
              <textarea name="additional_requirements" rows="2" style="border:2px solid #e0e0e0;border-radius:8px;padding:0.6rem;font-size:0.85rem;outline:none;font-family:inherit;resize:vertical;width:100%;"></textarea>
            </div>
            <button type="submit" class="sc-btn sc-btn-primary" style="margin-top:0.8rem;width:100%;">📤 Send Quote Request</button>
          </form>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<%-- Submit Offer Modal (supplier) --%>
<div style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:2000;align-items:center;justify-content:center;padding:1rem;" id="offerModal">
  <div style="background:#fff;border-radius:16px;width:100%;max-width:480px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:1.2rem 1.5rem;border-bottom:1px solid #f0f0f0;">
      <span style="font-size:1rem;font-weight:800;color:#1a1a2e;">Submit Your Offer</span>
      <button onclick="document.getElementById('offerModal').style.display='none'" style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:#999;">✕</button>
    </div>
    <div style="padding:1.5rem;">
      <form method="post" action="${pageContext.request.contextPath}/supplier-compare">
        <input type="hidden" name="action" value="submit_offer"/>
        <input type="hidden" name="request_id" id="offerRequestId"/>
        <div style="background:#f0f4ff;border-radius:8px;padding:0.8rem;margin-bottom:1rem;font-size:0.85rem;color:#1a1a2e;">
          Responding to: <strong id="offerProductName"></strong>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.8rem;">
          <div class="sc-fg"><label>Unit Price (₹) *</label><input type="number" name="unit_price" step="0.01" min="0" required/></div>
          <div class="sc-fg"><label>Pack Size</label><input type="text" name="pack_size" id="offerPackSize"/></div>
          <div class="sc-fg"><label>Delivery Charge (₹)</label><input type="number" name="delivery_charge" step="0.01" min="0" value="0"/></div>
          <div class="sc-fg"><label>Estimated Delivery</label><input type="text" name="estimated_delivery" placeholder="e.g. 3-5 days"/></div>
        </div>
        <div class="sc-fg" style="margin-top:0.5rem;">
          <label>Notes</label>
          <textarea name="notes" rows="2" style="border:2px solid #e0e0e0;border-radius:8px;padding:0.6rem;font-size:0.85rem;outline:none;font-family:inherit;resize:vertical;width:100%;" placeholder="Terms, conditions, minimum quantities..."></textarea>
        </div>
        <button type="submit" class="sc-btn sc-btn-primary" style="margin-top:0.8rem;width:100%;">Submit Offer</button>
      </form>
    </div>
  </div>
</div>

<%@ include file="footer.jsp" %>
<script>
// ── Compare checkbox logic ────────────────────────────────────────────────────
const selectedRows = new Map();

function toggleAll(cb) {
  document.querySelectorAll('.row-check').forEach(c => { c.checked = cb.checked; });
  updateCompareBar();
}

function updateCompareBar() {
  selectedRows.clear();
  document.querySelectorAll('.row-check:checked').forEach(c => {
    const row = c.closest('tr');
    selectedRows.set(c.value, row);
  });
  const bar = document.getElementById('compareBar');
  const count = selectedRows.size;
  document.getElementById('compareCount').textContent = count;
  bar.classList.toggle('hidden', count < 2);
}

function clearCompare() {
  document.querySelectorAll('.row-check').forEach(c => c.checked = false);
  document.getElementById('selectAll').checked = false;
  selectedRows.clear();
  document.getElementById('compareBar').classList.add('hidden');
}

// ── Side-by-side view ─────────────────────────────────────────────────────────
function showSideBySide() {
  const headers = ['Supplier','Verification','Product','Pack Size','Price','MOQ','Stock','Delivery','Est. Time'];
  const colIndexes = [1,2,3,4,5,6,7,8,9]; // td indexes in main table

  let html = '<tr style="background:#1a1a2e;">';
  html += '<td style="padding:0.7rem 1rem;color:rgba(255,255,255,0.7);font-size:0.75rem;font-weight:700;text-transform:uppercase;"></td>';
  selectedRows.forEach((row, key) => {
    html += '<td style="padding:0.7rem 1rem;color:#FFB3C6;font-size:0.82rem;font-weight:700;text-align:center;">Supplier ' + (Array.from(selectedRows.keys()).indexOf(key)+1) + '</td>';
  });
  html += '</tr>';

  headers.forEach((h, i) => {
    html += '<tr style="border-bottom:1px solid #f0f0f0;">';
    html += '<td style="padding:0.7rem 1rem;font-size:0.78rem;font-weight:700;color:#555;text-transform:uppercase;background:#f8f9fa;white-space:nowrap;">' + h + '</td>';
    selectedRows.forEach(row => {
      const td = row.querySelectorAll('td')[colIndexes[i]];
      html += '<td style="padding:0.7rem 1rem;text-align:center;">' + (td ? td.innerHTML : '—') + '</td>';
    });
    html += '</tr>';
  });

  document.getElementById('sideBySideTable').innerHTML = html;
  document.getElementById('sideBySideModal').style.display = 'flex';
}

// ── Quote modal pre-fill ──────────────────────────────────────────────────────
function openQuoteModal(product, packSize) {
  const el = document.getElementById('modalQfProduct');
  const pk = document.getElementById('modalQfPack');
  if (el) el.value = product;
  if (pk) pk.value = packSize;
  document.getElementById('quoteModal').style.display = 'flex';
}

// ── Offer modal ───────────────────────────────────────────────────────────────
function openOfferModal(requestId, productName, packSize) {
  document.getElementById('offerRequestId').value = requestId;
  document.getElementById('offerProductName').textContent = productName;
  const pk = document.getElementById('offerPackSize');
  if (pk) pk.value = packSize || '';
  document.getElementById('offerModal').style.display = 'flex';
}

// Close modals on backdrop click
['sideBySideModal','quoteModal','offerModal'].forEach(id => {
  const el = document.getElementById(id);
  if (el) el.addEventListener('click', e => { if (e.target === el) el.style.display = 'none'; });
});
</script>
</body>
</html>
