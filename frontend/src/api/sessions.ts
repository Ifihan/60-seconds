import api from "./client";

export interface Session {
  id: string;
  topic: string;
  area_id: string;
  area_name: string;
  mode: "AUDIO" | "VIDEO";
  completed_at: string;
}

export interface PaginatedSessions {
  data: Session[];
  pagination: { page: number; limit: number; total: number };
}

export const logSession = (payload: {
  area_id: string;
  topic: string;
  mode: "AUDIO" | "VIDEO";
  completed_at: string;
}) => api.post<Session>("/sessions", payload);

export const getSessions = (params?: { area_id?: string; page?: number; limit?: number }) =>
  api.get<PaginatedSessions>("/sessions", { params });
