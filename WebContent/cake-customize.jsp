<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Customize ${cake.name} – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cakes.css"/>
</head>
<body>
<%@ include file="navbar.jsp" %>

<!-- Breadcrumb -->
<div style="background:var(--white);padding:0.8rem 2rem;border-bottom:1px solid #f0e8ff">
  <div style="max-width:1300px;margin:0 auto;font-size:0.85rem;color:var(--gray)">
    <a href="${pageContext.request.contextPath}/home" style="color:var(--purple-d)">Home</a> /
    <a href="${pageContext.request.contextPath}/cakes" style="color:var(--purple-d)">Cakes</a> /
    <span>${cake.name}</span>
  </div>
</div>

<!-- Studio Header -->
<div class="studio-hero">
  <div class="studio-hero-inner">
    <div class="studio-cake-preview" id="cakePreview">
      <div class="preview-cake-icon" id="previewIcon">
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
      <div class="preview-summary" id="previewSummary">
        <div class="preview-title" id="previewName">${cake.name}</div>
        <div class="preview-detail" id="previewFlavour">Flavour: ${cake.baseFlavour}</div>
        <div class="preview-detail" id="previewSize">Size: —</div>
        <div class="preview-detail" id="previewShape">Shape: —</div>
        <div class="preview-detail" id="previewColour">Colour: —</div>
        <div class="preview-detail" id="previewToppings">Toppings: None</div>
        <div class="preview-detail" id="previewMessage">Message: —</div>
      </div>
      <div class="preview-price-box">
        <div class="preview-price-label">Your Price</div>
        <div class="preview-price" id="livePrice">₹<fmt:formatNumber value="${cake.basePrice}" maxFractionDigits="0"/></div>
        <div class="preview-price-note">Final price updates as you customize</div>
      </div>
    </div>
    <div class="studio-hero-info">
      <div class="studio-title">${cake.name}</div>
      <div class="studio-type-badge cake-type-${cake.cakeType}">
        <c:choose>
          <c:when test="${cake.cakeType == 'birthday'}">🎂 Birthday Cake</c:when>
          <c:when test="${cake.cakeType == 'wedding'}">💍 Wedding Cake</c:when>
          <c:when test="${cake.cakeType == 'photo'}">📸 Photo Cake</c:when>
          <c:when test="${cake.cakeType == 'chocolate'}">🍫 Chocolate Cake</c:when>
          <c:when test="${cake.cakeType == 'cartoon'}">🦄 Cartoon Cake</c:when>
          <c:when test="${cake.cakeType == 'heart'}">❤️ Heart Cake</c:when>
          <c:when test="${cake.cakeType == 'anniversary'}">🥂 Anniversary Cake</c:when>
          <c:when test="${cake.cakeType == 'designer'}">✨ Designer Cake</c:when>
          <c:otherwise>🎨 Custom Cake</c:otherwise>
        </c:choose>
      </div>
      <div class="studio-desc">${cake.description}</div>
      <div class="studio-meta">
        <span>📚 ${cake.layers} Layer<c:if test="${cake.layers > 1}">s</c:if></span>
        <span>🍦 Base: ${cake.baseFlavour}</span>
        <c:if test="${cake.supportsPhoto}"><span>📸 Photo Upload Supported</span></c:if>
      </div>
    </div>
  </div>
</div>

