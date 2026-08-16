"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import Button from "@/components/Button/Button";
import { useStore, type Area } from "@/store";
import { getDailyTopic } from "@/api/dailyTopic";
import { getTopics } from "@/api/areas";
import { pickDailyTopic, todayUTC } from "@/utils/dailyTopic";
import styles from "./DailyTopicCard.module.css";

interface Props {
  areas: Area[];
}

interface Resolved {
  area: Area;
  topicName: string;
}

export default function DailyTopicCard({ areas }: Props) {
  const router = useRouter();
  const {
    user,
    guestPreferredAreaId,
    guestDailyTopic,
    setGuestDailyTopic,
    setSelectedArea,
    setCurrentTopic,
    resetSession,
  } = useStore();

  const [resolved, setResolved] = useState<Resolved | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function loadSignedIn() {
      const preferredArea = areas.find((a) => a.is_preferred);
      if (!preferredArea) {
        if (!cancelled) setResolved(null);
        return;
      }
      try {
        const { data } = await getDailyTopic();
        if (!cancelled && data) {
          setResolved({ area: preferredArea, topicName: data.topic_name });
        } else if (!cancelled) {
          setResolved(null);
        }
      } catch {
        if (!cancelled) setResolved(null);
      }
    }

    async function loadGuest() {
      if (!guestPreferredAreaId) {
        if (!cancelled) setResolved(null);
        return;
      }
      const area = areas.find((a) => a.id === guestPreferredAreaId);
      if (!area) {
        if (!cancelled) setResolved(null);
        return;
      }

      const today = todayUTC();
      if (guestDailyTopic?.date === today && guestDailyTopic.areaId === guestPreferredAreaId) {
        if (!cancelled) setResolved({ area, topicName: guestDailyTopic.topicName });
        return;
      }

      try {
        const { data } = await getTopics(guestPreferredAreaId);
        const topicName = pickDailyTopic(today, guestPreferredAreaId, data);
        if (!topicName) {
          if (!cancelled) setResolved(null);
          return;
        }
        setGuestDailyTopic({
          date: today,
          areaId: guestPreferredAreaId,
          areaName: area.name,
          topicName,
        });
        if (!cancelled) setResolved({ area, topicName });
      } catch {
        if (!cancelled) setResolved(null);
      }
    }

    setLoading(true);
    const run = user ? loadSignedIn() : loadGuest();
    run.finally(() => {
      if (!cancelled) setLoading(false);
    });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [areas, user, guestPreferredAreaId]);

  function handleStartPrep() {
    if (!resolved) return;
    resetSession();
    setCurrentTopic(resolved.topicName);
    setSelectedArea(resolved.area);
    router.push("/prep");
  }

  if (loading) return null;

  if (!resolved) {
    return (
      <div className={styles.card}>
        <p className={styles.label}>Topic of the day</p>
        <p className={styles.promptBody}>
          Pick an area for a fresh topic every day.
        </p>
        <Link href="/areas" className={styles.promptLink}>
          Pick an area →
        </Link>
      </div>
    );
  }

  return (
    <div className={styles.card}>
      <p className={styles.label}>Topic of the day · {resolved.area.name}</p>
      <h2 className={styles.topic}>{resolved.topicName}</h2>
      <Button variant="primary" onClick={handleStartPrep}>
        Start Prep →
      </Button>
    </div>
  );
}
