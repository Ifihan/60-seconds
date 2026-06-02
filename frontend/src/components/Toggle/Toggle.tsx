import styles from "./Toggle.module.css";

interface ToggleProps {
  options: [string, string];
  value: string;
  onChange: (value: string) => void;
}

export default function Toggle({ options, value, onChange }: ToggleProps) {
  return (
    <div className={styles.toggle} role="group">
      {options.map((opt) => (
        <button
          key={opt}
          className={`${styles.option} ${value === opt ? styles.optionActive : ""}`}
          onClick={() => onChange(opt)}
          aria-pressed={value === opt}
        >
          {opt}
        </button>
      ))}
    </div>
  );
}
