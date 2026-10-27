<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Register – Scoopora</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <style>
    .auth-page { min-height: 100vh; display: flex; align-items: center; justify-content: center;
      background: linear-gradient(135deg, #7D3C98, #FF6B9D); padding: 2rem; }
    .auth-card { background: #fff; border-radius: 20px; padding: 2.5rem;
      width: 100%; max-width: 440px; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
    .auth-logo { text-align: center; font-size: 2.5rem; margin-bottom: 0.3rem; }
    .auth-title { text-align: center; font-size: 1.6rem; font-weight: 800;
      color: var(--choco); margin-bottom: 0.3rem; }
    .auth-sub { text-align: center; color: var(--gray); font-size: 0.88rem; margin-bottom: 1.8rem; }
    .form-group { margin-bottom: 1rem; }
    .form-group label { display: block; font-size: 0.82rem; font-weight: 600;
      color: var(--choco); margin-bottom: 0.4rem; }
    .form-group input, .form-group select {
      width: 100%; padding: 0.7rem 1rem; border-radius: 10px;
      border: 2px solid var(--lavender); font-size: 0.9rem; outline: none;
      font-family: inherit; transition: border-color 0.2s; }
    .form-group input:focus, .form-group select:focus { border-color: var(--purple-d); }
    .auth-btn { width: 100%; padding: 0.8rem; border-radius: 28px; border: none;
      background: linear-gradient(135deg, var(--purple-d), var(--pink-d));
      color: #fff; font-size: 1rem; font-weight: 700; cursor: pointer;
      transition: opacity 0.2s; margin-top: 0.5rem; }
    .auth-btn:hover { opacity: 0.88; }
    .auth-link { text-align: center; margin-top: 1.2rem; font-size: 0.88rem; color: var(--gray); }
    .auth-link a { color: var(--purple-d); font-weight: 700; }
    .alert-error { background: #fce4ec; color: #c62828; border-radius: 10px;
      padding: 0.7rem 1rem; font-size: 0.85rem; margin-bottom: 1rem; }
    .role-options { display: flex; gap: 0.8rem; }
    .role-option { flex: 1; }
    .role-option input[type=radio] { display: none; }
    .role-option label {
      display: block; text-align: center; padding: 0.6rem;
      border: 2px solid var(--lavender); border-radius: 10px;
      cursor: pointer; font-size: 0.85rem; font-weight: 600;
      color: var(--choco); transition: all 0.2s; }
    .role-option input[type=radio]:checked + label {
      border-color: var(--purple-d); background: var(--lavender); color: var(--purple-d); }
  </style>
</head>
<body>
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-logo">🍦</div>
    <div class="auth-title">Join Scoopora!</div>
    <div class="auth-sub">Create your free account today</div>

    <c:if test="${not empty error}">
      <div class="alert-error">⚠️ ${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth" method="post">
      <input type="hidden" name="action" value="register"/>

      <div class="form-group">
        <label>Account Type</label>
        <div class="role-options">
          <div class="role-option">
            <input type="radio" name="role" id="roleCustomer" value="customer" checked/>
            <label for="roleCustomer">🧑 Customer</label>
          </div>
          <div class="role-option">
            <input type="radio" name="role" id="roleBusiness" value="business"/>
            <label for="roleBusiness">🏪 Business</label>
          </div>
        </div>
      </div>

      <div class="form-group">
        <label>Full Name</label>
        <input type="text" name="name" placeholder="Your full name" required/>
      </div>
      <div class="form-group">
        <label>Email Address</label>
        <input type="email" name="email" placeholder="you@example.com" required/>
      </div>
      <div class="form-group">
        <label>Phone Number</label>
        <input type="tel" name="phone" placeholder="+91 98000 00000"/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="Min. 6 characters" minlength="6" required/>
      </div>

      <button class="auth-btn" type="submit">Create Account →</button>
    </form>

    <div class="auth-link">
      Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Login</a>
    </div>
    <div class="auth-link" style="margin-top:0.5rem">
      <a href="${pageContext.request.contextPath}/home">← Back to Home</a>
    </div>
  </div>
</div>
</body>
</html>
