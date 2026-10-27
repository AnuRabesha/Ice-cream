<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Business Login – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    .b-auth-page { min-height:100vh; background:linear-gradient(135deg,#1a1a2e,#0f3460); display:flex; align-items:center; justify-content:center; padding:2rem; }
    .b-auth-card { background:#fff; border-radius:20px; padding:2.5rem; width:100%; max-width:420px; box-shadow:0 20px 60px rgba(0,0,0,0.3); }
    .b-auth-logo { text-align:center; font-size:2.5rem; margin-bottom:0.3rem; }
    .b-auth-title { text-align:center; font-size:1.6rem; font-weight:800; color:var(--choco); margin-bottom:0.2rem; }
    .b-auth-sub { text-align:center; color:var(--gray); font-size:0.85rem; margin-bottom:1.8rem; }
    .form-group { margin-bottom:1.1rem; }
    .form-group label { display:block; font-size:0.82rem; font-weight:600; color:var(--choco); margin-bottom:0.4rem; }
    .form-group input { width:100%; padding:0.7rem 1rem; border-radius:10px; border:2px solid var(--lavender); font-size:0.9rem; outline:none; font-family:inherit; transition:border-color 0.2s; }
    .form-group input:focus { border-color:#0f3460; }
    .b-auth-btn { width:100%; padding:0.85rem; border-radius:28px; border:none; background:linear-gradient(135deg,#1a1a2e,#0f3460); color:#fff; font-size:1rem; font-weight:700; cursor:pointer; transition:opacity 0.2s; margin-top:0.5rem; }
    .b-auth-btn:hover { opacity:0.88; }
    .auth-link { text-align:center; margin-top:1.2rem; font-size:0.85rem; color:var(--gray); }
    .auth-link a { color:#0f3460; font-weight:700; }
    .alert-error { background:#fce4ec; color:#c62828; border-radius:10px; padding:0.7rem 1rem; font-size:0.85rem; margin-bottom:1rem; }
    .alert-success { background:#e8f5e9; color:#2e7d32; border-radius:10px; padding:0.7rem 1rem; font-size:0.85rem; margin-bottom:1rem; }
    .b2b-types { display:flex; justify-content:center; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap; }
    .b2b-type-badge { background:#e8eaf6; color:#3949ab; border-radius:20px; padding:0.3rem 0.9rem; font-size:0.78rem; font-weight:700; }
  </style>
</head>
<body>
<div class="b-auth-page">
  <div class="b-auth-card">
    <div class="b-auth-logo">🏭</div>
    <div class="b-auth-title">Business Portal</div>
    <div class="b-auth-sub">Login to your Scoopora business account</div>

    <div class="b2b-types">
      <span class="b2b-type-badge">🏭 Manufacturers</span>
      <span class="b2b-type-badge">🏪 Wholesalers</span>
      <span class="b2b-type-badge">🚚 Distributors</span>
    </div>

    <c:if test="${not empty error}">
      <div class="alert-error">⚠️ ${error}</div>
    </c:if>
    <c:if test="${param.registered == 'true'}">
      <div class="alert-success">✅ Registration submitted! We'll review your account within 1–2 business days.</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/business/auth" method="post">
      <input type="hidden" name="action" value="login"/>
      <div class="form-group">
        <label>Business Email</label>
        <input type="email" name="email" placeholder="business@example.com" required/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="••••••••" required/>
      </div>
      <button class="b-auth-btn" type="submit">Login to Dashboard →</button>
    </form>

    <div class="auth-link">
      New business? <a href="${pageContext.request.contextPath}/business-register.jsp">Register here</a>
    </div>
    <div class="auth-link" style="margin-top:0.4rem">
      <a href="${pageContext.request.contextPath}/home">← Back to Scoopora</a>
    </div>
  </div>
</div>
</body>
</html>
