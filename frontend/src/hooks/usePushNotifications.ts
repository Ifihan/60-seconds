"use client";

import { useEffect, useState } from "react";
import { subscribePush, unsubscribePush } from "@/api/push";
import { useStore } from "@/store";

const VAPID_PUBLIC_KEY = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY ?? "";

function urlBase64ToUint8Array(base64: string): Uint8Array {
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const b64 = (base64 + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = atob(b64);
  return Uint8Array.from([...raw].map((c) => c.charCodeAt(0)));
}

export function usePushNotifications() {
  const { token } = useStore();
  const [supported, setSupported] = useState(false);
  const [permission, setPermission] = useState<NotificationPermission>("default");
  const [subscribed, setSubscribed] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const ok =
      typeof window !== "undefined" &&
      "Notification" in window &&
      "serviceWorker" in navigator &&
      "PushManager" in window;
    setSupported(ok);
    if (ok) setPermission(Notification.permission);
  }, []);

  useEffect(() => {
    if (!supported) return;
    navigator.serviceWorker.ready.then((reg) =>
      reg.pushManager.getSubscription().then((sub) => setSubscribed(!!sub))
    );
  }, [supported]);

  async function subscribe() {
    if (!token || !supported || !VAPID_PUBLIC_KEY) return;
    setLoading(true);
    try {
      const reg = await navigator.serviceWorker.ready;
      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
      });
      const json = sub.toJSON();
      await subscribePush({
        endpoint: json.endpoint!,
        p256dh: json.keys!.p256dh,
        auth: json.keys!.auth,
      });
      setPermission(Notification.permission);
      setSubscribed(true);
    } catch {
      // user denied or error
    } finally {
      setLoading(false);
    }
  }

  async function unsubscribe() {
    if (!supported) return;
    setLoading(true);
    try {
      const reg = await navigator.serviceWorker.ready;
      const sub = await reg.pushManager.getSubscription();
      if (sub) {
        const json = sub.toJSON();
        await unsubscribePush({
          endpoint: json.endpoint!,
          p256dh: json.keys!.p256dh,
          auth: json.keys!.auth,
        });
        await sub.unsubscribe();
        setSubscribed(false);
      }
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  }

  return { supported, permission, subscribed, loading, subscribe, unsubscribe };
}
