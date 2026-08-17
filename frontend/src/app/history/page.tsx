"use client";

import { Fragment, useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Nav from "@/components/Nav/Nav";
import { useStore } from "@/store";
import { getAreas } from "@/api/areas";
import { getSessions, type Session } from "@/api/sessions";
import SpeechFeedback from "@/components/SpeechFeedback/SpeechFeedback";
import type { Area } from "@/store";
import styles from "./page.module.css";

const LIMIT = 20;

export default function HistoryPage() {
  const router = useRouter();
  const { token, _hydrated } = useStore();

  const [sessions, setSessions] = useState<Session[]>([]);
  const [areas, setAreas] = useState<Area[]>([]);
  const [selectedAreaId, setSelectedAreaId] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    if (!_hydrated) return;
    if (!token) { router.replace("/login?returnTo=/history"); return; }
  }, [token, _hydrated, router]);

  const fetchSessions = useCallback(async () => {
    if (!token || !_hydrated) return;
    setLoading(true);
    try {
      const { data } = await getSessions({
        area_id: selectedAreaId ?? undefined,
        page,
        limit: LIMIT,
      });
      setSessions(data.data);
      setTotal(data.pagination.total);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  }, [token, _hydrated, selectedAreaId, page]);

  useEffect(() => {
    fetchSessions();
  }, [fetchSessions]);

  useEffect(() => {
    if (!token || !_hydrated) return;
    getAreas()
      .then(({ data }) => setAreas(data.filter((a) => a.is_subscribed || a.is_own)))
      .catch(() => {});
  }, [token, _hydrated]);

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <>
      <Nav />
      <main className={styles.page}>
        {/* Filter sidebar */}
        <aside className={styles.sidebar}>
          <p className={styles.filterLabel}>Filter</p>
          <div className={styles.filterList}>
            <button
              className={`${styles.filterItem} ${!selectedAreaId ? styles.filterItemActive : ""}`}
              onClick={() => { setSelectedAreaId(null); setPage(1); }}
            >
              All sessions
            </button>
            {areas.map((area) => (
              <button
                key={area.id}
                className={`${styles.filterItem} ${selectedAreaId === area.id ? styles.filterItemActive : ""}`}
                onClick={() => { setSelectedAreaId(area.id); setPage(1); }}
              >
                {area.name}
              </button>
            ))}
          </div>
        </aside>

        {/* Content */}
        <section className={styles.content}>
          <button type="button" className={styles.backBtn} onClick={() => router.back()}>
            ← Back
          </button>
          <div className={styles.header}>
            <h1 className={styles.title}>History</h1>
            {!loading && (
              <span className={styles.meta}>
                {total} session{total !== 1 ? "s" : ""} · {total} min total
              </span>
            )}
          </div>

          {loading && <p className={styles.empty}>Loading…</p>}

          {!loading && sessions.length === 0 && (
            <p className={styles.empty}>No sessions yet.</p>
          )}

          {!loading && sessions.length > 0 && (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th className={styles.th}>Topic</th>
                  <th className={styles.th}>Area</th>
                  <th className={styles.th}>Date</th>
                  <th className={styles.th}>Format</th>
                  <th className={styles.th}>Feedback</th>
                </tr>
              </thead>
              <tbody>
                {sessions.map((s) => (
                  <Fragment key={s.id}>
                    <tr className={styles.tr}>
                      <td className={`${styles.td} ${styles.tdTopic}`}>{s.topic}</td>
                      <td className={`${styles.td} ${styles.tdArea}`}>{s.area_name}</td>
                      <td className={`${styles.td} ${styles.tdDate}`}>
                        {new Date(s.completed_at).toLocaleDateString("en-US", {
                          month: "short",
                          day: "numeric",
                          year: "numeric",
                        })}
                      </td>
                      <td className={`${styles.td} ${styles.tdMode}`}>
                        {s.mode === "VIDEO" ? "Video" : "Audio"}
                      </td>
                      <td className={`${styles.td} ${styles.tdFeedback}`}>
                        {s.transcript ? (
                          <button
                            type="button"
                            className={styles.feedbackToggle}
                            onClick={() => setExpandedId(expandedId === s.id ? null : s.id)}
                          >
                            {expandedId === s.id ? "Hide" : "View"}
                          </button>
                        ) : (
                          <span className={styles.tdMode}>—</span>
                        )}
                      </td>
                    </tr>
                    {expandedId === s.id && (
                      <tr>
                        <td colSpan={5} className={styles.feedbackRow}>
                          <SpeechFeedback session={s} />
                        </td>
                      </tr>
                    )}
                  </Fragment>
                ))}
              </tbody>
            </table>
          )}

          {totalPages > 1 && (
            <div className={styles.pagination}>
              <button
                type="button"
                className={styles.pageBtn}
                disabled={page <= 1}
                onClick={() => setPage((p) => p - 1)}
              >
                ← Prev
              </button>
              <span className={styles.pageMeta}>
                Page {page} of {totalPages}
              </span>
              <button
                type="button"
                className={styles.pageBtn}
                disabled={page >= totalPages}
                onClick={() => setPage((p) => p + 1)}
              >
                Next →
              </button>
            </div>
          )}
        </section>
      </main>
    </>
  );
}
