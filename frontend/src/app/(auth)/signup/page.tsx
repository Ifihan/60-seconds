"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useStore } from "@/store";
import { signup } from "@/api/auth";
import styles from "../auth.module.css";

interface Errors {
  email?: string;
  password?: string;
  global?: string;
}

function SignupForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { setUser, setToken } = useStore();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState<Errors>({});
  const [loading, setLoading] = useState(false);

  function validate(): Errors {
    const e: Errors = {};
    if (!email) e.email = "Email is required";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) e.email = "Invalid email";
    if (!password) e.password = "Password is required";
    else if (password.length < 8) e.password = "Minimum 8 characters";
    else if (password.length > 128) e.password = "Maximum 128 characters";
    return e;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }

    setLoading(true);
    setErrors({});

    try {
      const { data } = await signup(email, password);
      setToken(data.token);
      setUser(data.user);
      const returnTo = searchParams.get("returnTo") ?? "/areas";
      router.push(returnTo);
    } catch (err: unknown) {
      const status = (err as { response?: { status?: number } })?.response?.status;
      const msg =
        (err as { response?: { data?: { error?: { message?: string } } } })
          ?.response?.data?.error?.message ??
        (status === 409 ? "Email already in use" : "Something went wrong");
      setErrors({ global: msg });
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className={styles.page}>
      {/* Left */}
      <div className={styles.left}>
        <div className={styles.topBar}>
          <button type="button" className={styles.backBtn} onClick={() => router.back()} aria-label="Go back">
            ← Back
          </button>
        </div>
        <h1 className={styles.headline}>
          Start<br />speaking.
        </h1>
        <p className={styles.subtext}>
          Pick areas, spin a topic, and record your 60 seconds.
          Your history syncs across devices.
        </p>
      </div>

      {/* Right */}
      <div className={styles.right}>
        <form className={styles.form} onSubmit={handleSubmit} noValidate>
          {errors.global && (
            <div className={styles.globalError}>{errors.global}</div>
          )}

          <div className={styles.field}>
            <label className={styles.fieldLabel} htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              className={`${styles.input} ${errors.email ? styles.inputError : ""}`}
              placeholder="you@domain.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
            />
            {errors.email && <span className={styles.fieldError}>{errors.email}</span>}
          </div>

          <div className={styles.field}>
            <label className={styles.fieldLabel} htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              className={`${styles.input} ${errors.password ? styles.inputError : ""}`}
              placeholder="min 8 characters"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="new-password"
            />
            {errors.password && <span className={styles.fieldError}>{errors.password}</span>}
          </div>

          <button type="submit" className={styles.submitBtn} disabled={loading}>
            {loading ? "Creating account…" : "Create account →"}
          </button>

          <Link href="/login" className={styles.altLink}>
            Sign in instead
          </Link>
        </form>
      </div>
    </main>
  );
}

export default function SignupPage() {
  return (
    <Suspense>
      <SignupForm />
    </Suspense>
  );
}
