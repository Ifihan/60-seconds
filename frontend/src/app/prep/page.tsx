"use client";

import { useEffect, useState, useCallback, useRef } from "react";
import { useRouter } from "next/navigation";
import Nav from "@/components/Nav/Nav";
import { useStore } from "@/store";
import { formatTime } from "@/utils/formatTime";
import { generateTone } from "@/utils/generateTone";
import styles from "./page.module.css";

export default function PrepPage() {
  const router = useRouter();
  const {
    currentTopic,
    selectedArea,
    token,
    prepTimeRemaining,
    setPrepTimeRemaining,
    prepNotes,
    setPrepNotes,
    _hydrated,
  } = useStore();

  const [flashing, setFlashing] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const expiredRef = useRef(false);

  useEffect(() => {
    if (!_hydrated) return;
    if (!currentTopic) { router.replace("/"); return; }
  }, [currentTopic, _hydrated, router]);

  const goToRecord = useCallback((manual = false) => {
    if (intervalRef.current) clearInterval(intervalRef.current);
    if (manual) {
      router.push("/record");
    } else {
      setFlashing(true);
      setTimeout(() => router.push("/record"), 250);
    }
  }, [router]);

  useEffect(() => {
    if (!currentTopic) return;

    expiredRef.current = false;
    intervalRef.current = setInterval(() => {
      const current = useStore.getState().prepTimeRemaining;
      if (current <= 0) return;

      const next = current - 1;
      setPrepTimeRemaining(next);

      if (next <= 0 && !expiredRef.current) {
        expiredRef.current = true;
        clearInterval(intervalRef.current!);
        generateTone(880, 0.4);
        goToRecord();
      }
    }, 1000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [currentTopic, setPrepTimeRemaining, goToRecord]);

  if (!_hydrated || !currentTopic) return null;

  return (
    <>
      <Nav />
      {flashing && <div className={styles.flash} aria-hidden />}
      <main className={styles.page}>
        <button type="button" className={styles.backBtn} onClick={() => router.back()}>
          ← Back
        </button>

        {/* Left: topic + timer */}
        <section className={styles.left}>
          {selectedArea && (
            <p className={styles.areaLabel}>
              {selectedArea.name}
            </p>
          )}
          <h1 className={styles.topic}>{currentTopic}</h1>

          <div
            role="timer"
            aria-live="polite"
            aria-label={`${formatTime(prepTimeRemaining)} remaining`}
            className={styles.timer}
          >
            {formatTime(prepTimeRemaining)}
          </div>
          </section>

        {/* Right: notes */}
        <section className={styles.right}>
          <div className={styles.notesHeader}>
            <span className={styles.notesLabel}>Notes</span>
            <button type="button" className={styles.notesSkip} onClick={() => goToRecord(true)}>
              {token ? "Start now →" : "Start timer →"}
            </button>
          </div>
          <textarea
            className={styles.textarea}
            value={prepNotes}
            onChange={(e) => setPrepNotes(e.target.value)}
            placeholder="Write anything. No one will see this."
            aria-label="Prep notes"
          />
        </section>
      </main>
    </>
  );
}
