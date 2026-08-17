"use client";

import { useRef, useState, useCallback } from "react";

export type RecordMode = "AUDIO" | "VIDEO";

export interface RecordingResult {
  blob: Blob;
  audioBlob: Blob;
}

interface UseMediaRecorderOptions {
  mode: RecordMode;
  onStop?: (result: RecordingResult) => void;
}

export function useMediaRecorder({ mode, onStop }: UseMediaRecorderOptions) {
  const [recording, setRecording] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const streamRef = useRef<MediaStream | null>(null);

  // VIDEO mode also runs a second, audio-only recorder off the same stream so
  // we can upload just the audio for analysis without sending the full video.
  const audioRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);

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

      let audioMr: MediaRecorder | null = null;
      if (mode === "VIDEO") {
        const audioOnlyStream = new MediaStream(stream.getAudioTracks());
        audioMr = new MediaRecorder(audioOnlyStream);
        audioRecorderRef.current = audioMr;
        audioChunksRef.current = [];
        audioMr.ondataavailable = (e) => {
          if (e.data.size > 0) audioChunksRef.current.push(e.data);
        };
      }

      mr.ondataavailable = (e) => {
        if (e.data.size > 0) chunksRef.current.push(e.data);
      };

      let stoppedCount = 0;
      const expectedStops = mode === "VIDEO" ? 2 : 1;
      const finish = () => {
        stoppedCount += 1;
        if (stoppedCount < expectedStops) return;

        const blob = new Blob(chunksRef.current, {
          type: mode === "VIDEO" ? "video/webm" : "audio/webm",
        });
        const audioBlob =
          mode === "VIDEO"
            ? new Blob(audioChunksRef.current, { type: "audio/webm" })
            : blob;

        onStop?.({ blob, audioBlob });
        stream.getTracks().forEach((t) => t.stop());
        streamRef.current = null;
        setRecording(false);
      };

      mr.onstop = finish;
      if (audioMr) audioMr.onstop = finish;

      mr.start();
      audioMr?.start();
      setRecording(true);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Could not access microphone"
      );
    }
  }, [mode, onStop]);

  const stop = useCallback(() => {
    mediaRecorderRef.current?.stop();
    audioRecorderRef.current?.stop();
  }, []);

  const getStream = () => streamRef.current;

  return { recording, error, start, stop, getStream };
}