<!-- Customization Form -->
<div class="studio-body">
  <form action="${pageContext.request.contextPath}/custom-cake" method="post"
        enctype="multipart/form-data" id="cakeForm">
    <input type="hidden" name="designId" value="${cake.id}"/>
    <input type="hidden" name="finalPrice" id="finalPriceInput" value="${cake.basePrice}"/>

    <div class="studio-grid">
      <!-- LEFT: All customization steps -->
      <div class="studio-steps">

        <!-- Step 1: Shop Selection -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">1</span> Choose Shop</div>
          <div class="step-body">
            <select name="shopId" class="studio-select" required id="shopSelect">
              <option value="">— Select a shop —</option>
              <c:forEach var="shop" items="${shops}">
                <option value="${shop.id}">${shop.name} (${shop.city})</option>
              </c:forEach>
            </select>
          </div>
        </div>

        <!-- Step 2: Size -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">2</span> Choose Size / Weight</div>
          <div class="step-body">
            <div class="option-chips" id="sizeChips">
              <c:forEach var="sizeEntry" items="${cake.availableSizes.split(',')}" varStatus="st">
                <c:set var="sp" value="${sizeEntry.split(':')}"/>
                <label class="option-chip <c:if test="${st.first}">selected</c:if>">
                  <input type="radio" name="size" value="${sp[0]}"
                         data-price="${sp[1]}" <c:if test="${st.first}">checked</c:if>
                         onchange="updatePreview()"/>
                  <span class="chip-label">${sp[0]}</span>
                  <span class="chip-price">₹${sp[1]}</span>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>

        <!-- Step 3: Shape -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">3</span> Choose Shape</div>
          <div class="step-body">
            <div class="option-chips">
              <c:forEach var="shape" items="${cake.availableShapes.split(',')}" varStatus="st">
                <label class="option-chip <c:if test="${st.first}">selected</c:if>">
                  <input type="radio" name="shape" value="${shape}"
                         <c:if test="${st.first}">checked</c:if> onchange="updatePreview()"/>
                  <span class="chip-label">
                    <c:choose>
                      <c:when test="${shape.trim() == 'Round'}">⭕ Round</c:when>
                      <c:when test="${shape.trim() == 'Square'}">⬛ Square</c:when>
                      <c:when test="${shape.trim() == 'Heart'}">❤️ Heart</c:when>
                      <c:when test="${shape.trim() == 'Rectangle'}">▬ Rectangle</c:when>
                      <c:otherwise>${shape}</c:otherwise>
                    </c:choose>
                  </span>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>

        <!-- Step 4: Flavour -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">4</span> Choose Ice Cream Flavour</div>
          <div class="step-body">
            <div class="option-chips">
              <c:forEach var="flav" items="${cake.availableFlavours.split(',')}" varStatus="st">
                <label class="option-chip <c:if test="${st.first}">selected</c:if>">
                  <input type="radio" name="flavour" value="${flav}"
                         <c:if test="${st.first}">checked</c:if> onchange="updatePreview()"/>
                  <span class="chip-label">${flav}</span>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>

        <!-- Step 5: Colour Theme -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">5</span> Choose Colour Theme</div>
          <div class="step-body">
            <div class="colour-chips" id="colourChips">
              <c:forEach var="col" items="${cake.availableColours.split(',')}" varStatus="st">
                <label class="colour-chip <c:if test="${st.first}">selected</c:if>"
                       title="${col}">
                  <input type="radio" name="colour" value="${col}"
                         <c:if test="${st.first}">checked</c:if> onchange="updatePreview()"/>
                  <span class="colour-dot" data-colour="${col}"></span>
                  <span class="colour-name">${col}</span>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>

        <!-- Step 6: Toppings -->
        <div class="studio-step">
          <div class="step-header">
            <span class="step-num">6</span> Choose Toppings
            <span class="step-note">(₹50 each)</span>
          </div>
          <div class="step-body">
            <div class="topping-chips">
              <c:forEach var="top" items="${cake.availableToppings.split(',')}">
                <label class="topping-chip">
                  <input type="checkbox" name="toppings" value="${top}" onchange="updatePreview()"/>
                  <span>${top}</span>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>

        <!-- Step 7: Custom Message -->
        <div class="studio-step">
          <div class="step-header"><span class="step-num">7</span> Custom Name / Message</div>
          <div class="step-body">
            <input type="text" name="message" id="messageInput" maxlength="60"
                   placeholder="e.g. Happy Birthday Sarah! 🎉"
                   class="studio-input" oninput="updatePreview()"/>
            <div class="char-count"><span id="msgLen">0</span>/60 characters</div>
          </div>
        </div>

        <!-- Step 8: Photo Upload (if supported) -->
        <c:if test="${cake.supportsPhoto}">
          <div class="studio-step">
            <div class="step-header"><span class="step-num">8</span> Upload Photo
              <span class="step-note">(+₹200, JPG/PNG max 5MB)</span>
            </div>
            <div class="step-body">
              <div class="photo-upload-area" id="photoUploadArea">
                <input type="file" name="photoFile" id="photoFile" accept="image/*"
                       onchange="handlePhotoPreview(this)"/>
                <label for="photoFile" class="photo-upload-label">
                  <span id="photoUploadText">📷 Click to upload your photo</span>
                </label>
                <img id="photoPreviewImg" src="" alt="" style="display:none;max-height:120px;border-radius:8px;margin-top:0.5rem"/>
              </div>
            </div>
          </div>
        </c:if>

        <!-- Step 9: Extra Decorations -->
        <div class="studio-step">
          <div class="step-header">
            <c:choose><c:when test="${cake.supportsPhoto}">9</c:when><c:otherwise>8</c:otherwise></c:choose>
            . Extra Decorations / Notes
          </div>
          <div class="step-body">
            <textarea name="extras" class="studio-textarea" rows="2"
                      placeholder="e.g. Add sparklers, extra candles, specific decoration requests…"></textarea>
          </div>
        </div>

        <!-- Step 10: Quantity -->
        <div class="studio-step">
          <div class="step-header">Quantity</div>
          <div class="step-body">
            <div class="qty-control">
              <button type="button" class="qty-btn" onclick="changeQty(-1)">−</button>
              <input type="number" name="qty" id="qtyInput" value="1" min="1" max="10"
                     class="qty-input" onchange="updatePreview()"/>
              <button type="button" class="qty-btn" onclick="changeQty(1)">+</button>
            </div>
          </div>
        </div>

        <!-- Step 11: Delivery -->
        <div class="studio-step">
          <div class="step-header">Delivery Details</div>
          <div class="step-body">
            <div class="delivery-grid">
              <div>
                <label class="studio-label">Delivery Date</label>
                <input type="date" name="deliveryDate" class="studio-input" required
                       min="${pageContext.request.getAttribute('minDate')}"/>
              </div>
              <div>
                <label class="studio-label">Delivery Address</label>
                <input type="text" name="address" class="studio-input" required
                       placeholder="Full delivery address"/>
              </div>
            </div>
            <label class="studio-label" style="margin-top:0.8rem">Special Notes for Shop</label>
            <textarea name="notes" class="studio-textarea" rows="2"
                      placeholder="Allergy info, timing requirements, etc."></textarea>
          </div>
        </div>

      </div><!-- end studio-steps -->

      <!-- RIGHT: Sticky Order Summary -->
      <div class="studio-sidebar">
        <div class="order-summary-card" id="orderSummary">
          <div class="summary-title">📋 Order Summary</div>

          <div class="summary-row"><span>Design</span><span id="sumDesign">${cake.name}</span></div>
          <div class="summary-row"><span>Size</span><span id="sumSize">—</span></div>
          <div class="summary-row"><span>Shape</span><span id="sumShape">—</span></div>
          <div class="summary-row"><span>Flavour</span><span id="sumFlavour">${cake.baseFlavour}</span></div>
          <div class="summary-row"><span>Colour</span><span id="sumColour">—</span></div>
          <div class="summary-row"><span>Toppings</span><span id="sumToppings">None</span></div>
          <div class="summary-row"><span>Message</span><span id="sumMessage">—</span></div>
          <div class="summary-row"><span>Quantity</span><span id="sumQty">1</span></div>
          <div class="summary-divider"></div>
          <div class="summary-row summary-total">
            <span>Total Price</span>
            <span id="sumTotal">₹<fmt:formatNumber value="${cake.basePrice}" maxFractionDigits="0"/></span>
          </div>

          <button type="submit" class="btn-place-order" id="placeOrderBtn">
            🎂 Place Cake Order
          </button>
          <div class="order-note">
            Your order will be sent to the shop owner for review and confirmation.
            You'll receive a status update within 24 hours.
          </div>
        </div>
      </div>

    </div><!-- end studio-grid -->
  </form>
