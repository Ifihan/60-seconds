"use client";

import { create } from "zustand";
import {
  persist,
  createJSONStorage,
  type StateStorage,
} from "zustand/middleware";

export interface Area {
  id: string;
  name: string;
  topic_count: number;
  is_subscribed: boolean;
  is_own: boolean;
  created_at: string;
}

export interface Topic {
  id: string;
  name: string;
  created_at: string;
}

export interface User {
  id: string;
  email: string;
}

interface Store {
  // Auth
  user: User | null;
  token: string | null;

  // Session flow
  selectedArea: Area | null;
  currentTopic: string | null;
  prepTimeRemaining: number;
  prepNotes: string;

  // Theme
  theme: "dark" | "light";

  // Actions
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;

  setSelectedArea: (area: Area | null) => void;
  setCurrentTopic: (topic: string | null) => void;
  setPrepTimeRemaining: (seconds: number) => void;
  setPrepNotes: (notes: string) => void;
  resetSession: () => void;

  toggleTheme: () => void;

  // Hydration tracking (not persisted)
  _hydrated: boolean;
  setHydrated: () => void;
}

const noopStorage: StateStorage = {
  getItem: () => null,
  setItem: () => undefined,
  removeItem: () => undefined,
};

const getStorage = () =>
  typeof window !== "undefined" ? window.localStorage : noopStorage;

export const useStore = create<Store>()(
  persist(
    (set) => ({
      user: null,
      token: null,

      selectedArea: null,
      currentTopic: null,
      prepTimeRemaining: 300,
      prepNotes: "",

      theme: "light",

      setUser: (user) => set({ user }),
      setToken: (token) => set({ token }),
      logout: () =>
        set({
          user: null,
          token: null,
          selectedArea: null,
          currentTopic: null,
          prepTimeRemaining: 300,
          prepNotes: "",
        }),

      setSelectedArea: (area) => set({ selectedArea: area }),
      setCurrentTopic: (topic) => set({ currentTopic: topic }),
      setPrepTimeRemaining: (seconds) =>
        set({ prepTimeRemaining: seconds }),
      setPrepNotes: (notes) => set({ prepNotes: notes }),
      resetSession: () =>
        set({
          selectedArea: null,
          currentTopic: null,
          prepTimeRemaining: 300,
          prepNotes: "",
        }),

      toggleTheme: () =>
        set((s) => ({ theme: s.theme === "dark" ? "light" : "dark" })),

      _hydrated: false,
      setHydrated: () => set({ _hydrated: true }),
    }),
    {
      name: "60s-store",
      skipHydration: true,
      storage: createJSONStorage(getStorage),
      partialize: (s) => ({
        user: s.user,
        token: s.token,
        theme: s.theme,
        currentTopic: s.currentTopic,
        selectedArea: s.selectedArea,
        prepTimeRemaining: s.prepTimeRemaining,
      }),
    }
  )
);
