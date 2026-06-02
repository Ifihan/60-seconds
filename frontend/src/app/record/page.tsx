"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Nav from "@/components/Nav/Nav";
import Button from "@/components/Button/Button";
import Toggle from "@/components/Toggle/Toggle";
import RecordButton from "@/components/RecordButton/RecordButton";
import { useStore } from "@/store";
import { useMediaRecorder, type RecordMode } from "@/hooks/useMediaRecorder";
import { logSession } from "@/api/sessions";
import { formatTime } from "@/utils/formatTime";
import { generateTone } from "@/utils/generateTone";
import styles from "./page.module.css";

const RECORD_SECONDS = 60;

export default function RecordPage() {
  const router = useRouter();
  const { currentTopic, selectedArea, token, resetSession, _hydrated } = useStore();

  const [mode, setMode] = useState<RecordMode>("AUDIO");
  const [remaining, setRemaining] = useState(() => {
    if (typeof window === "undefined") return RECORD_SECONDS;
    const saved = sessionStorage.getItem("60s-record-remaining");
    return saved ? parseInt(saved, 10) : RECORD_SECONDS;
  });
  const [timerKey, setTimerKey] = useState(0);
  const [done, setDone] = useState(false);
  const [timerStarted, setTimerStarted] = useState(false);
  const [didRecord, setDidRecord] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  // Guest-mode timer (no MediaRecorder)
  const [guestStarted, setGuestStarted] = useState(false);
  const [guestRemaining, setGuestRemaining] = useState(RECORD_SECONDS);
  const [guestDone, setGuestDone] = useState(false);
  const [guestStopped, setGuestStopped] = useState(false);
  const guestIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    if (!_hydrated) return;
    if (!currentTopic) router.replace("/");
  }, [currentTopic, _hydrated, router]);

  // Persist record timer across refreshes
  useEffect(() => {
    sessionStorage.setItem("60s-record-remaining", String(remaining));
  }, [remaining]);

  // Guest countdown
  useEffect(() => {
    if (!guestStarted) return;
    guestIntervalRef.current = setInterval(() => {
      setGuestRemaining((r) => {
        if (r <= 1) {
          clearInterval(guestIntervalRef.current!);
          generateTone(880, 0.4);
          setGuestStarted(false);
          setGuestDone(true);
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => { if (guestIntervalRef.current) clearInterval(guestIntervalRef.current); };
  }, [guestStarted]);

  const handleStop = useCallback(
    (blob: Blob) => {
      const url = URL.createObjectURL(blob);
      const ext = "webm";
      const filename = `${currentTopic?.replace(/\s+/g, "_") ?? "session"}_${Date.now()}.${ext}`;
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      a.click();
      setTimeout(() => URL.revokeObjectURL(url), 5000);
      // Session is logged when the timer completes, not here
    },
    [currentTopic]
  );

  const { recording, error, start, stop, getStream } = useMediaRecorder({
    mode,
    onStop: handleStop,
  });

  // Refs so the timer interval can read fresh values without stale closure issues
  const recordingRef = useRef(recording);
  useEffect(() => { recordingRef.current = recording; }, [recording]);
  const stopRef = useRef(stop);
  useEffect(() => { stopRef.current = stop; }, [stop]);
  const modeRef = useRef(mode);
  useEffect(() => { modeRef.current = mode; }, [mode]);

  useEffect(() => {
    if (recording && mode === "VIDEO" && videoRef.current) {
      const stream = getStream();
      if (stream) {
        videoRef.current.srcObject = stream;
        videoRef.current.play().catch(() => {});
      }
    }
  }, [recording, mode, getStream]);

  // Signed-in timer — starts when user clicks "Start timer", recording is independent
  useEffect(() => {
    if (!token || done || !timerStarted) return;
    intervalRef.current = setInterval(() => {
      setRemaining((r) => {
        if (r <= 1) {
          clearInterval(intervalRef.current!);
          generateTone(880, 0.4);
          if (recordingRef.current) stopRef.current();
          const { token: t, selectedArea: a, currentTopic: ct } = useStore.getState();
          if (t && a && ct) {
            logSession({
              area_id: a.id,
              topic: ct,
              mode: modeRef.current,
              completed_at: new Date().toISOString(),
            }).catch(() => {});
          }
          sessionStorage.removeItem("60s-record-remaining");
          setDone(true);
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [timerKey, token, done, timerStarted]);

  async function handleRecordClick() {
    if (recording) {
      stop();
    } else {
      await start();
      setDidRecord(true);
    }
  }

  function handleGoHome() {
    sessionStorage.removeItem("60s-record-remaining");
    if (intervalRef.current) clearInterval(intervalRef.current);
    resetSession();
    router.push("/");
  }

  function handleStartAgain() {
    sessionStorage.removeItem("60s-record-remaining");
    if (intervalRef.current) clearInterval(intervalRef.current);
    setDone(false);
    setRemaining(RECORD_SECONDS);
    setDidRecord(false);
    setTimerStarted(false);
    setTimerKey((k) => k + 1);
  }

  function handleGuestStop() {
    if (guestIntervalRef.current) clearInterval(guestIntervalRef.current);
    setGuestStarted(false);
    setGuestStopped(true);
  }

  function handleGuestRestart() {
    setGuestStopped(false);
    setGuestRemaining(RECORD_SECONDS);
    setGuestStarted(true);
  }

  if (!_hydrated || !currentTopic) return null;

  // Guest mode — timer only, no recording
  if (!token) {
    return (
      <>
        <Nav />
        <main className={styles.page}>
          <p className={styles.eyebrow}>Practice</p>
          <p className={styles.breadcrumb}>
            {selectedArea?.name} · {currentTopic}
          </p>

          <div
            role="timer"
            aria-live="polite"
            aria-label={`${formatTime(guestRemaining)} remaining`}
            className={styles.timer}
          >
            {formatTime(guestRemaining)}
          </div>

          <div className={styles.controls}>
            {!guestStarted && !guestDone && !guestStopped && (
              <Button variant="primary" onClick={() => setGuestStarted(true)}>
                Start timer →
              </Button>
            )}
            {guestStarted && (
              <Button variant="ghost" onClick={handleGuestStop}>
                Stop
              </Button>
            )}
            {guestStopped && !guestDone && (
              <Button variant="primary" onClick={handleGuestRestart}>
                Start again →
              </Button>
            )}
          </div>

          {guestDone ? (
            <div className={styles.guestSignup}>
              <p className={styles.guestSignupText}>
                Nice work.{" "}
                <Link href="/signup" className={styles.guestLink}>Create an account</Link>
                {" "}to record and save your sessions.
              </p>
              <Button variant="ghost" onClick={handleGoHome}>Go Home</Button>
            </div>
          ) : (
            <p className={styles.guestNote}>
              <Link href="/login" className={styles.guestLink}>Sign in</Link>
              {" "}or{" "}
              <Link href="/signup" className={styles.guestLink}>create an account</Link>
              {" "}to record and save.
            </p>
          )}
        </main>
      </>
    );
  }

  if (done) {
    return (
      <>
        <Nav />
        <main className={styles.page}>
          <div className={styles.doneWrap}>
            <h1 className={styles.doneTitle}>Session logged.</h1>
            <div className={styles.doneMeta}>
              <span>{currentTopic}</span>
              {selectedArea && <span>{selectedArea.name}</span>}
              <span>
                {didRecord ? `${mode === "AUDIO" ? "Audio" : "Video"} · ` : ""}{new Date().toLocaleDateString()}
              </span>
            </div>
            <Button variant="primary" onClick={handleStartAgain}>
              Start again →
            </Button>
            <Button variant="ghost" onClick={handleGoHome}>
              Go Home
            </Button>
            <Link href="/history">
              <Button variant="ghost">View History</Button>
            </Link>
          </div>
        </main>
      </>
    );
  }

  return (
    <>
      <Nav />
      <main className={styles.page}>
        <p className={`${styles.eyebrow} ${recording ? styles.eyebrowRecording : ""}`}>
          {recording && <span className={styles.dot} />}
          {recording ? `Recording · ${mode === "AUDIO" ? "Audio" : "Video"}` : "Practice"}
        </p>

        <p className={styles.breadcrumb}>
          {selectedArea?.name} · {currentTopic}
        </p>

        <div
          role="timer"
          aria-live="polite"
          aria-label={`${formatTime(remaining)} remaining`}
          className={styles.timer}
        >
          {formatTime(remaining)}
        </div>

        <div className={styles.toggle}>
          <Toggle
            options={["AUDIO", "VIDEO"]}
            value={mode}
            onChange={(v) => {
              if (!recording) setMode(v as RecordMode);
            }}
          />
        </div>

        {error && <p className={styles.error}>{error}</p>}

        <div className={styles.controls}>
          {!timerStarted ? (
            <Button variant="primary" onClick={() => setTimerStarted(true)}>
              Start timer →
            </Button>
          ) : (
            <RecordButton
              recording={recording}
              disabled={done}
              onClick={handleRecordClick}
            />
          )}
        </div>

        {recording && mode === "VIDEO" && (
          <video
            ref={videoRef}
            className={styles.videoPreview}
            muted
            playsInline
            aria-label="Live video preview"
          />
        )}
      </main>
    </>
  );
}
