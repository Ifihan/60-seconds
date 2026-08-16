"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Nav from "@/components/Nav/Nav";
import Button from "@/components/Button/Button";
import AreaRow from "@/components/AreaRow/AreaRow";
import DailyTopicCard from "@/components/DailyTopicCard/DailyTopicCard";
import { useStore, type Area } from "@/store";
import { getAreas } from "@/api/areas";
import styles from "./page.module.css";

export default function Home() {
  const router = useRouter();
  const { user, setSelectedArea, resetSession } = useStore();
  const [areas, setAreas] = useState<Area[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  // Guests see all global areas; logged-in see subscribed + their own
  const allDisplayAreas = user
    ? areas.filter((a) => a.is_subscribed || a.is_own)
    : areas.filter((a) => !a.is_own);
  const SIDEBAR_LIMIT = 5;
  const displayAreas = allDisplayAreas.slice(0, SIDEBAR_LIMIT);
  const hasMore = allDisplayAreas.length > SIDEBAR_LIMIT;

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

  function prepareArea(area: Area) {
    resetSession();
    setSelectedArea(area);
  }

  return (
    <>
      <Nav />
      <main className={styles.page}>
        {/* Left hero */}
        <section className={styles.hero}>
          {!loading && !error && <DailyTopicCard areas={areas} />}
          <h1 className={styles.heroTitle}>
            Spin a<br />topic.
          </h1>
          <div className={styles.spinRow}>
            <Button
              variant="primary"
              onClick={() => router.push("/areas")}
            >
              Pick an area →
            </Button>
            <p className={styles.spinHint}>
              {user
                ? "Or pick from the sidebar."
                : "Browse areas and pick a topic."}
            </p>
          </div>
        </section>

        {/* Right sidebar */}
        <aside className={styles.sidebar}>
          <div className={styles.sidebarHeader}>
            <span className={styles.sidebarTitle}>
              {user ? "Your Areas" : "Available Areas"}
            </span>
            {user && (
              <Link href="/areas" className={styles.addBtn}>+ Add</Link>
            )}
          </div>

          {loading && !error && <p className={styles.empty}>Loading…</p>}

          {error && (
            <div className={styles.retryWrap}>
              <p className={styles.empty}>Couldn&apos;t load areas.</p>
              <button
                type="button"
                className={styles.retryBtn}
                onClick={() => { setLoading(true); fetchAreas(); }}
              >
                Retry →
              </button>
            </div>
          )}

          {!loading && displayAreas.length === 0 && user && (
            <div className={styles.authEmptyState}>
              <h2 className={styles.authEmptyTitle}>No areas yet.</h2>
              <p className={styles.authEmptyBody}>
                Subscribe to a global area or create your own with custom topics.
              </p>
              <div className={styles.authEmptyActions}>
                <Link href="/areas" className={styles.authPrimaryLink}>
                  Browse &amp; subscribe →
                </Link>
                <Link href="/areas/new" className={styles.authSecondaryLink}>
                  Create your own
                </Link>
              </div>
            </div>
          )}

          {!loading && displayAreas.length > 0 && displayAreas.map((area) => (
            <AreaRow
              key={area.id}
              area={area}
              href={`/spin/${area.id}`}
              onClick={() => prepareArea(area)}
            />
          ))}

          {!loading && hasMore && (
            <Link href="/areas" className={styles.seeAllLink}>
              See all areas →
            </Link>
          )}

          {/* Guest: sign-in prompt at bottom */}
          {!user && !loading && (
            <div className={styles.guestBanner}>
              <p className={styles.guestBannerText}>
                Sign in to create your own areas, subscribe, and track history.
              </p>
              <div className={styles.guestBannerLinks}>
                <Link href="/signup" className={styles.authPrimaryLink}>
                  Create account →
                </Link>
                <Link href="/login" className={styles.authSecondaryLink}>
                  Sign in
                </Link>
              </div>
            </div>
          )}
        </aside>
      </main>
    </>
  );
}
