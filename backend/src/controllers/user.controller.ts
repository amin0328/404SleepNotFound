import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';

export async function getMe(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const result = await pool.query(
      `SELECT id, nusnet_id, name, email,
              home_country, major, home_currency, dorm,
              arrival_date, grad_year, lifestyle, created_at
       FROM users
       WHERE id = $1`,
      [userId],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'User not found.' });
      return;
    }

    const user = result.rows[0];
    res.json({ user, onboarding_complete: isOnboardingComplete(user) });
  } catch (err) {
    console.error('[getMe]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function updateMe(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const {
      name,
      home_country,
      major,
      home_currency,
      dorm,
      arrival_date,
      grad_year,
      lifestyle,
    } = req.body;

    if (lifestyle !== undefined) {
      const err = validateLifestyle(lifestyle);
      if (err) {
        res.status(400).json({ error: err });
        return;
      }
    }

    if (grad_year !== undefined) {
      const year = Number(grad_year);
      if (!Number.isInteger(year) || year < 2020 || year > 2040) {
        res.status(400).json({ error: 'grad_year must be a valid year (e.g. 2027).' });
        return;
      }
    }

    if (home_country !== undefined && !/^[A-Za-z]{2}$/.test(home_country)) {
      res.status(400).json({ error: 'home_country must be a 2-letter code (e.g. "MY", "KR").' });
      return;
    }

    if (home_currency !== undefined && !/^[A-Za-z]{3}$/.test(home_currency)) {
      res.status(400).json({ error: 'home_currency must be a 3-letter code (e.g. "MYR", "KRW").' });
      return;
    }

    const updates: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    const addField = (col: string, val: unknown, transform?: (v: unknown) => unknown) => {
      if (val !== undefined) {
        updates.push(`${col} = $${idx++}`);
        values.push(transform ? transform(val) : val);
      }
    };

    addField('name',          name,          (v) => (v as string).trim());
    addField('home_country',  home_country,  (v) => (v as string).toUpperCase());
    addField('major',         major);
    addField('home_currency', home_currency, (v) => (v as string).toUpperCase());
    addField('dorm',          dorm);
    addField('arrival_date',  arrival_date);
    addField('grad_year',     grad_year,     Number);
    addField('lifestyle',     lifestyle,     JSON.stringify);

    if (updates.length === 0) {
      res.status(400).json({ error: 'No valid fields provided for update.' });
      return;
    }

    values.push(userId); 

    const result = await pool.query(
      `UPDATE users
       SET ${updates.join(', ')}
       WHERE id = $${idx}
       RETURNING id, nusnet_id, name, email,
                 home_country, major, home_currency, dorm,
                 arrival_date, grad_year, lifestyle, created_at`,
      values,
    );

    const user = result.rows[0];
    res.json({ user, onboarding_complete: isOnboardingComplete(user) });
  } catch (err) {
    console.error('[updateMe]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

function isOnboardingComplete(user: Record<string, unknown>): boolean {
  return !!(
    user.home_country &&
    user.major &&
    user.home_currency &&
    user.dorm &&
    user.arrival_date &&
    user.grad_year &&
    user.lifestyle
  );
}

function validateLifestyle(l: Record<string, unknown>): string | null {
  if (!['early', 'late'].includes(l.sleep as string))
    return 'lifestyle.sleep must be "early" or "late".';

  const cleanliness = Number(l.cleanliness);
  if (!Number.isInteger(cleanliness) || cleanliness < 1 || cleanliness > 5)
    return 'lifestyle.cleanliness must be an integer 1–5.';

  if (typeof l.cooking !== 'boolean')
    return 'lifestyle.cooking must be true or false.';

  if (!['quiet', 'loud'].includes(l.noise as string))
    return 'lifestyle.noise must be "quiet" or "loud".';

  if (typeof l.diet !== 'string' || (l.diet as string).trim() === '')
    return 'lifestyle.diet is required (e.g. "halal", "vegetarian", "none").';

  if (!['introvert', 'extrovert'].includes(l.social as string))
    return 'lifestyle.social must be "introvert" or "extrovert".';

  return null;

}