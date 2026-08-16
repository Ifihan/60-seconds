import api from "./client";
import type { Area, Topic } from "@/store";

export const getAreas = () => api.get<Area[]>("/areas");

export const createArea = (name: string) =>
  api.post<Area>("/areas", { name });

export const deleteArea = (areaId: string) =>
  api.delete(`/areas/${areaId}`);

export const subscribeArea = (areaId: string) =>
  api.post<Area>(`/areas/${areaId}/subscribe`);

export const unsubscribeArea = (areaId: string) =>
  api.delete(`/areas/${areaId}/subscribe`);

export const setPreferredArea = (areaId: string) =>
  api.post<Area>(`/areas/${areaId}/preferred`);

export const getTopics = (areaId: string) =>
  api.get<Topic[]>(`/areas/${areaId}/topics`);

export const addTopics = (areaId: string, names: string[]) =>
  api.post<Topic[]>(`/areas/${areaId}/topics`, { names });

export const deleteTopic = (areaId: string, topicId: string) =>
  api.delete(`/areas/${areaId}/topics/${topicId}`);
