<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    .auth-page { min-height: 100vh; display: flex; align-items: center; justify-content: center;
      background: linear-gradient(135deg, #7D3C98, #FF6B9D); padding: 2rem; }
    .auth-card { background: #fff; border-radius: 20px; padding: 2.5rem;
      width: 100%; max-width: 420px; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
    .auth-logo { text-align: center; font-size: 2.5rem; margin-bottom: 0.3rem; }
    .auth-title { text-align: center; font-size: 1.6rem; font-weight: 800;
      color: var(--choco); margin-bottom: 0.3rem; }
    .auth-sub { text-align: center; color: var(--gray); font-size: 0.88rem; margin-bottom: 1.8rem; }
    .form-group { margin-bottom: 1.1rem; }
    .form-group label { display: block; font-size: 0.82rem; font-weight: 600;
      color: var(--choco); margin-bottom: 0.4rem; }
    .form-group input { width: 100%; padding: 0.7rem 1rem; border-radius: 10px;
      border: 2px solid var(--lavender); font-size: 0.9rem; outline: none;
      font-family: inherit; transition: border-color 0.2s; }
    .form-group input:focus { border-color: var(--purple-d); }
    .auth-btn { width: 100%; padding: 0.8rem; border-radius: 28px; border: none;
      background: linear-gradient(135deg, var(--purple-d), var(--pink-d));
      color: #fff; font-size: 1rem; font-weight: 700; cursor: pointer;
      transition: opacity 0.2s; margin-top: 0.5rem; }
    .auth-btn:hover { opacity: 0.88; }
    .auth-link { text-align: center; margin-top: 1.2rem; font-size: 0.88rem; color: var(--gray); }
    .auth-link a { color: var(--purple-d); font-weight: 700; }
    .alert-error { background: #fce4ec; color: #c62828; border-radius: 10px;
      padding: 0.7rem 1rem; font-size: 0.85rem; margin-bottom: 1rem; }
    .alert-success { background: #e8f5e9; color: #2e7d32; border-radius: 10px;
      padding: 0.7rem 1rem; font-size: 0.85rem; margin-bottom: 1rem; }
  </style>
</head>
<body>
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-logo">🍦</div>
    <div class="auth-title">Welcome Back!</div>
    <div class="auth-sub">Login to your Scoopora account</div>

    <c:if test="${not empty error}">
      <div class="alert-error">⚠️ ${error}</div>
    </c:if>
    <c:if test="${param.registered == 'true'}">
      <div class="alert-success">🎉 Registration successful! Please login.</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth" method="post">
      <input type="hidden" name="action" value="login"/>
      <div class="form-group">
        <label>Email Address</label>
        <input type="email" name="email" placeholder="you@example.com" required/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="••••••••" required/>
      </div>
      <button class="auth-btn" type="submit">Login →</button>
    </form>

    <div class="auth-link">
      Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp">Sign Up Free</a>
    </div>
    <div class="auth-link" style="margin-top:0.5rem">
      <a href="${pageContext.request.contextPath}/home">← Back to Home</a>
    </div>
  </div>
</div>
</body>
</html>
