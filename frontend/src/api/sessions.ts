import api from "./client";

export interface Session {
  id: string;
  topic: string;
  area_id: string;
  area_name: string;
  mode: "AUDIO" | "VIDEO";
  completed_at: string;
  transcript?: string | null;
  filler_word_count?: number | null;
  words_per_minute?: number | null;
  coherence_score?: number | null;
  grammar_score?: number | null;
  content_accuracy_score?: number | null;
  feedback_summary?: string | null;
  analyzed_at?: string | null;
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

export const analyzeSession = (sessionId: string, audioBlob: Blob) => {
  const formData = new FormData();
  formData.append("audio", audioBlob, "clip.webm");
  return api.post<Session>(`/sessions/${sessionId}/analyze`, formData, {
    headers: { "Content-Type": undefined },
  });
};
