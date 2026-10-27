<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.scoopora.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User navUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="ctx" content="${pageContext.request.contextPath}"/>
  <title>Scoopy World – Premium Ice Cream</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800;900&family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    :root{
      --pink:#FF6B9D;--pink-l:#FFB3C6;--pink-ll:#FFE4EE;--pink-bg:#FFF0F5;
      --blush:#FDE8F0;--rose:#E8547A;--white:#FFFFFF;
      --charcoal:#1A1A2E;--gray:#6C757D;--gray-l:#F8F9FA;
      --shadow:0 4px 24px rgba(255,107,157,0.12);
      --shadow-h:0 12px 40px rgba(255,107,157,0.22);
      --radius:16px;--radius-s:10px;
    }
    body{font-family:'Poppins',sans-serif;background:var(--pink-bg);color:var(--charcoal);overflow-x:hidden;}
    a{text-decoration:none;color:inherit;}
    img{max-width:100%;display:block;}

    /* ── NAVBAR ── */
    .sw-nav{
      position:fixed;top:0;left:0;right:0;z-index:1000;
      background:rgba(255,255,255,0.92);
      backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);
      box-shadow:0 2px 20px rgba(255,107,157,0.10);
      padding:0 2.5rem;height:72px;
      display:flex;align-items:center;justify-content:space-between;
      transition:all 0.3s;
    }
    .sw-nav.scrolled{box-shadow:0 4px 30px rgba(255,107,157,0.18);}
    .sw-logo{display:flex;align-items:center;gap:0.6rem;cursor:pointer;}
    .sw-logo-icon{
      width:42px;height:42px;border-radius:50%;
      background:linear-gradient(135deg,var(--pink),var(--pink-l));
      display:flex;align-items:center;justify-content:center;
      font-size:1.3rem;box-shadow:0 4px 12px rgba(255,107,157,0.35);
    }
    .sw-logo-text{font-family:'Playfair Display',serif;font-size:1.4rem;font-weight:800;
      background:linear-gradient(135deg,var(--rose),var(--pink));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;}
    .sw-nav-links{display:flex;align-items:center;gap:0.3rem;}
    .sw-nav-links a{
      padding:0.45rem 1rem;border-radius:24px;font-size:0.88rem;font-weight:600;
      color:var(--charcoal);transition:all 0.2s;
    }
    .sw-nav-links a:hover,.sw-nav-links a.active{background:var(--pink-ll);color:var(--rose);}
    .sw-nav-actions{display:flex;align-items:center;gap:0.8rem;}
    .sw-btn-contact{
      background:linear-gradient(135deg,var(--pink),var(--rose));
      color:#fff;border:none;border-radius:28px;
      padding:0.5rem 1.4rem;font-size:0.88rem;font-weight:700;
      cursor:pointer;transition:all 0.2s;font-family:'Poppins',sans-serif;
      box-shadow:0 4px 14px rgba(255,107,157,0.35);
    }
    .sw-btn-contact:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(255,107,157,0.45);}
    .sw-btn-login{
      background:transparent;border:2px solid var(--pink-l);color:var(--rose);
      border-radius:28px;padding:0.45rem 1.2rem;font-size:0.85rem;font-weight:700;
      cursor:pointer;transition:all 0.2s;font-family:'Poppins',sans-serif;
    }
    .sw-btn-login:hover{background:var(--pink-ll);}
    .sw-hamburger{display:none;background:none;border:none;font-size:1.5rem;cursor:pointer;color:var(--charcoal);}
    .sw-mobile-menu{
      display:none;position:fixed;top:72px;left:0;right:0;
      background:#fff;padding:1.2rem 2rem;box-shadow:0 8px 24px rgba(0,0,0,0.1);
      z-index:999;flex-direction:column;gap:0.5rem;
    }
    .sw-mobile-menu.open{display:flex;}
    .sw-mobile-menu a{padding:0.7rem 1rem;border-radius:10px;font-weight:600;color:var(--charcoal);transition:all 0.2s;}
    .sw-mobile-menu a:hover{background:var(--pink-ll);color:var(--rose);}

    /* ── HERO ── */
    .sw-hero{
      min-height:100vh;padding:100px 2.5rem 4rem;
      background:linear-gradient(145deg,#FFF0F5 0%,#FFE4EE 40%,#FFF8FB 100%);
      display:flex;align-items:center;position:relative;overflow:hidden;
    }
    .sw-hero::before{
      content:'';position:absolute;top:-120px;right:-120px;
      width:600px;height:600px;border-radius:50%;
      background:radial-gradient(circle,rgba(255,179,198,0.35) 0%,transparent 70%);
      pointer-events:none;
    }
    .sw-hero::after{
      content:'';position:absolute;bottom:-80px;left:-80px;
      width:400px;height:400px;border-radius:50%;
      background:radial-gradient(circle,rgba(255,107,157,0.12) 0%,transparent 70%);
      pointer-events:none;
    }
    .sw-hero-inner{
      max-width:1300px;margin:0 auto;width:100%;
      display:grid;grid-template-columns:1fr 1fr;gap:3rem;align-items:center;
      position:relative;z-index:1;
    }

    /* Hero Left */
    .sw-hero-left{animation:fadeInLeft 0.9s ease both;}
    .sw-hero-tag{
      display:inline-flex;align-items:center;gap:0.5rem;
      background:rgba(255,107,157,0.12);border:1px solid rgba(255,107,157,0.25);
      border-radius:24px;padding:0.35rem 1rem;
      font-size:0.78rem;font-weight:700;color:var(--rose);
      margin-bottom:1.2rem;
    }
    .sw-hero-title{
      font-family:'Playfair Display',serif;
      font-size:clamp(2.8rem,5vw,4.2rem);font-weight:900;
      line-height:1.1;color:var(--charcoal);margin-bottom:1.2rem;
    }
    .sw-hero-title span{
      background:linear-gradient(135deg,var(--rose),var(--pink));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;
    }
    .sw-hero-sub{
      font-size:1rem;color:var(--gray);line-height:1.7;
      max-width:440px;margin-bottom:2rem;
    }
    .sw-hero-btns{display:flex;gap:1rem;flex-wrap:wrap;margin-bottom:2.5rem;}
    .sw-btn-order{
      background:linear-gradient(135deg,var(--pink),var(--rose));
      color:#fff;border:none;border-radius:32px;
      padding:0.85rem 2rem;font-size:0.95rem;font-weight:700;
      cursor:pointer;transition:all 0.25s;font-family:'Poppins',sans-serif;
      box-shadow:0 6px 20px rgba(255,107,157,0.4);
      display:inline-flex;align-items:center;gap:0.5rem;
    }
    .sw-btn-order:hover{transform:translateY(-3px);box-shadow:0 10px 28px rgba(255,107,157,0.5);}
    .sw-btn-menu{
      background:#fff;color:var(--charcoal);
      border:2px solid #E8D0DA;border-radius:32px;
      padding:0.83rem 2rem;font-size:0.95rem;font-weight:700;
      cursor:pointer;transition:all 0.25s;font-family:'Poppins',sans-serif;
      display:inline-flex;align-items:center;gap:0.5rem;
    }
    .sw-btn-menu:hover{border-color:var(--pink);color:var(--rose);transform:translateY(-3px);box-shadow:var(--shadow);}

    /* Mini cone previews */
    .sw-mini-cones{display:flex;align-items:center;gap:1rem;}
    .sw-mini-cone{
      display:flex;flex-direction:column;align-items:center;gap:0.4rem;
      cursor:pointer;transition:all 0.25s;
    }
    .sw-mini-cone:hover{transform:translateY(-6px);}
    .sw-mini-img{
      width:72px;height:90px;border-radius:50% 50% 40% 40%;
      object-fit:cover;box-shadow:0 6px 18px rgba(255,107,157,0.2);
      border:3px solid #fff;
      background:linear-gradient(135deg,var(--pink-ll),var(--blush));
      display:flex;align-items:center;justify-content:center;font-size:2rem;
    }
    .sw-mini-label{font-size:0.7rem;font-weight:700;color:var(--gray);}
    .sw-mini-sep{width:1px;height:50px;background:linear-gradient(to bottom,transparent,var(--pink-l),transparent);}

    /* Hero Right */
    .sw-hero-right{
      display:flex;align-items:center;justify-content:center;
      position:relative;animation:fadeInRight 0.9s ease both;
    }
    .sw-hero-glow{
      position:absolute;width:480px;height:480px;border-radius:50%;
      background:radial-gradient(circle,rgba(255,107,157,0.22) 0%,rgba(255,179,198,0.12) 50%,transparent 70%);
      animation:pulse 3s ease-in-out infinite;
    }
    .sw-hero-cone-wrap{
      position:relative;z-index:2;
      filter:drop-shadow(0 20px 40px rgba(255,107,157,0.3));
      animation:float 4s ease-in-out infinite;
    }
    .sw-hero-cone{width:100%;max-width:420px;height:520px;object-fit:contain;}
    .sw-cone-emoji{font-size:clamp(180px,22vw,280px);line-height:1;display:block;text-align:center;}

    /* Floating decorations */
    .sw-deco{position:absolute;pointer-events:none;animation:floatDeco 5s ease-in-out infinite;}
    .sw-deco-1{top:8%;right:5%;font-size:2.2rem;animation-delay:0s;}
    .sw-deco-2{top:20%;left:2%;font-size:1.6rem;animation-delay:1s;}
    .sw-deco-3{bottom:20%;right:8%;font-size:1.8rem;animation-delay:2s;}
    .sw-deco-4{bottom:10%;left:5%;font-size:1.4rem;animation-delay:0.5s;}
    .sw-deco-5{top:50%;right:2%;font-size:1.2rem;animation-delay:1.5s;}

    /* Stats strip */
    .sw-stats{
      background:#fff;border-radius:20px;
      padding:1.2rem 2rem;margin-top:2rem;
      display:flex;gap:2rem;box-shadow:var(--shadow);
      width:fit-content;
    }
    .sw-stat{text-align:center;}
    .sw-stat-val{font-size:1.4rem;font-weight:800;color:var(--rose);}
    .sw-stat-label{font-size:0.72rem;color:var(--gray);font-weight:600;}

    /* ── FLAVOURS STRIP ── */
    .sw-flavours{
      background:#fff;padding:3rem 2.5rem;
    }
    .sw-flavours-inner{max-width:1300px;margin:0 auto;}
    .sw-section-tag{
      display:inline-block;background:var(--pink-ll);color:var(--rose);
      border-radius:20px;padding:0.25rem 0.9rem;font-size:0.75rem;font-weight:700;
      margin-bottom:0.6rem;
    }
    .sw-section-title{
      font-family:'Playfair Display',serif;font-size:2rem;font-weight:800;
      color:var(--charcoal);margin-bottom:0.4rem;
    }
    .sw-section-title span{color:var(--rose);}
    .sw-section-sub{font-size:0.88rem;color:var(--gray);margin-bottom:2rem;}
    .sw-flavour-grid{
      display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:1.2rem;
    }
    .sw-flavour-card{
      background:var(--pink-bg);border-radius:var(--radius);
      padding:1.4rem 1rem;text-align:center;
      transition:all 0.25s;cursor:pointer;border:2px solid transparent;
    }
    .sw-flavour-card:hover{
      transform:translateY(-6px);box-shadow:var(--shadow-h);
      border-color:var(--pink-l);background:#fff;
    }
    .sw-flavour-icon{font-size:2.4rem;margin-bottom:0.6rem;}
    .sw-flavour-name{font-size:0.85rem;font-weight:700;color:var(--charcoal);}
    .sw-flavour-cat{font-size:0.72rem;color:var(--gray);text-transform:capitalize;margin-top:0.2rem;}

    /* ── BESTSELLERS ── */
    .sw-bestsellers{padding:3.5rem 2.5rem;background:var(--pink-bg);}
    .sw-bestsellers-inner{max-width:1300px;margin:0 auto;}
    .sw-section-header{display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:2rem;flex-wrap:wrap;gap:1rem;}
    .sw-view-all{
      background:transparent;border:2px solid var(--pink-l);color:var(--rose);
      border-radius:24px;padding:0.45rem 1.2rem;font-size:0.82rem;font-weight:700;
      cursor:pointer;transition:all 0.2s;font-family:'Poppins',sans-serif;
    }
    .sw-view-all:hover{background:var(--pink);color:#fff;border-color:var(--pink);}
    .sw-products-grid{
      display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:1.4rem;
    }
    .sw-product-card{
      background:#fff;border-radius:var(--radius);
      box-shadow:0 2px 16px rgba(255,107,157,0.08);
      overflow:hidden;transition:all 0.25s;position:relative;
    }
    .sw-product-card:hover{transform:translateY(-6px);box-shadow:var(--shadow-h);}
    .sw-product-img{
      height:170px;background:linear-gradient(135deg,var(--pink-ll),var(--blush));
      display:flex;align-items:center;justify-content:center;font-size:3.5rem;
      position:relative;overflow:hidden;
    }
    .sw-product-img::after{
      content:'';position:absolute;bottom:0;left:0;right:0;height:40px;
      background:linear-gradient(to top,#fff,transparent);
    }
    .sw-bestseller-tag{
      position:absolute;top:10px;left:10px;
      background:linear-gradient(135deg,var(--pink),var(--rose));
      color:#fff;font-size:0.68rem;font-weight:700;
      padding:0.2rem 0.6rem;border-radius:10px;
    }
    .sw-product-body{padding:1rem 1.1rem 1.2rem;}
    .sw-product-name{font-size:0.92rem;font-weight:700;color:var(--charcoal);margin-bottom:0.25rem;}
    .sw-product-shop{font-size:0.75rem;color:var(--gray);margin-bottom:0.6rem;}
    .sw-product-footer{display:flex;align-items:center;justify-content:space-between;}
    .sw-product-price{font-size:1rem;font-weight:800;color:var(--rose);}
    .sw-add-btn{
      background:linear-gradient(135deg,var(--pink),var(--rose));
      color:#fff;border:none;border-radius:20px;
      padding:0.35rem 0.9rem;font-size:0.78rem;font-weight:700;
      cursor:pointer;transition:all 0.2s;font-family:'Poppins',sans-serif;
    }
    .sw-add-btn:hover{transform:scale(1.05);box-shadow:0 4px 12px rgba(255,107,157,0.4);}

    /* ── REVIEWS ── */
    .sw-reviews{padding:3.5rem 2.5rem;background:#fff;}
    .sw-reviews-inner{max-width:1300px;margin:0 auto;}
    .sw-reviews-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:1.2rem;}
    .sw-review-card{
      background:var(--pink-bg);border-radius:var(--radius);
      padding:1.4rem;transition:all 0.25s;border:2px solid transparent;
    }
    .sw-review-card:hover{border-color:var(--pink-l);box-shadow:var(--shadow);}
    .sw-review-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:0.8rem;}
    .sw-reviewer{font-weight:700;font-size:0.88rem;color:var(--charcoal);}
    .sw-review-shop{font-size:0.75rem;color:var(--gray);margin-top:0.15rem;}
    .sw-review-stars{color:#FFB800;font-size:1rem;letter-spacing:1px;}
    .sw-review-text{font-size:0.85rem;color:#555;line-height:1.6;font-style:italic;}
    .sw-review-text::before{content:'"';}
    .sw-review-text::after{content:'"';}

    /* ── CTA BANNER ── */
    .sw-cta{
      padding:4rem 2.5rem;
      background:linear-gradient(135deg,var(--rose) 0%,var(--pink) 50%,#FFB3C6 100%);
      text-align:center;color:#fff;position:relative;overflow:hidden;
    }
    .sw-cta::before{
      content:'🍦🍧🍨🍦🍧🍨';position:absolute;top:0;left:0;right:0;
      font-size:4rem;opacity:0.06;letter-spacing:3rem;white-space:nowrap;
    }
    .sw-cta-inner{max-width:700px;margin:0 auto;position:relative;z-index:1;}
    .sw-cta h2{font-family:'Playfair Display',serif;font-size:2.4rem;font-weight:800;margin-bottom:0.8rem;}
    .sw-cta p{font-size:1rem;opacity:0.9;margin-bottom:2rem;}
    .sw-cta-btns{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;}
    .sw-cta-btn-white{
      background:#fff;color:var(--rose);border:none;border-radius:32px;
      padding:0.85rem 2rem;font-size:0.95rem;font-weight:800;
      cursor:pointer;transition:all 0.25s;font-family:'Poppins',sans-serif;
      box-shadow:0 6px 20px rgba(0,0,0,0.15);
    }
    .sw-cta-btn-white:hover{transform:translateY(-3px);box-shadow:0 10px 28px rgba(0,0,0,0.2);}
    .sw-cta-btn-outline{
      background:transparent;color:#fff;border:2px solid rgba(255,255,255,0.7);
      border-radius:32px;padding:0.83rem 2rem;font-size:0.95rem;font-weight:700;
      cursor:pointer;transition:all 0.25s;font-family:'Poppins',sans-serif;
    }
    .sw-cta-btn-outline:hover{background:rgba(255,255,255,0.15);transform:translateY(-3px);}

    /* ── FOOTER ── */
    .sw-footer{
      background:var(--charcoal);color:rgba(255,255,255,0.8);
      padding:3rem 2.5rem 1.5rem;
    }
    .sw-footer-inner{
      max-width:1300px;margin:0 auto;
      display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:2.5rem;margin-bottom:2rem;
    }
    .sw-footer-brand .sw-logo-text{font-size:1.5rem;color:var(--pink-l);-webkit-text-fill-color:var(--pink-l);}
    .sw-footer-brand p{font-size:0.85rem;opacity:0.7;margin-top:0.6rem;line-height:1.6;}
    .sw-footer-col h4{font-size:0.9rem;font-weight:700;color:var(--pink-l);margin-bottom:0.9rem;}
    .sw-footer-col a{display:block;font-size:0.83rem;opacity:0.75;margin-bottom:0.45rem;transition:opacity 0.2s;}
    .sw-footer-col a:hover{opacity:1;color:var(--pink-l);}
    .sw-footer-bottom{
      max-width:1300px;margin:0 auto;
      padding-top:1.2rem;border-top:1px solid rgba(255,255,255,0.1);
      text-align:center;font-size:0.8rem;opacity:0.6;
    }

    /* ── ANIMATIONS ── */
    @keyframes fadeInLeft{from{opacity:0;transform:translateX(-40px);}to{opacity:1;transform:translateX(0);}}
    @keyframes fadeInRight{from{opacity:0;transform:translateX(40px);}to{opacity:1;transform:translateX(0);}}
    @keyframes float{0%,100%{transform:translateY(0);}50%{transform:translateY(-18px);}}
    @keyframes floatDeco{0%,100%{transform:translateY(0) rotate(0deg);}50%{transform:translateY(-10px) rotate(8deg);}}
    @keyframes pulse{0%,100%{transform:scale(1);opacity:0.8;}50%{transform:scale(1.08);opacity:1;}}
    @keyframes fadeInUp{from{opacity:0;transform:translateY(30px);}to{opacity:1;transform:translateY(0);}}
    .anim-up{opacity:0;animation:fadeInUp 0.7s ease forwards;}
    .anim-up-1{animation-delay:0.1s;}
    .anim-up-2{animation-delay:0.2s;}
    .anim-up-3{animation-delay:0.3s;}
    .anim-up-4{animation-delay:0.4s;}

    /* ── RESPONSIVE ── */
    @media(max-width:960px){
      .sw-hero-inner{grid-template-columns:1fr;text-align:center;}
      .sw-hero-sub{max-width:100%;}
      .sw-hero-btns{justify-content:center;}
      .sw-mini-cones{justify-content:center;}
      .sw-stats{margin:2rem auto 0;}
      .sw-hero-right{margin-top:2rem;}
      .sw-footer-inner{grid-template-columns:1fr 1fr;}
    }
    @media(max-width:640px){
      .sw-nav{padding:0 1.2rem;}
      .sw-nav-links{display:none;}
      .sw-hamburger{display:block;}
      .sw-hero{padding:90px 1.2rem 3rem;}
      .sw-hero-title{font-size:2.4rem;}
      .sw-flavours,.sw-bestsellers,.sw-reviews,.sw-cta{padding:2.5rem 1.2rem;}
      .sw-footer-inner{grid-template-columns:1fr;}
      .sw-stats{flex-wrap:wrap;gap:1rem;}
    }
  </style>
</head>
<body>

<!-- ══ NAVBAR ══ -->
<nav class="sw-nav" id="swNav">
  <a href="${pageContext.request.contextPath}/home" class="sw-logo">
    <div class="sw-logo-icon">🍦</div>
    <span class="sw-logo-text">Scoopy World</span>
  </a>

  <div class="sw-nav-links">
    <a href="${pageContext.request.contextPath}/home" class="active">Home</a>
    <a href="${pageContext.request.contextPath}/shops">Menu</a>
    <a href="${pageContext.request.contextPath}/reviews">Reviews</a>
    <a href="#sw-contact">Contact</a>
  </div>

  <div class="sw-nav-actions">
    <% if (navUser != null) { %>
      <form action="${pageContext.request.contextPath}/auth" method="post" style="display:inline">
        <input type="hidden" name="action" value="logout"/>
        <button class="sw-btn-login" type="submit">👋 <%= navUser.getName().split(" ")[0] %></button>
      </form>
    <% } else { %>
      <a href="${pageContext.request.contextPath}/login.jsp">
        <button class="sw-btn-login">Login</button>
      </a>
    <% } %>
    <a href="#sw-contact">
      <button class="sw-btn-contact">Contact Us</button>
    </a>
  </div>

  <button class="sw-hamburger" id="swHamburger" onclick="toggleMobileMenu()">☰</button>
</nav>

<!-- Mobile Menu -->
<div class="sw-mobile-menu" id="swMobileMenu">
  <a href="${pageContext.request.contextPath}/home" onclick="toggleMobileMenu()">🏠 Home</a>
  <a href="${pageContext.request.contextPath}/shops" onclick="toggleMobileMenu()">🍦 Menu</a>
  <a href="${pageContext.request.contextPath}/reviews" onclick="toggleMobileMenu()">⭐ Reviews</a>
  <a href="#sw-contact" onclick="toggleMobileMenu()">📞 Contact</a>
  <% if (navUser == null) { %>
  <a href="${pageContext.request.contextPath}/login.jsp" onclick="toggleMobileMenu()">🔐 Login / Sign Up</a>
  <% } %>
</div>

<!-- ══ HERO ══ -->
<section class="sw-hero" id="home">

  <!-- Floating decorations -->
  <span class="sw-deco sw-deco-1">🍓</span>
  <span class="sw-deco sw-deco-2">🌸</span>
  <span class="sw-deco sw-deco-3">🍃</span>
  <span class="sw-deco sw-deco-4">✨</span>
  <span class="sw-deco sw-deco-5">🍒</span>

  <div class="sw-hero-inner">

    <!-- Left Column -->
    <div class="sw-hero-left">
      <div class="sw-hero-tag">🍓 Premium Ice Cream Experience</div>

      <h1 class="sw-hero-title">
        Strawberry<br/><span>Swirl</span>
      </h1>

      <p class="sw-hero-sub">
        Every scoop of strawberry ice cream is a taste of pure happiness, fresh and sweet. Crafted with real fruit and love.
      </p>

      <div class="sw-hero-btns">
        <a href="${pageContext.request.contextPath}/shops">
          <button class="sw-btn-order">🛒 Order Now</button>
        </a>
        <a href="${pageContext.request.contextPath}/shops">
          <button class="sw-btn-menu">🍦 View Menu</button>
        </a>
      </div>

      <!-- Mini cone previews -->
      <div class="sw-mini-cones">
        <div class="sw-mini-cone" onclick="window.location='${pageContext.request.contextPath}/shops'" title="Strawberry">
          <div class="sw-mini-img">🍓</div>
          <span class="sw-mini-label">Strawberry</span>
        </div>
        <div class="sw-mini-sep"></div>
        <div class="sw-mini-cone" onclick="window.location='${pageContext.request.contextPath}/shops'" title="Blueberry">
          <div class="sw-mini-img">🫐</div>
          <span class="sw-mini-label">Blueberry</span>
        </div>
        <div class="sw-mini-sep"></div>
        <div class="sw-mini-cone" onclick="window.location='${pageContext.request.contextPath}/shops'" title="Chocolate">
          <div class="sw-mini-img">🍫</div>
          <span class="sw-mini-label">Chocolate</span>
        </div>
        <div class="sw-mini-sep"></div>
        <div class="sw-mini-cone" onclick="window.location='${pageContext.request.contextPath}/shops'" title="Mango">
          <div class="sw-mini-img">🥭</div>
          <span class="sw-mini-label">Mango</span>
        </div>
      </div>

      <!-- Stats -->
      <div class="sw-stats">
        <div class="sw-stat">
          <div class="sw-stat-val">50+</div>
          <div class="sw-stat-label">Flavours</div>
        </div>
        <div class="sw-stat">
          <div class="sw-stat-val">10K+</div>
          <div class="sw-stat-label">Happy Customers</div>
        </div>
        <div class="sw-stat">
          <div class="sw-stat-val">4.9★</div>
          <div class="sw-stat-label">Rating</div>
        </div>
        <div class="sw-stat">
          <div class="sw-stat-val">6</div>
          <div class="sw-stat-label">Locations</div>
        </div>
      </div>
    </div>

    <!-- Right Column — Hero Ice Cream Visual -->
    <div class="sw-hero-right">
      <div class="sw-hero-glow"></div>
      <div class="sw-hero-cone-wrap">
        <!-- Decorative splashes around the cone -->
        <div style="position:relative;text-align:center;">
          <span style="position:absolute;top:-30px;left:10px;font-size:2rem;animation:floatDeco 3s ease-in-out infinite;animation-delay:0.3s;">🍓</span>
          <span style="position:absolute;top:20px;right:0px;font-size:1.6rem;animation:floatDeco 4s ease-in-out infinite;animation-delay:1s;">🍃</span>
          <span style="position:absolute;bottom:60px;left:-10px;font-size:1.8rem;animation:floatDeco 3.5s ease-in-out infinite;animation-delay:0.7s;">🍓</span>
          <span style="position:absolute;bottom:40px;right:10px;font-size:1.4rem;animation:floatDeco 4.5s ease-in-out infinite;animation-delay:1.5s;">🌸</span>
          <!-- Main ice cream cone -->
          <span class="sw-cone-emoji">🍦</span>
          <!-- Sauce drip effect -->
          <div style="position:absolute;top:30%;left:50%;transform:translateX(-50%);width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,rgba(255,107,157,0.15),transparent 70%);pointer-events:none;"></div>
        </div>
      </div>
    </div>

  </div>
</section>

<!-- ══ TRENDING FLAVOURS ══ -->
<section class="sw-flavours" id="menu">
  <div class="sw-flavours-inner">
    <div class="sw-section-header">
      <div>
        <span class="sw-section-tag">🌟 Fan Favourites</span>
        <div class="sw-section-title">Trending <span>Flavours</span></div>
        <div class="sw-section-sub">What everyone is scooping right now</div>
      </div>
      <a href="${pageContext.request.contextPath}/shops">
        <button class="sw-view-all">All Flavours →</button>
      </a>
    </div>
    <div class="sw-flavour-grid">
      <div class="sw-flavour-card anim-up anim-up-1" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🍓</div>
        <div class="sw-flavour-name">Strawberry Dream</div>
        <div class="sw-flavour-cat">fruit</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-2" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🍫</div>
        <div class="sw-flavour-name">Belgian Chocolate</div>
        <div class="sw-flavour-cat">chocolate</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-3" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🥭</div>
        <div class="sw-flavour-name">Mango Tango</div>
        <div class="sw-flavour-cat">fruit</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-4" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🍵</div>
        <div class="sw-flavour-name">Matcha Green Tea</div>
        <div class="sw-flavour-cat">exotic</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-1" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🍪</div>
        <div class="sw-flavour-name">Cookies &amp; Cream</div>
        <div class="sw-flavour-cat">classic</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-2" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🍮</div>
        <div class="sw-flavour-name">Salted Caramel</div>
        <div class="sw-flavour-cat">caramel</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-3" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🥜</div>
        <div class="sw-flavour-name">Pistachio Royale</div>
        <div class="sw-flavour-cat">nut</div>
      </div>
      <div class="sw-flavour-card anim-up anim-up-4" onclick="window.location='${pageContext.request.contextPath}/shops'">
        <div class="sw-flavour-icon">🫐</div>
        <div class="sw-flavour-name">Blueberry Cheesecake</div>
        <div class="sw-flavour-cat">fruit</div>
      </div>
    </div>
  </div>
</section>

<!-- ══ BESTSELLERS ══ -->
<section class="sw-bestsellers">
  <div class="sw-bestsellers-inner">
    <div class="sw-section-header">
      <div>
        <span class="sw-section-tag">⭐ Top Picks</span>
        <div class="sw-section-title">Best-Selling <span>Scoops</span></div>
        <div class="sw-section-sub">Customer favourites across all our locations</div>
      </div>
      <a href="${pageContext.request.contextPath}/shops">
        <button class="sw-view-all">View All →</button>
      </a>
    </div>
    <div class="sw-products-grid">
      <c:forEach var="p" items="${bestsellerProducts}">
        <div class="sw-product-card">
          <div class="sw-product-img">
            <c:choose>
              <c:when test="${p.category == 'scoop'}">🍨</c:when>
              <c:when test="${p.category == 'cone'}">🍦</c:when>
              <c:when test="${p.category == 'cup'}">🍧</c:when>
              <c:when test="${p.category == 'combo'}">🎁</c:when>
              <c:otherwise>🍦</c:otherwise>
            </c:choose>
          </div>
          <span class="sw-bestseller-tag">⭐ Bestseller</span>
          <div class="sw-product-body">
            <div class="sw-product-name">${p.name}</div>
            <div class="sw-product-shop">🏪 ${p.shopName}</div>
            <div class="sw-product-footer">
              <span class="sw-product-price">₹${p.price}</span>
              <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                <input type="hidden" name="action" value="add"/>
                <input type="hidden" name="productId" value="${p.id}"/>
                <button class="sw-add-btn" type="submit">+ Add</button>
              </form>
            </div>
          </div>
        </div>
      </c:forEach>
      <!-- Fallback cards if no DB data -->
      <c:if test="${empty bestsellerProducts}">
        <div class="sw-product-card">
          <div class="sw-product-img">🍦</div>
          <span class="sw-bestseller-tag">⭐ Bestseller</span>
          <div class="sw-product-body">
            <div class="sw-product-name">Belgian Choco Scoop</div>
            <div class="sw-product-shop">🏪 Sweet Scoops</div>
            <div class="sw-product-footer">
              <span class="sw-product-price">₹120</span>
              <a href="${pageContext.request.contextPath}/shops"><button class="sw-add-btn">Order</button></a>
            </div>
          </div>
        </div>
        <div class="sw-product-card">
          <div class="sw-product-img">🍧</div>
          <span class="sw-bestseller-tag">⭐ Bestseller</span>
          <div class="sw-product-body">
            <div class="sw-product-name">Salted Caramel Sundae</div>
            <div class="sw-product-shop">🏪 Chill Zone</div>
            <div class="sw-product-footer">
              <span class="sw-product-price">₹220</span>
              <a href="${pageContext.request.contextPath}/shops"><button class="sw-add-btn">Order</button></a>
            </div>
          </div>
        </div>
        <div class="sw-product-card">
          <div class="sw-product-img">🍨</div>
          <span class="sw-bestseller-tag">⭐ Bestseller</span>
          <div class="sw-product-body">
            <div class="sw-product-name">Pistachio Gelato Cup</div>
            <div class="sw-product-shop">🏪 Gelato King</div>
            <div class="sw-product-footer">
              <span class="sw-product-price">₹180</span>
              <a href="${pageContext.request.contextPath}/shops"><button class="sw-add-btn">Order</button></a>
            </div>
          </div>
        </div>
        <div class="sw-product-card">
          <div class="sw-product-img">🍦</div>
          <span class="sw-bestseller-tag">⭐ Bestseller</span>
          <div class="sw-product-body">
            <div class="sw-product-name">Mango Tango Cone</div>
            <div class="sw-product-shop">🏪 Sweet Scoops</div>
            <div class="sw-product-footer">
              <span class="sw-product-price">₹150</span>
              <a href="${pageContext.request.contextPath}/shops"><button class="sw-add-btn">Order</button></a>
            </div>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</section>

<!-- ══ REVIEWS ══ -->
<section class="sw-reviews" id="reviews">
  <div class="sw-reviews-inner">
    <div class="sw-section-header">
      <div>
        <span class="sw-section-tag">💬 Real Stories</span>
        <div class="sw-section-title">What Customers <span>Say</span></div>
        <div class="sw-section-sub">Real reviews from real ice cream lovers</div>
      </div>
      <a href="${pageContext.request.contextPath}/reviews">
        <button class="sw-view-all">All Reviews →</button>
      </a>
    </div>
    <div class="sw-reviews-grid">
      <c:forEach var="rev" items="${recentReviews}">
        <div class="sw-review-card">
          <div class="sw-review-header">
            <div>
              <div class="sw-reviewer">👤 ${rev.userName}</div>
              <div class="sw-review-shop">at ${rev.shopName}</div>
            </div>
            <div class="sw-review-stars">
              <c:forEach begin="1" end="${rev.rating}" var="s">★</c:forEach>
            </div>
          </div>
          <div class="sw-review-text">${rev.comment}</div>
        </div>
      </c:forEach>
      <c:if test="${empty recentReviews}">
        <div class="sw-review-card">
          <div class="sw-review-header">
            <div><div class="sw-reviewer">👤 Priya S.</div><div class="sw-review-shop">at Sweet Scoops</div></div>
            <div class="sw-review-stars">★★★★★</div>
          </div>
          <div class="sw-review-text">Absolutely amazing! Best ice cream in the city. The Belgian chocolate scoop is pure heaven.</div>
        </div>
        <div class="sw-review-card">
          <div class="sw-review-header">
            <div><div class="sw-reviewer">👤 Rahul M.</div><div class="sw-review-shop">at Gelato King</div></div>
            <div class="sw-review-stars">★★★★★</div>
          </div>
          <div class="sw-review-text">Authentic Italian gelato — this is the real deal! The pistachio gelato transported me straight to Sicily.</div>
        </div>
        <div class="sw-review-card">
          <div class="sw-review-header">
            <div><div class="sw-reviewer">👤 Ananya K.</div><div class="sw-review-shop">at The Ice Lab</div></div>
            <div class="sw-review-stars">★★★★★</div>
          </div>
          <div class="sw-review-text">The liquid nitrogen ice cream experience is absolutely mind-blowing! Worth every rupee.</div>
        </div>
      </c:if>
    </div>
  </div>
</section>

<!-- ══ CTA BANNER ══ -->
<section class="sw-cta">
  <div class="sw-cta-inner">
    <h2>🍦 Ready for Your Perfect Scoop?</h2>
    <p>Explore our full menu, customize your order, and get it delivered fresh to your door.</p>
    <div class="sw-cta-btns">
      <a href="${pageContext.request.contextPath}/shops">
        <button class="sw-cta-btn-white">🛒 Order Now</button>
      </a>
      <a href="${pageContext.request.contextPath}/register.jsp">
        <button class="sw-cta-btn-outline">Join Scoopy World →</button>
      </a>
    </div>
  </div>
</section>

<!-- ══ FOOTER / CONTACT ══ -->
<footer class="sw-footer" id="sw-contact">
  <div class="sw-footer-inner">
    <div class="sw-footer-brand">
      <div class="sw-logo" style="margin-bottom:0.8rem;">
        <div class="sw-logo-icon">🍦</div>
        <span class="sw-logo-text">Scoopy World</span>
      </div>
      <p>Your premium ice cream destination. Crafted with love, served with joy. Discover amazing flavours and unforgettable experiences.</p>
      <div style="margin-top:1rem;display:flex;gap:0.8rem;">
        <span style="background:rgba(255,255,255,0.1);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1rem;">📘</span>
        <span style="background:rgba(255,255,255,0.1);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1rem;">📸</span>
        <span style="background:rgba(255,255,255,0.1);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1rem;">🐦</span>
      </div>
    </div>
    <div class="sw-footer-col">
      <h4>Menu</h4>
      <a href="${pageContext.request.contextPath}/shops">Ice Cream Shops</a>
      <a href="${pageContext.request.contextPath}/shops">All Flavours</a>
      <a href="${pageContext.request.contextPath}/cakes">Ice Cream Cakes</a>
      <a href="${pageContext.request.contextPath}/bulk">Bulk Orders</a>
    </div>
    <div class="sw-footer-col">
      <h4>Quick Links</h4>
      <a href="${pageContext.request.contextPath}/home">Home</a>
      <a href="${pageContext.request.contextPath}/reviews">Reviews</a>
      <a href="${pageContext.request.contextPath}/mood">Mood Finder</a>
      <a href="${pageContext.request.contextPath}/supplier-compare">Compare Suppliers</a>
    </div>
    <div class="sw-footer-col">
      <h4>Contact</h4>
      <a href="mailto:hello@scoopyworld.com">📧 hello@scoopyworld.com</a>
      <a href="tel:+919800000000">📞 +91 98000 00000</a>
      <a href="#">📍 Mumbai, India</a>
      <a href="${pageContext.request.contextPath}/register.jsp">🤝 Partner With Us</a>
    </div>
  </div>
  <div class="sw-footer-bottom">
    &copy; 2025 Scoopy World. All rights reserved. Made with 🍦 and ❤️
  </div>
</footer>

<script>
// Navbar scroll effect
window.addEventListener('scroll', function() {
  document.getElementById('swNav').classList.toggle('scrolled', window.scrollY > 40);
});

// Mobile menu toggle
function toggleMobileMenu() {
  document.getElementById('swMobileMenu').classList.toggle('open');
}
document.addEventListener('click', function(e) {
  const menu = document.getElementById('swMobileMenu');
  const btn   = document.getElementById('swHamburger');
  if (!menu.contains(e.target) && !btn.contains(e.target)) {
    menu.classList.remove('open');
  }
});

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(function(a) {
  a.addEventListener('click', function(e) {
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

// Intersection Observer for fade-in animations
const observer = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (entry.isIntersecting) {
      entry.target.style.animationPlayState = 'running';
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.15 });

document.querySelectorAll('.anim-up').forEach(function(el) {
  el.style.animationPlayState = 'paused';
  observer.observe(el);
});

// Mini cone hover ripple
document.querySelectorAll('.sw-mini-cone').forEach(function(cone) {
  cone.addEventListener('mouseenter', function() {
    this.querySelector('.sw-mini-img').style.transform = 'scale(1.1)';
  });
  cone.addEventListener('mouseleave', function() {
    this.querySelector('.sw-mini-img').style.transform = 'scale(1)';
  });
});
</script>
</body>
</html>
