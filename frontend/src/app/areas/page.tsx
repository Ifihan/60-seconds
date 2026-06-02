"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Nav from "@/components/Nav/Nav";
import { useStore, type Area } from "@/store";
import { getAreas, subscribeArea, unsubscribeArea } from "@/api/areas";
import styles from "./page.module.css";

type Filter = "ALL" | "SUBSCRIBED" | "OWN";

export default function AreasPage() {
  const router = useRouter();
  const { token } = useStore();
  const [areas, setAreas] = useState<Area[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [filter, setFilter] = useState<Filter>("ALL");
  const [pending, setPending] = useState<Set<string>>(new Set());

  // Guests can browse global areas — no auth redirect here

  const fetchAreas = useCallback(async () => {
    setError(false);
    try {
      const { data } = await getAreas();
      setAreas(data);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchAreas();
  }, [fetchAreas]);

  async function toggleSubscribe(area: Area) {
    if (pending.has(area.id) || area.is_own) return;
    setPending((p) => new Set(p).add(area.id));
    try {
      if (area.is_subscribed) {
        await unsubscribeArea(area.id);
      } else {
        await subscribeArea(area.id);
      }
      setAreas((prev) =>
        prev.map((a) =>
          a.id === area.id ? { ...a, is_subscribed: !a.is_subscribed } : a
        )
      );
    } catch {
      // ignore
    } finally {
      setPending((p) => {
        const next = new Set(p);
        next.delete(area.id);
        return next;
      });
    }
  }

  const globalAreas = areas.filter((a) => !a.is_own);
  const ownAreas = areas.filter((a) => a.is_own);

  const filtered = filter === "SUBSCRIBED"
    ? globalAreas.filter((a) => a.is_subscribed)
    : filter === "OWN"
    ? ownAreas
    : globalAreas;

  return (
    <>
      <Nav />
      <main className={styles.page}>
        <div className={styles.inner}>
          <button type="button" className={styles.backBtn} onClick={() => router.back()}>
            ← Back
          </button>

          <div className={styles.header}>
            <div>
              <h1 className={styles.title}>Browse &amp; subscribe</h1>
              <p className={styles.subtitle}>
                {token
                  ? "Subscribe to global areas, or create your own with custom topics."
                  : "Pick an area to spin a topic. Sign in to subscribe and create your own."}
              </p>
            </div>
            {token && (
              <Link href="/areas/new" className={styles.createBtn}>
                + Create area
              </Link>
            )}
          </div>

          {token && (
            <div className={styles.filterRow} role="group" aria-label="Filter areas">
              {(["ALL", "SUBSCRIBED", "OWN"] as Filter[]).map((f) => (
                <button
                  key={f}
                  type="button"
                  className={`${styles.chip} ${filter === f ? styles.chipActive : ""}`}
                  onClick={() => setFilter(f)}
                  aria-pressed={filter === f}
                >
                  {f === "ALL" ? "All" : f === "SUBSCRIBED" ? "Subscribed" : "My areas"}
                </button>
              ))}
            </div>
          )}

          {loading && !error && <p className={styles.loading}>Loading areas…</p>}

          {error && (
            <div className={styles.retryWrap}>
              <p className={styles.loading}>Couldn&apos;t load areas.</p>
              <button
                type="button"
                className={styles.retryBtn}
                onClick={() => { setLoading(true); fetchAreas(); }}
              >
                Retry →
              </button>
            </div>
          )}

          {/* Own areas (only shown in "My areas" filter or when filter is ALL) */}
          {!loading && filter === "OWN" && ownAreas.length === 0 && (
            <p className={styles.loading}>
              No custom areas yet.{" "}
              <Link href="/areas/new" className={styles.createBtn}>Create one →</Link>
            </p>
          )}

          {!loading && filter !== "OWN" && filtered.length === 0 && (
            <p className={styles.loading}>No areas found.</p>
          )}

          {!loading && filtered.map((area) => (
            <AreaCard
              key={area.id}
              area={area}
              busy={pending.has(area.id)}
              onToggle={() => toggleSubscribe(area)}
              isGuest={!token}
            />
          ))}

          {/* Own areas shown at the bottom when filter is ALL */}
          {!loading && filter === "ALL" && ownAreas.length > 0 && (
            <div className={styles.section}>
              <p className={styles.sectionLabel}>My areas</p>
              {ownAreas.map((area) => (
                <AreaCard key={area.id} area={area} busy={false} onToggle={() => {}} isGuest={false} />
              ))}
            </div>
          )}
        </div>
      </main>
    </>
  );
}

function AreaCard({
  area,
  busy,
  onToggle,
  isGuest,
}: {
  area: Area;
  busy: boolean;
  onToggle: () => void;
  isGuest: boolean;
}) {
  return (
    <div className={styles.areaCard}>
      <span className={styles.areaName}>{area.name}</span>
      <span className={styles.areaCount}>{area.topic_count} topics</span>
      {area.is_own ? (
        <>
          <span className={styles.ownBadge}>Mine</span>
          <Link href={`/spin/${area.id}`} className={styles.spinLink}>↺ Spin</Link>
        </>
      ) : isGuest ? (
        <Link href={`/spin/${area.id}`} className={styles.spinLink}>↺ Spin</Link>
      ) : (
        <>
          <button
            type="button"
            className={`${styles.subBtn} ${area.is_subscribed ? styles.subBtnActive : ""}`}
            onClick={onToggle}
            disabled={busy}
            aria-pressed={area.is_subscribed}
          >
            {busy ? "…" : area.is_subscribed ? "Subscribed" : "+ Add"}
          </button>
          <Link href={`/spin/${area.id}`} className={styles.spinLink}>↺ Spin</Link>
        </>
      )}
    </div>
  );
}
