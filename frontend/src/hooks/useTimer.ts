"use client";

import { useEffect, useRef, useCallback } from "react";
import { useStore } from "@/store";
import { generateTone } from "@/utils/generateTone";

interface UseTimerOptions {
  onExpire?: () => void;
  autoStart?: boolean;
}

export function usePrepTimer({ onExpire, autoStart = true }: UseTimerOptions = {}) {
  const { prepTimeRemaining, setPrepTimeRemaining } = useStore();
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const expiredRef = useRef(false);

  const stop = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  useEffect(() => {
    if (!autoStart) return;

    expiredRef.current = false;
    intervalRef.current = setInterval(() => {
      setPrepTimeRemaining(
        useStore.getState().prepTimeRemaining <= 0
          ? 0
          : useStore.getState().prepTimeRemaining - 1
      );

      if (useStore.getState().prepTimeRemaining <= 0 && !expiredRef.current) {
        expiredRef.current = true;
        stop();
        generateTone(880, 0.4);
        onExpire?.();
      }
    }, 1000);

    return stop;
  }, [autoStart, stop, onExpire, setPrepTimeRemaining]);

  return { remaining: prepTimeRemaining, stop };
}

export function useCountdown(initialSeconds: number, { onExpire }: UseTimerOptions = {}) {
  const remainingRef = useRef(initialSeconds);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const expiredRef = useRef(false);
  const forceUpdateRef = useRef<(() => void) | null>(null);

  const stop = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  useEffect(() => {
    remainingRef.current = initialSeconds;
    expiredRef.current = false;

    intervalRef.current = setInterval(() => {
      if (remainingRef.current <= 0) return;
      remainingRef.current -= 1;
      forceUpdateRef.current?.();

      if (remainingRef.current <= 0 && !expiredRef.current) {
        expiredRef.current = true;
        stop();
        generateTone(880, 0.4);
        onExpire?.();
      }
    }, 1000);

    return stop;
  }, [initialSeconds, stop, onExpire]);

  return { remainingRef, stop };
}
