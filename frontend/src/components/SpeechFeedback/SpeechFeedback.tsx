"use client";

import Button from "@/components/Button/Button";
import type { Session } from "@/api/sessions";
import styles from "./SpeechFeedback.module.css";

interface Props {
  session: Session;
}

function buildReport(session: Session): string {
  return [
    `Topic: ${session.topic}`,
    `Area: ${session.area_name}`,
    session.analyzed_at ? `Analyzed: ${new Date(session.analyzed_at).toLocaleString()}` : "",
    "",
    `Filler words: ${session.filler_word_count ?? "-"}`,
    `Pace: ${session.words_per_minute ?? "-"} wpm`,
    `Coherence: ${session.coherence_score ?? "-"}/10`,
    `Grammar: ${session.grammar_score ?? "-"}/10`,
    `Content accuracy: ${session.content_accuracy_score ?? "-"}/10`,
    "",
    "Feedback:",
    session.feedback_summary ?? "",
    "",
    "Transcript:",
    session.transcript ?? "",
  ]
    .filter((line) => line !== "")
    .join("\n");
}

export default function SpeechFeedback({ session }: Props) {
  if (!session.transcript) return null;

  function handleDownload() {
    const text = buildReport(session);
    const blob = new Blob([text], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${session.topic.replace(/\s+/g, "_")}_feedback.txt`;
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 5000);
  }

  const stats: { label: string; value: string }[] = [
    { label: "Filler words", value: String(session.filler_word_count ?? "-") },
    { label: "Pace", value: `${session.words_per_minute ?? "-"} wpm` },
    { label: "Coherence", value: `${session.coherence_score ?? "-"}/10` },
    { label: "Grammar", value: `${session.grammar_score ?? "-"}/10` },
    { label: "Content accuracy", value: `${session.content_accuracy_score ?? "-"}/10` },
  ];

  return (
    <div className={styles.card}>
      <div className={styles.statGrid}>
        {stats.map((s) => (
          <div key={s.label} className={styles.stat}>
            <span className={styles.statValue}>{s.value}</span>
            <span className={styles.statLabel}>{s.label}</span>
          </div>
        ))}
      </div>

      {session.feedback_summary && (
        <p className={styles.summary}>{session.feedback_summary}</p>
      )}

      <details className={styles.transcript}>
        <summary className={styles.transcriptToggle}>Transcript</summary>
        <p className={styles.transcriptBody}>{session.transcript}</p>
      </details>

      <Button variant="ghost" onClick={handleDownload}>
        Download →
      </Button>
    </div>
  );
}
