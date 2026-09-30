// Offline support for Learning OS.
//
// - App files (same origin): network first, so a new version is picked up
//   as soon as you're online; the cached copy is used when offline.
// - Flutter engine files and fonts from Google's CDN (CanvasKit, Roboto,
//   Noto for Arabic): cache first. Their URLs are versioned, so a cached
//   copy never goes stale.
//
// User data never goes through here: it lives in IndexedDB.

const CACHE = 'learning-os-v1';
const CDN_HOSTS = ['www.gstatic.com', 'fonts.gstatic.com', 'fonts.googleapis.com'];

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);

  if (url.origin === self.location.origin) {
    event.respondWith(networkFirst(request));
  } else if (CDN_HOSTS.includes(url.hostname)) {
    event.respondWith(cacheFirst(request));
  }
});

async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
      // Every page is the same app shell (index.html); keep it for offline
      // deep links whatever the first page visited was.
      if (request.mode === 'navigate') cache.put('./', response.clone());
    }
    return response;
  } catch (error) {
    const cached =
      (await cache.match(request)) ||
      // Deep links (/notes/123) are served by the app shell.
      (request.mode === 'navigate' ? await cache.match('./') : undefined);
    if (cached) return cached;
    throw error;
  }
}

async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  // Opaque (no-cors) responses have status 0 but are still usable.
  if (response.ok || response.type === 'opaque') {
    cache.put(request, response.clone());
  }
  return response;
}
