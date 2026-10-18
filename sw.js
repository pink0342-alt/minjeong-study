// Minjeong Study service worker — cache refresh 2026-10-11
const CACHE = 'ms-v034';
const ASSETS = ['./', './index.html', './style.css', './manifest.webmanifest', './icon.svg'];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(Promise.all([
    caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE).map(key => caches.delete(key)))),
    self.clients.claim()
  ]));
});
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;
  // Always fetch app code from the network; never serve stale JavaScript from cache.
  if (new URL(request.url).pathname.endsWith('/app.js')) {
    event.respondWith(fetch(new Request(request, { cache: 'no-store' })));
    return;
  }
  event.respondWith(fetch(request).catch(() => caches.match(request)));
});
