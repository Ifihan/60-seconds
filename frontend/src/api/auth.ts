import api from "./client";

export interface AuthPayload {
  token: string;
  user: { id: string; email: string };
}

export const signup = (email: string, password: string) =>
  api.post<AuthPayload>("/auth/signup", { email, password });

export const login = (email: string, password: string) =>
  api.post<AuthPayload>("/auth/login", { email, password });
