// ── Scoopora main.js ──

// Cart badge count from session via API
async function refreshCartBadge() {
  try {
    const res = await fetch(getCtx() + '/cart-count');
    if (res.ok) {
      const data = await res.json();
      const badge = document.getElementById('cartBadge');
      if (badge) badge.textContent = data.count || 0;
    }
  } catch (_) {}
}

function getCtx() {
  return document.querySelector('meta[name="ctx"]')?.content || '';
}

// Toast notification
function showToast(msg, duration = 3000) {
  const t = document.getElementById('toast');
  if (!t) return;
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), duration);
}

// Show toast on cart add (detect URL param)
(function () {
  const params = new URLSearchParams(window.location.search);
  if (params.get('added') === 'true')       showToast('🛒 Added to cart!');
  if (params.get('placed') === 'true')      showToast('✅ Order placed! We are preparing your ice cream 🍦', 5000);
  if (params.get('submitted') === 'true')   showToast('✅ Wholesale order submitted! We will confirm shortly 📦', 5000);
  if (params.get('cancelled') === 'true')   showToast('🗑️ Order cancelled. Stock has been restored.');
  if (params.get('cancelError') === 'true') showToast('⚠️ Order cannot be cancelled at this stage.', 4000);
  if (params.get('updated') === 'true')     showToast('✅ Stock updated successfully!');
  if (params.get('registered') === 'true')  showToast('🎉 Registration successful! Please login.');
})();

// Animate cards on scroll (Intersection Observer)
function animateOnScroll() {
  const cards = document.querySelectorAll('.shop-card, .product-card, .review-card');
  if (!('IntersectionObserver' in window)) return;
  const obs = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.style.opacity = '1';
        e.target.style.transform = 'translateY(0)';
        obs.unobserve(e.target);
      }
    });
  }, { threshold: 0.1 });

  cards.forEach(c => {
    c.style.opacity = '0';
    c.style.transform = 'translateY(24px)';
    c.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
    obs.observe(c);
  });
}

document.addEventListener('DOMContentLoaded', () => {
  refreshCartBadge();
  animateOnScroll();
});
