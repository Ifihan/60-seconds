import Link from "next/link";
import type { Area } from "@/store";
import styles from "./AreaRow.module.css";

interface AreaRowProps {
  area: Area;
  href: string;
  onClick?: () => void;
}

export default function AreaRow({ area, href, onClick }: AreaRowProps) {
  return (
    <Link href={href} className={styles.row} onClick={onClick}>
      <span className={styles.name}>{area.name}</span>
      {area.is_own && <span className={styles.badge}>Mine</span>}
      <span className={styles.chevron}>↺ Spin</span>
    </Link>
  );
}
