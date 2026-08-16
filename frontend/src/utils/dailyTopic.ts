export function todayUTC(): string {
  return new Date().toISOString().slice(0, 10);
}

// djb2 string hash — deterministic across runs/browsers.
function hash(input: string): number {
  let h = 5381;
  for (let i = 0; i < input.length; i++) {
    h = (h * 33) ^ input.charCodeAt(i);
  }
  return h >>> 0;
}

export function pickDailyTopic(
  dateStr: string,
  areaId: string,
  topics: { id: string; name: string }[]
): string | null {
  if (topics.length === 0) return null;
  const sorted = [...topics].sort((a, b) => a.id.localeCompare(b.id));
  const index = hash(`${dateStr}:${areaId}`) % sorted.length;
  return sorted[index].name;
}
