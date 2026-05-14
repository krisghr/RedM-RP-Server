const overlay = document.getElementById('overlay');
const titleEl = document.getElementById('title');
const imageEl = document.getElementById('image');
const errorEl = document.getElementById('error');
const loadingEl = document.getElementById('loading');
const closeBtn = document.getElementById('closeBtn');

function toggleHidden(el, hidden) {
  if (!el) return;
  el.classList.toggle('hidden', hidden);
}

function setState({ loading = false, showImage = false, showError = false, errorText = '' }) {
  toggleHidden(loadingEl, !loading);
  toggleHidden(imageEl, !showImage);
  toggleHidden(errorEl, !showError);
  if (showError && errorText && errorEl) errorEl.textContent = errorText;
}

function closePopup() {
  if (overlay) overlay.classList.add('hidden');
  if (imageEl) imageEl.removeAttribute('src');
  setState({ loading: false, showImage: false, showError: false });

  fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: '{}'
  }).catch(() => {});
}

function normalizeUrl(input) {
  if (!input || typeof input !== 'string') return '';
  try {
    const url = new URL(input);
    return url.toString();
  } catch (_) {
    return input;
  }
}

if (closeBtn) {
  closeBtn.addEventListener('click', closePopup);
}

window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closePopup();
});

if (imageEl) {
  imageEl.addEventListener('load', () => setState({ loading: false, showImage: true, showError: false }));
  imageEl.addEventListener('error', () => {
    setState({ loading: false, showImage: false, showError: true, errorText: 'Failed to load image URL. Host may block hotlinking; try direct image URL.' });
  });
}

window.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.action === 'open') {
    if (titleEl) titleEl.textContent = data.title || 'Image Preview';

    if (imageEl) {
      imageEl.referrerPolicy = 'no-referrer';
      imageEl.crossOrigin = 'anonymous';

      const nextUrl = normalizeUrl(data.url || '');
      if (nextUrl) {
        setState({ loading: true, showImage: false, showError: false });
        imageEl.src = nextUrl;
      } else {
        imageEl.removeAttribute('src');
        setState({ loading: true, showImage: false, showError: false });
      }
    }

    if (overlay) overlay.classList.remove('hidden');
  }

  if (data.action === 'close') {
    if (overlay) overlay.classList.add('hidden');
    if (imageEl) imageEl.removeAttribute('src');
    setState({ loading: false, showImage: false, showError: false });
  }
});
