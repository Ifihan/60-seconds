"use client";

import { useRef, useState, useCallback } from "react";

export type RecordMode = "AUDIO" | "VIDEO";

interface UseMediaRecorderOptions {
  mode: RecordMode;
  onStop?: (blob: Blob) => void;
}

export function useMediaRecorder({ mode, onStop }: UseMediaRecorderOptions) {
  const [recording, setRecording] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const streamRef = useRef<MediaStream | null>(null);

  const start = useCallback(async () => {
    setError(null);
    try {
      const constraints =
        mode === "VIDEO"
          ? { audio: true, video: true }
          : { audio: true };

      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      streamRef.current = stream;

      const mr = new MediaRecorder(stream);
      mediaRecorderRef.current = mr;
      chunksRef.current = [];

      mr.ondataavailable = (e) => {
        if (e.data.size > 0) chunksRef.current.push(e.data);
      };

      mr.onstop = () => {
        const blob = new Blob(chunksRef.current, {
          type: mode === "VIDEO" ? "video/webm" : "audio/webm",
        });
        onStop?.(blob);
        stream.getTracks().forEach((t) => t.stop());
        streamRef.current = null;
        setRecording(false);
      };

      mr.start();
      setRecording(true);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Could not access microphone"
      );
    }
  }, [mode, onStop]);

  const stop = useCallback(() => {
    mediaRecorderRef.current?.stop();
  }, []);

  const getStream = () => streamRef.current;

  return { recording, error, start, stop, getStream };
}