</div>

<div class="toast" id="toast"></div>
<%@ include file="footer.jsp" %>

<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
const CTX   = '${pageContext.request.contextPath}';
const DESIGN_ID = ${cake.id};
let debounceTimer;

// Set min delivery date to 3 days from now
const minDate = new Date();
minDate.setDate(minDate.getDate() + 3);
document.querySelector('input[name="deliveryDate"]').min =
  minDate.toISOString().split('T')[0];

// Colour dot colours map
const colourMap = {
  'Pink':'#FFB3C6','White':'#FFFFFF','Chocolate Brown':'#5C3317',
  'Blue':'#4A90D9','Purple':'#9B59B6','Gold':'#FFD700',
  'Rainbow':'linear-gradient(135deg,red,orange,yellow,green,blue,purple)',
  'Red':'#E53935','Black':'#212121','Silver':'#9E9E9E',
  'Champagne':'#F7E7CE','Ivory':'#FFFFF0','Blush Pink':'#FFB6C1',
  'Sage Green':'#8FBC8F','Peach':'#FFCBA4','Lilac':'#C8A2C8',
  'Rose Gold':'#B76E79','Teal':'#008080','Custom':'var(--lavender)'
};

document.querySelectorAll('.colour-dot').forEach(dot => {
  const c = dot.dataset.colour;
  if (colourMap[c]) {
    if (colourMap[c].startsWith('linear')) dot.style.background = colourMap[c];
    else dot.style.backgroundColor = colourMap[c];
    if (c === 'White' || c === 'Ivory' || c === 'Champagne')
      dot.style.border = '2px solid #ddd';
  }
});

