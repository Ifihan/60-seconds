"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useStore } from "@/store";
import { login } from "@/api/auth";
import styles from "../auth.module.css";

interface Errors {
  email?: string;
  password?: string;
  global?: string;
}

function LoginForm() {
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
    return e;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }

    setLoading(true);
    setErrors({});

    try {
      const { data } = await login(email, password);
      setToken(data.token);
      setUser(data.user);
      const returnTo = searchParams.get("returnTo") ?? "/";
      router.push(returnTo);
    } catch (err: unknown) {
      const msg =
        (err as { response?: { data?: { error?: { message?: string } } } })
          ?.response?.data?.error?.message ?? "Invalid email or password";
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
          Welcome<br />back.
        </h1>
        <p className={styles.subtext}>
          An account only syncs your history across devices.
          The drill itself never needs one.
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
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
            />
            {errors.password && <span className={styles.fieldError}>{errors.password}</span>}
          </div>

          <button type="submit" className={styles.submitBtn} disabled={loading}>
            {loading ? "Signing in…" : "Sign in →"}
          </button>

          <Link href="/signup" className={styles.altLink}>
            Create account
          </Link>
        </form>
      </div>
    </main>
  );
}

export default function LoginPage() {
  return (
    <Suspense>
      <LoginForm />
    </Suspense>
  );
}
