interface Lifestyle {
  sleep?: string;
  cleanliness?: number;
  cooking?: boolean;
  noise?: string;
  diet?: string;
  social?: string;
}

export function compatibilityScore(a: Lifestyle, b: Lifestyle): number {
  let score = 0;

  if (a.sleep && b.sleep && a.sleep === b.sleep)   score += 25;
  if (a.noise && b.noise && a.noise === b.noise)   score += 20;
  if (a.diet  && b.diet  && a.diet  === b.diet)    score += 20;
  if (a.social && b.social && a.social === b.social) score += 15;

  if (a.cleanliness !== undefined && b.cleanliness !== undefined) {
    const diff = Math.abs(a.cleanliness - b.cleanliness);
    score += Math.max(0, 15 - diff * 5);
  }

  if (a.cooking !== undefined && b.cooking !== undefined && a.cooking === b.cooking) score += 5;

  return Math.min(100, score);
}