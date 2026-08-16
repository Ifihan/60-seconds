import api from "./client";

export interface DailyTopicOut {
  area_id: string;
  area_name: string;
  topic_name: string;
  date: string;
}

export const getDailyTopic = () => api.get<DailyTopicOut | null>("/daily-topic");
