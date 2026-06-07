import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';

export async function getListings(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { location, type, min_price, max_price } = req.query;

    const conditions: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    if (location && typeof location === 'string') {
      conditions.push(`LOWER(l.location) LIKE $${idx++}`);
      values.push(`%${location.toLowerCase()}%`);
    }
    if (type && typeof type === 'string') {
      conditions.push(`LOWER(l.type) = $${idx++}`);
      values.push(type.toLowerCase());
    }
    if (min_price) {
      conditions.push(`l.price_sgd >= $${idx++}`);
      values.push(Number(min_price));
    }
    if (max_price) {
      conditions.push(`l.price_sgd <= $${idx++}`);
      values.push(Number(max_price));
    }

    const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    values.push(userId);

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END AS is_saved
       FROM listings l
       LEFT JOIN saved_listings sl ON sl.listing_id = l.id AND sl.user_id = $${idx}
       ${where}
       ORDER BY l.available_from ASC NULLS LAST, l.created_at DESC`,
      values,
    );

    res.json({ listings: result.rows, total: result.rowCount });
  } catch (err) {
    console.error('[getListings]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getSavedListings(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              true AS is_saved
       FROM listings l
       INNER JOIN saved_listings sl ON sl.listing_id = l.id
       WHERE sl.user_id = $1
       ORDER BY sl.created_at DESC`,
      [userId],
    );

    res.json({ listings: result.rows, total: result.rowCount });
  } catch (err) {
    console.error('[getSavedListings]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getListingById(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END AS is_saved
       FROM listings l
       LEFT JOIN saved_listings sl ON sl.listing_id = l.id AND sl.user_id = $2
       WHERE l.id = $1`,
      [id, userId],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Listing not found.' });
      return;
    }

    res.json({ listing: result.rows[0] });
  } catch (err) {
    console.error('[getListingById]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function saveListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const listing = await pool.query('SELECT id FROM listings WHERE id = $1', [id]);
    if (listing.rows.length === 0) {
      res.status(404).json({ error: 'Listing not found.' });
      return;
    }

    await pool.query(
      `INSERT INTO saved_listings (user_id, listing_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [userId, id],
    );

    res.status(201).json({ message: 'Listing saved.', listing_id: id });
  } catch (err) {
    console.error('[saveListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function unsaveListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM saved_listings WHERE user_id = $1 AND listing_id = $2 RETURNING listing_id',
      [userId, id],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Saved listing not found.' });
      return;
    }

    res.json({ message: 'Listing unsaved.', listing_id: id });
  } catch (err) {
    console.error('[unsaveListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}