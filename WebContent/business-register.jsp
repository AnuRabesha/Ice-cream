<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Business Registration – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    .b-auth-page { min-height:100vh; background:linear-gradient(135deg,#1a1a2e,#0f3460); display:flex; align-items:center; justify-content:center; padding:2rem; }
    .b-auth-card { background:#fff; border-radius:20px; padding:2.5rem; width:100%; max-width:620px; box-shadow:0 20px 60px rgba(0,0,0,0.3); }
    .b-auth-logo { text-align:center; font-size:2.2rem; margin-bottom:0.3rem; }
    .b-auth-title { text-align:center; font-size:1.5rem; font-weight:800; color:var(--choco); margin-bottom:0.2rem; }
    .b-auth-sub { text-align:center; color:var(--gray); font-size:0.85rem; margin-bottom:1.8rem; }
    .type-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:0.8rem; margin-bottom:1.5rem; }
    .type-option input[type=radio] { display:none; }
    .type-option label { display:block; text-align:center; padding:1rem 0.5rem; border:2px solid var(--lavender); border-radius:12px; cursor:pointer; transition:all 0.2s; }
    .type-option label .type-icon { font-size:1.8rem; display:block; margin-bottom:0.3rem; }
    .type-option label .type-name { font-size:0.82rem; font-weight:700; color:var(--choco); }
    .type-option label .type-desc { font-size:0.72rem; color:var(--gray); margin-top:0.2rem; }
    .type-option input:checked + label { border-color:#0f3460; background:#f0f4ff; }
    .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
    .form-group { margin-bottom:0.9rem; }
    .form-group label { display:block; font-size:0.8rem; font-weight:600; color:var(--choco); margin-bottom:0.35rem; }
    .form-group input, .form-group textarea, .form-group select { width:100%; padding:0.65rem 0.9rem; border-radius:10px; border:2px solid var(--lavender); font-size:0.88rem; outline:none; font-family:inherit; transition:border-color 0.2s; }
    .form-group input:focus, .form-group textarea:focus { border-color:#0f3460; }
    .form-group textarea { resize:vertical; min-height:70px; }
    .section-label { font-size:0.78rem; font-weight:700; color:#0f3460; text-transform:uppercase; letter-spacing:0.5px; margin:1.2rem 0 0.8rem; padding-bottom:0.4rem; border-bottom:2px solid #e8eaf6; }
    .b-auth-btn { width:100%; padding:0.85rem; border-radius:28px; border:none; background:linear-gradient(135deg,#1a1a2e,#0f3460); color:#fff; font-size:1rem; font-weight:700; cursor:pointer; transition:opacity 0.2s; margin-top:0.5rem; }
    .b-auth-btn:hover { opacity:0.88; }
    .auth-link { text-align:center; margin-top:1rem; font-size:0.85rem; color:var(--gray); }
    .auth-link a { color:#0f3460; font-weight:700; }
    .alert-error { background:#fce4ec; color:#c62828; border-radius:10px; padding:0.7rem 1rem; font-size:0.85rem; margin-bottom:1rem; }
    .note-box { background:#e8eaf6; border-radius:10px; padding:0.8rem 1rem; font-size:0.8rem; color:#3949ab; margin-bottom:1.2rem; }
    @media(max-width:600px){ .form-grid{grid-template-columns:1fr;} .type-grid{grid-template-columns:1fr;} }
  </style>
</head>
<body>
<div class="b-auth-page">
  <div class="b-auth-card">
    <div class="b-auth-logo">🏭</div>
    <div class="b-auth-title">Business Registration</div>
    <div class="b-auth-sub">Join Scoopora's B2B network as a manufacturer, wholesaler, or distributor</div>

    <c:if test="${not empty error}">
      <div class="alert-error">⚠️ ${error}</div>
    </c:if>

    <div class="note-box">📋 Your account will be reviewed within 1–2 business days. A verified badge will appear on your profile once approved.</div>

    <form action="${pageContext.request.contextPath}/business/auth" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="register"/>

      <div class="section-label">Business Type</div>
      <div class="type-grid">
        <div class="type-option">
          <input type="radio" name="business_type" id="typeManufacturer" value="manufacturer" checked/>
          <label for="typeManufacturer">
            <span class="type-icon">🏭</span>
            <span class="type-name">Manufacturer</span>
            <span class="type-desc">Produce ice cream &amp; frozen desserts</span>
          </label>
        </div>
        <div class="type-option">
          <input type="radio" name="business_type" id="typeWholesaler" value="wholesaler"/>
          <label for="typeWholesaler">
            <span class="type-icon">🏪</span>
            <span class="type-name">Wholesaler</span>
            <span class="type-desc">Bulk supply to retailers &amp; shops</span>
          </label>
        </div>
        <div class="type-option">
          <input type="radio" name="business_type" id="typeDistributor" value="distributor"/>
          <label for="typeDistributor">
            <span class="type-icon">🚚</span>
            <span class="type-name">Distributor</span>
            <span class="type-desc">Regional distribution &amp; logistics</span>
          </label>
        </div>
      </div>

      <div class="section-label">Contact Information</div>
      <div class="form-grid">
        <div class="form-group">
          <label>Contact Person Name *</label>
          <input type="text" name="contact_name" placeholder="Your full name" required/>
        </div>
        <div class="form-group">
          <label>Business Name *</label>
          <input type="text" name="business_name" placeholder="Company / brand name" required/>
        </div>
        <div class="form-group">
          <label>Email Address *</label>
          <input type="email" name="email" placeholder="business@example.com" required/>
        </div>
        <div class="form-group">
          <label>Phone Number *</label>
          <input type="tel" name="phone" placeholder="+91 98000 00000" required/>
        </div>
        <div class="form-group">
          <label>Password *</label>
          <input type="password" name="password" placeholder="Min. 6 characters" minlength="6" required/>
        </div>
        <div class="form-group">
          <label>Website</label>
          <input type="url" name="website" placeholder="https://yourcompany.com"/>
        </div>
      </div>

      <div class="section-label">Business Address</div>
      <div class="form-group">
        <label>Street Address *</label>
        <input type="text" name="address" placeholder="Building, street, area" required/>
      </div>
      <div class="form-grid">
        <div class="form-group">
          <label>City *</label>
          <input type="text" name="city" placeholder="City" required/>
        </div>
        <div class="form-group">
          <label>State *</label>
          <input type="text" name="state" placeholder="State" required/>
        </div>
        <div class="form-group">
          <label>PIN Code</label>
          <input type="text" name="pincode" placeholder="400001"/>
        </div>
        <div class="form-group">
          <label>GST Number</label>
          <input type="text" name="gst_number" placeholder="22AAAAA0000A1Z5"/>
        </div>
        <div class="form-group">
          <label>PAN Number</label>
          <input type="text" name="pan_number" placeholder="AAAAA0000A"/>
        </div>
      </div>

      <div class="section-label">About Your Business</div>
      <div class="form-group">
        <label>Business Description</label>
        <textarea name="description" placeholder="Describe your products, capacity, and what makes your business unique..."></textarea>
      </div>

      <button class="b-auth-btn" type="submit">Submit for Verification →</button>
    </form>

    <div class="auth-link">
      Already registered? <a href="${pageContext.request.contextPath}/business-login.jsp">Login here</a>
    </div>
    <div class="auth-link" style="margin-top:0.4rem">
      <a href="${pageContext.request.contextPath}/home">← Back to Scoopora</a>
    </div>
  </div>
</div>
</body>
</html>
