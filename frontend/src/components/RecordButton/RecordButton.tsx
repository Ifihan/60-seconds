import styles from "./RecordButton.module.css";

interface RecordButtonProps {
  recording: boolean;
  disabled?: boolean;
  onClick: () => void;
}

export default function RecordButton({
  recording,
  disabled,
  onClick,
}: RecordButtonProps) {
  return (
    <div className={styles.wrap}>
      <button
        className={`${styles.ring} ${recording ? styles.ringRecording : ""}`}
        onClick={onClick}
        disabled={disabled}
        aria-label={recording ? "Stop recording" : "Start recording"}
        aria-pressed={recording}
      >
        <span
          className={`${styles.inner} ${recording ? styles.innerRecording : ""}`}
        />
      </button>
      <span className={styles.hint}>
        {recording ? "Tap to stop" : "Tap to record · saves to your device"}
      </span>
    </div>
  );
}
