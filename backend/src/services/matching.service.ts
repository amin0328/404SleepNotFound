// ─── Match Score Service ─────────────────────────────────────────────────────
// Compares two users' lifestyle JSONB fields and returns a 0-100 score.
// Each criterion is worth equal weight (1/6 of total).

interface Lifestyle {
  sleep?: 'early' | 'late';
  noise?: 'quiet' | 'loud';
  social?: 'introvert' | 'extrovert';
  diet?: string;
  cleanliness?: number;
  cooking?: boolean;
}

export function calculateMatchScore(
  userA: { lifestyle?: Lifestyle; home_country?: string; major?: string },
  userB: { lifestyle?: Lifestyle; home_country?: string; major?: string },
): number {
  const a: Lifestyle = userA.lifestyle || {};
  const b: Lifestyle = userB.lifestyle || {};

  let score = 0;
  let total = 0;

  // ── Core lifestyle (each worth 1 point) ──────────────────────────────────
  total += 6;
  if (a.sleep    && b.sleep    && a.sleep    === b.sleep)    score += 1;
  if (a.noise    && b.noise    && a.noise    === b.noise)    score += 1;
  if (a.social   && b.social   && a.social   === b.social)   score += 1;
  if (a.diet     && b.diet     && a.diet     === b.diet)     score += 1;
  if (typeof a.cooking === 'boolean' && typeof b.cooking === 'boolean' && a.cooking === b.cooking) score += 1;

  // Cleanliness — within 1 level counts as compatible
  if (a.cleanliness != null && b.cleanliness != null) {
    if (Math.abs(a.cleanliness - b.cleanliness) <= 1) score += 1;
  }

  // ── Bonus: same nationality (worth 0.5 extra) ────────────────────────────
  if (userA.home_country && userB.home_country &&
      userA.home_country === userB.home_country) {
    score += 0.5;
    total += 0.5;
  }

  // ── Bonus: same faculty/major (worth 0.5 extra) ──────────────────────────
  if (userA.major && userB.major) {
    const facultyA = userA.major.split(' ')[0];
    const facultyB = userB.major.split(' ')[0];
    if (facultyA === facultyB) {
      score += 0.5;
      total += 0.5;
    }
  }

  if (total === 0) return 0;
  return Math.min(100, Math.round((score / total) * 100));
}