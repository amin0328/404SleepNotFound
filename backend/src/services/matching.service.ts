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

  total += 6;
  if (a.sleep    && b.sleep    && a.sleep    === b.sleep)    score += 1;
  if (a.noise    && b.noise    && a.noise    === b.noise)    score += 1;
  if (a.social   && b.social   && a.social   === b.social)   score += 1;
  if (a.diet     && b.diet     && a.diet     === b.diet)     score += 1;
  if (typeof a.cooking === 'boolean' && typeof b.cooking === 'boolean' && a.cooking === b.cooking) score += 1;

  if (a.cleanliness != null && b.cleanliness != null) {
    if (Math.abs(a.cleanliness - b.cleanliness) <= 1) score += 1;
  }

  if (userA.home_country && userB.home_country &&
      userA.home_country === userB.home_country) {
    score += 0.5;
    total += 0.5;
  }

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

export function countSharedInterests(a: string[] = [], b: string[] = []): number {
  const mine = new Set(a.map((tag) => tag.trim().toLowerCase()).filter(Boolean));
  return b.reduce((count, tag) => mine.has(tag.trim().toLowerCase()) ? count + 1 : count, 0);
}

/** A stable 0-100 feed score. The individual parts are returned to keep ranking explainable. */
export function calculateRecommendationScore(input: {
  compatibility: number;
  sharedInterests: number;
  viewedByMe: boolean;
  viewedMe: boolean;
  createdAt: string | Date;
}): { score: number; reasons: string[] } {
  const ageHours = Math.max(0, (Date.now() - new Date(input.createdAt).getTime()) / 3_600_000);
  const interestBoost = Math.min(12, input.sharedInterests * 4);
  const behaviouralBoost = (input.viewedByMe ? 5 : 0) + (input.viewedMe ? 8 : 0);
  const recencyBoost = Math.max(0, 12 * (1 - ageHours / (14 * 24)));
  const reasons: string[] = [];
  if (input.sharedInterests > 0) reasons.push(`${input.sharedInterests} shared interest${input.sharedInterests === 1 ? '' : 's'}`);
  if (input.viewedMe) reasons.push('viewed your post');
  if (input.viewedByMe) reasons.push('you viewed this post');
  if (recencyBoost >= 6) reasons.push('recently posted');
  return { score: Math.round(Math.min(100, input.compatibility * 0.75 + interestBoost + behaviouralBoost + recencyBoost)), reasons };
}
