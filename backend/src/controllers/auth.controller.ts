import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db';

const JWT_SECRET = process.env.JWT_SECRET as string;

function generateToken(userId: string): string {
  return jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '7d' });
}

export async function register(req: Request, res: Response): Promise<void> {
  try {
    const {
      nusnet_id,
      name,
      email,
      password,
      home_country,
      major,
      home_currency,
      dorm,
      arrival_date,
      grad_year,
      lifestyle,
    } = req.body;

    if (!nusnet_id || !name || !email || !password) {
      res.status(400).json({
        error: 'nusnet_id, name, email, and password are required.',
      });
      return;
    }

    const nusnetRegex = /^e\d{7}$/i;
    if (!nusnetRegex.test(nusnet_id)) {
      res.status(400).json({ error: 'nusnet_id must be in the format e0123456.' });
      return;
    }

    if (!email.endsWith('@u.nus.edu') && !email.endsWith('@nus.edu.sg')) {
      res.status(400).json({ error: 'Please use your NUS email address.' });
      return;
    }

    if (password.length < 8) {
      res.status(400).json({ error: 'Password must be at least 8 characters.' });
      return;
    }

    const existing = await pool.query(
      'SELECT id FROM users WHERE email = $1 OR nusnet_id = $2',
      [email.toLowerCase(), nusnet_id.toLowerCase()],
    );
    if (existing.rows.length > 0) {
      res.status(409).json({ error: 'An account with that email or NUSNET ID already exists.' });
      return;
    }

    if (lifestyle !== undefined) {
      const validationError = validateLifestyle(lifestyle);
      if (validationError) {
        res.status(400).json({ error: validationError });
        return;
      }
    }

    const password_hash = await bcrypt.hash(password, 12);

    const result = await pool.query(
      `INSERT INTO users
         (nusnet_id, name, email, password_hash,
          home_country, major, home_currency, dorm,
          arrival_date, grad_year, lifestyle)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING id, nusnet_id, name, email,
                 home_country, major, home_currency, dorm,
                 arrival_date, grad_year, lifestyle, created_at`,
      [
        nusnet_id.toLowerCase(),
        name.trim(),
        email.toLowerCase(),
        password_hash,
        home_country?.toUpperCase() ?? null,
        major ?? null,
        home_currency?.toUpperCase() ?? null,
        dorm ?? null,
        arrival_date ?? null,
        grad_year ?? null,
        lifestyle ? JSON.stringify(lifestyle) : null,
      ],
    );

    const user = result.rows[0];
    const token = generateToken(user.id);

    const onboardingComplete = !!(
      user.home_country &&
      user.major &&
      user.home_currency &&
      user.dorm &&
      user.arrival_date &&
      user.grad_year &&
      user.lifestyle
    );

    res.status(201).json({
      token,
      onboarding_complete: onboardingComplete,
      user,
    });
  } catch (err) {
    console.error('[register]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function login(req: Request, res: Response): Promise<void> {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ error: 'Email and password are required.' });
      return;
    }

    const result = await pool.query(
      `SELECT id, nusnet_id, name, email, password_hash,
              home_country, major, home_currency, dorm,
              arrival_date, grad_year, lifestyle, created_at
       FROM users
       WHERE email = $1`,
      [email.toLowerCase()],
    );

    if (result.rows.length === 0) {
      res.status(401).json({ error: 'Invalid email or password.' });
      return;
    }

    const user = result.rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      res.status(401).json({ error: 'Invalid email or password.' });
      return;
    }

    const token = generateToken(user.id);

    const { password_hash, ...safeUser } = user;

    const onboardingComplete = !!(
      safeUser.home_country &&
      safeUser.major &&
      safeUser.home_currency &&
      safeUser.dorm &&
      safeUser.arrival_date &&
      safeUser.grad_year &&
      safeUser.lifestyle
    );

    res.status(200).json({
      token,
      onboarding_complete: onboardingComplete,
      user: safeUser,
    });
  } catch (err) {
    console.error('[login]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

function validateLifestyle(l: Record<string, unknown>): string | null {
  if (!['early', 'late'].includes(l.sleep as string)) {
    return 'lifestyle.sleep must be "early" or "late".';
  }
  const cleanliness = Number(l.cleanliness);
  if (!Number.isInteger(cleanliness) || cleanliness < 1 || cleanliness > 5) {
    return 'lifestyle.cleanliness must be an integer between 1 and 5.';
  }
  if (typeof l.cooking !== 'boolean') {
    return 'lifestyle.cooking must be true or false.';
  }
  if (!['quiet', 'loud'].includes(l.noise as string)) {
    return 'lifestyle.noise must be "quiet" or "loud".';
  }
  if (typeof l.diet !== 'string' || (l.diet as string).trim() === '') {
    return 'lifestyle.diet is required (e.g. "halal", "vegetarian", "none").';
  }
  if (!['introvert', 'extrovert'].includes(l.social as string)) {
    return 'lifestyle.social must be "introvert" or "extrovert".';
  }
  return null;
}