// Option chip selection highlight
document.querySelectorAll('.option-chips, .colour-chips').forEach(group => {
  group.querySelectorAll('label').forEach(lbl => {
    lbl.querySelector('input').addEventListener('change', () => {
      group.querySelectorAll('label').forEach(l => l.classList.remove('selected'));
      lbl.classList.add('selected');
    });
  });
});

// Topping chip toggle
document.querySelectorAll('.topping-chip input').forEach(cb => {
  cb.addEventListener('change', function() {
    this.closest('.topping-chip').classList.toggle('selected', this.checked);
  });
});

function changeQty(delta) {
  const inp = document.getElementById('qtyInput');
  let v = parseInt(inp.value) + delta;
  if (v < 1) v = 1; if (v > 10) v = 10;
  inp.value = v;
  updatePreview();
}

function handlePhotoPreview(input) {
  const file = input.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = e => {
    const img = document.getElementById('photoPreviewImg');
    img.src = e.target.result; img.style.display = 'block';
    document.getElementById('photoUploadText').textContent = '✅ ' + file.name;
  };
  reader.readAsDataURL(file);
  updatePreview();
}

function updatePreview() {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(doUpdate, 300);
}

function doUpdate() {
  const form = document.getElementById('cakeForm');
  const fd   = new FormData(form);

  const size    = fd.get('size')    || '—';
  const shape   = fd.get('shape')   || '—';
  const flavour = fd.get('flavour') || '—';
  const colour  = fd.get('colour')  || '—';
  const message = fd.get('message') || '—';
  const qty     = parseInt(fd.get('qty')) || 1;
  const tops    = fd.getAll('toppings');
  const hasPhoto = document.getElementById('photoFile') &&
                   document.getElementById('photoFile').files.length > 0;

  // Update preview panel
  document.getElementById('previewFlavour').textContent  = 'Flavour: ' + flavour;
  document.getElementById('previewSize').textContent     = 'Size: ' + size;
  document.getElementById('previewShape').textContent    = 'Shape: ' + shape;
  document.getElementById('previewColour').textContent   = 'Colour: ' + colour;
  document.getElementById('previewToppings').textContent = 'Toppings: ' + (tops.length ? tops.join(', ') : 'None');
  document.getElementById('previewMessage').textContent  = 'Message: ' + message;

  // Update summary sidebar
  document.getElementById('sumSize').textContent    = size;
  document.getElementById('sumShape').textContent   = shape;
  document.getElementById('sumFlavour').textContent = flavour;
  document.getElementById('sumColour').textContent  = colour;
  document.getElementById('sumToppings').textContent= tops.length ? tops.join(', ') : 'None';
  document.getElementById('sumMessage').textContent = message;
  document.getElementById('sumQty').textContent     = qty;

  // Message char count
  const msg = fd.get('message') || '';
  document.getElementById('msgLen').textContent = msg.length;

  // Fetch live price from backend
  const params = new URLSearchParams({
    action: 'price', designId: DESIGN_ID,
    size: size, toppings: tops.length,
    photo: hasPhoto, qty: qty
  });
  fetch(CTX + '/cakes?' + params)
    .then(r => r.json())
    .then(data => {
      const p = data.price || 0;
      document.getElementById('livePrice').textContent  = '₹' + p.toFixed(0);
      document.getElementById('sumTotal').textContent   = '₹' + p.toFixed(0);
      document.getElementById('finalPriceInput').value  = p.toFixed(2);
    })
    .catch(() => {});
}

// Init on load
document.addEventListener('DOMContentLoaded', () => {
  doUpdate();
  // Validate shop selected before submit
  document.getElementById('cakeForm').addEventListener('submit', function(e) {
    if (!document.getElementById('shopSelect').value) {
      e.preventDefault();
      showToast('⚠️ Please select a shop first!');
    }
  });
});
</script>
</body>
</html>
