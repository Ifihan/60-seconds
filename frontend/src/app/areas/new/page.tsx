"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Nav from "@/components/Nav/Nav";
import { useStore } from "@/store";
import { createArea, addTopics } from "@/api/areas";
import styles from "./page.module.css";

interface Errors {
  name?: string;
  topics?: string;
  global?: string;
}

export default function NewAreaPage() {
  const router = useRouter();
  const { token } = useStore();

  const [name, setName] = useState("");
  const [topicsText, setTopicsText] = useState("");
  const [errors, setErrors] = useState<Errors>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!token) router.replace("/login");
  }, [token, router]);

  function validate(): Errors {
    const e: Errors = {};
    if (!name.trim()) e.name = "Area name is required";
    else if (name.trim().length > 100) e.name = "Max 100 characters";
    const lines = topicsText
      .split(/[\n,]/)
      .map((t) => t.trim())
      .filter(Boolean);
    if (lines.length === 0) e.topics = "Add at least one topic";
    else if (lines.length > 50) e.topics = "Maximum 50 topics at once";
    else if (lines.some((l) => l.length > 200)) e.topics = "Each topic max 200 characters";
    return e;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }

    setLoading(true);
    setErrors({});

    const topicNames = topicsText
      .split(/[\n,]/)
      .map((t) => t.trim())
      .filter(Boolean);

    try {
      const { data: area } = await createArea(name.trim());
      await addTopics(area.id, topicNames);
      router.push("/");
    } catch (err: unknown) {
      const status = (err as { response?: { status?: number } })?.response?.status;
      const msg =
        (err as { response?: { data?: { error?: { message?: string } } } })
          ?.response?.data?.error?.message ??
        (status === 409 ? "An area with that name already exists" : "Something went wrong");
      setErrors({ global: msg });
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <Nav />
      <main className={styles.page}>
        <div className={styles.inner}>
          <Link href="/areas" className={styles.back}>← Back to areas</Link>

          <p className={styles.eyebrow}>Create area</p>
          <h1 className={styles.title}>Build your own area.</h1>
          <p className={styles.subtitle}>
            Name your area and add the topics you want to practice. Only you can see and spin from it.
          </p>

          <form className={styles.form} onSubmit={handleSubmit} noValidate>
            {errors.global && (
              <div className={styles.globalError}>{errors.global}</div>
            )}

            <div className={styles.field}>
              <label className={styles.label} htmlFor="name">Area name</label>
              <input
                id="name"
                type="text"
                className={`${styles.input} ${errors.name ? styles.inputError : ""}`}
                placeholder="e.g. Medicine, Philosophy, Finance"
                value={name}
                onChange={(e) => setName(e.target.value)}
                maxLength={100}
              />
              {errors.name && <span className={styles.fieldError}>{errors.name}</span>}
            </div>

            <div className={styles.field}>
              <label className={styles.label} htmlFor="topics">Topics</label>
              <textarea
                id="topics"
                className={`${styles.textarea} ${errors.topics ? styles.inputError : ""}`}
                placeholder={"One topic per line, or comma-separated:\nThe heart and circulatory system\nHow vaccines work\nAntibiotic resistance"}
                value={topicsText}
                onChange={(e) => setTopicsText(e.target.value)}
              />
              <span className={styles.hint}>
                Up to 50 topics · Each max 200 characters
              </span>
              {errors.topics && <span className={styles.fieldError}>{errors.topics}</span>}
            </div>

            <button type="submit" className={styles.submitBtn} disabled={loading}>
              {loading ? "Creating…" : "Create area →"}
            </button>
          </form>
        </div>
      </main>
    </>
  );
}
