"use client";

import { useEffect, useState, useRef, useCallback } from "react";
import { useParams, useRouter } from "next/navigation";
import Nav from "@/components/Nav/Nav";
import Button from "@/components/Button/Button";
import { useStore, type Area } from "@/store";
import { getAreas, getTopics } from "@/api/areas";
import styles from "./page.module.css";

const REEL_DURATION = 1800;

export default function SpinPage() {
  const { areaId } = useParams<{ areaId: string }>();
  const router = useRouter();
  const { setSelectedArea, setCurrentTopic, resetSession } = useStore();

  const [area, setArea] = useState<Area | null>(null);
  const [topics, setTopics] = useState<{ id: string; name: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [spinning, setSpinning] = useState(false);
  const [winner, setWinner] = useState<string | null>(null);
  const [reelTopics, setReelTopics] = useState<string[]>([]);

  const trackRef = useRef<HTMLDivElement>(null);
  const pickedRef = useRef<string>("");
  const hasSpun = useRef(false);

  useEffect(() => {
    async function load() {
      try {
        const [areasRes, topicsRes] = await Promise.all([
          getAreas(),
          getTopics(areaId),
        ]);
        const found = areasRes.data.find((a) => a.id === areaId) ?? null;
        setArea(found);
        if (found) setSelectedArea(found);
        setTopics(topicsRes.data);
      } catch {
        // ignore
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [areaId, setSelectedArea]);

  const spin = useCallback(
    (topicList: { id: string; name: string }[]) => {
      if (topicList.length === 0) return;
      if (topicList.length === 1) {
        setWinner(topicList[0].name);
        setCurrentTopic(topicList[0].name);
        return;
      }

      const pickedIndex = Math.floor(Math.random() * topicList.length);
      const picked = topicList[pickedIndex].name;
      pickedRef.current = picked;

      const padCount = 18;
      const reel: string[] = [];
      let prev = "";
      for (let i = 0; i < padCount; i++) {
        let next = topicList[Math.floor(Math.random() * topicList.length)].name;
        if (topicList.length > 1) {
          while (next === prev) {
            next = topicList[Math.floor(Math.random() * topicList.length)].name;
          }
        }
        reel.push(next);
        prev = next;
      }
      // Ensure the item right before the winner isn't the winner itself,
      // so the reel doesn't appear to "hover" on the answer before landing.
      if (reel[reel.length - 1] === picked && topicList.length > 1) {
        let filler = topicList[Math.floor(Math.random() * topicList.length)].name;
        while (filler === picked) {
          filler = topicList[Math.floor(Math.random() * topicList.length)].name;
        }
        reel[reel.length - 1] = filler;
      }
      reel.push(picked);

      setWinner(null);
      setReelTopics(reel);
      setSpinning(true);
    },
    [setCurrentTopic]
  );

  // Trigger animation after DOM renders new reel items
  useEffect(() => {
    if (!spinning || reelTopics.length === 0) return;

    let raf1: number;
    let raf2: number;
    let timer: ReturnType<typeof setTimeout>;

    raf1 = requestAnimationFrame(() => {
      raf2 = requestAnimationFrame(() => {
        const track = trackRef.current;
        if (!track) return;

        const items = track.querySelectorAll<HTMLElement>("[data-reel-item]");
        if (!items.length) return;

        const itemH = items[0].offsetHeight;
        if (!itemH) return;

        const viewH = track.parentElement?.offsetHeight ?? 320;
        const winnerIdx = reelTopics.length - 1;
        const targetY = -(itemH * winnerIdx - (viewH / 2 - itemH / 2));

        // Reset to top, force reflow, then animate
        track.style.transition = "none";
        track.style.transform = "translateY(0)";
        void track.getBoundingClientRect();

        track.style.transition = `transform ${REEL_DURATION}ms cubic-bezier(0.12, 0.82, 0.18, 1)`;
        track.style.transform = `translateY(${targetY}px)`;
      });
    });

    const picked = pickedRef.current;
    timer = setTimeout(() => {
      setSpinning(false);
      setWinner(picked);
      setCurrentTopic(picked);
    }, REEL_DURATION + 200);

    return () => {
      cancelAnimationFrame(raf1);
      cancelAnimationFrame(raf2);
      clearTimeout(timer);
    };
  }, [reelTopics, spinning, setCurrentTopic]);

  // Auto-spin once on load
  useEffect(() => {
    if (!loading && topics.length > 0 && !hasSpun.current) {
      hasSpun.current = true;
      spin(topics);
    }
  }, [loading, topics, spin]);

  function handleStartPrep() {
    if (!winner) return;
    resetSession();
    setCurrentTopic(winner);
    if (area) setSelectedArea(area);
    router.push("/prep");
  }

  function handleRespin() {
    hasSpun.current = true;
    spin(topics);
  }

  return (
    <>
      <Nav />
      <main className={styles.page}>
        <button type="button" className={styles.backBtn} onClick={() => router.back()}>
          ← Back
        </button>

        {loading && <p className={styles.loading}>Loading…</p>}

        {!loading && spinning && (
          <div className={styles.reelWrap}>
            <div className={styles.reelTrack} ref={trackRef}>
              {reelTopics.map((t, i) => (
                <div
                  key={i}
                  data-reel-item
                  className={`${styles.reelItem} ${i === reelTopics.length - 1 ? styles.reelItemSelected : ""}`}
                >
                  {t}
                </div>
              ))}
            </div>
            <div className={styles.lineTop} />
            <div className={styles.lineBottom} />
          </div>
        )}

        {!loading && winner && (
          <div className={styles.revealed}>
            <h1 className={styles.revealedTopic}>{winner}</h1>
            <div className={styles.revealedArea}>
              {area?.name}
            </div>
            <div className={styles.actions}>
              <Button variant="primary" onClick={handleStartPrep}>
                Start Prep →
              </Button>
              <Button variant="ghost" onClick={handleRespin}>
                ↺ Re-spin
              </Button>
            </div>
          </div>
        )}
      </main>
    </>
  );
}
