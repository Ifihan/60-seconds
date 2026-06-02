import api from "./client";

interface PushPayload {
  endpoint: string;
  p256dh: string;
  auth: string;
}

export const subscribePush = (data: PushPayload) => api.post("/push/subscribe", data);
export const unsubscribePush = (data: PushPayload) => api.delete("/push/subscribe", { data });
