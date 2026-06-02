"use client";

import { useEffect } from "react";
import { useStore } from "@/store";

export default function StoreHydration() {
  useEffect(() => {
    useStore.persist.rehydrate();
    useStore.getState().setHydrated();
  }, []);

  return null;
}
