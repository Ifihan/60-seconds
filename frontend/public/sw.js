self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (e) => e.waitUntil(clients.claim()));

self.addEventListener("push", (event) => {
  const data = event.data?.json() ?? {};
  event.waitUntil(
    self.registration.showNotification(data.title ?? "60 Seconds", {
      body: data.body ?? "Time to practice. Pick a topic and speak.",
      icon: "/icon.svg",
      badge: "/icon.svg",
      tag: "daily-reminder",
      renotify: true,
      data: { url: "/" },
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        for (const client of clientList) {
          if ("focus" in client) return client.focus();
        }
        if (clients.openWindow) {
          return clients.openWindow(event.notification.data?.url ?? "/");
        }
      })
  );
});
