import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';
import { calculateMatchScore } from '../services/matching.service';

// ─── GET /v1/posts ───────────────────────────────────────────────────────────
// Supports ?category=roommate|hobby_mate|study_mate
// Returns match_percentage and is_favorited on each post

export async function getPosts(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { category } = req.query;

    // Get the requesting user's profile for match calculation
    const meResult = await pool.query(
      'SELECT id, lifestyle, home_country, major FROM users WHERE id = $1',
      [userId],
    );
    const me = meResult.rows[0];

    const values: unknown[] = [userId];
    let categoryClause = '';

    if (category && typeof category === 'string' && category !== 'all') {
      categoryClause = 'AND LOWER(p.category) = $2';
      values.push(category.toLowerCase());
    }

    const result = await pool.query(
      `SELECT
         p.id, p.category, p.title, p.body, p.group_size, p.current_size,
         p.tags, p.move_in_date, p.created_at,
         u.id        AS author_id,
         u.name      AS author_name,
         u.avatar_url,
         u.major,
         u.home_country,
         u.nationality,
         u.academic_year,
         u.bio,
         u.lifestyle,
         u.course_codes,
         u.study_locations,
         CASE WHEN pf.user_id IS NOT NULL THEN true ELSE false END AS is_favorited
       FROM posts p
       JOIN users u ON u.id = p.author_id
       LEFT JOIN post_favorites pf ON pf.post_id = p.id AND pf.user_id = $1
       WHERE p.author_id != $1
       ${categoryClause}
       ORDER BY p.created_at DESC`,
      values,
    );

    // Attach match percentage to each post
    const posts = result.rows.map((post) => ({
      ...post,
      match_percentage: calculateMatchScore(me, {
        lifestyle: post.lifestyle,
        home_country: post.home_country,
        major: post.major,
      }),
    }));

    // Sort by match percentage descending
    posts.sort((a, b) => b.match_percentage - a.match_percentage);

    res.json({ posts, total: posts.length });
  } catch (err) {
    console.error('[getPosts]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

// ─── POST /v1/posts ──────────────────────────────────────────────────────────

export async function createPost(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { category, title, body, group_size, tags, move_in_date } = req.body;

    if (!category || !title) {
      res.status(400).json({ error: 'category and title are required.' });
      return;
    }

    const validCategories = ['roommate', 'hobby_mate', 'study_mate'];
    if (!validCategories.includes(category.toLowerCase())) {
      res.status(400).json({ error: `category must be one of: ${validCategories.join(', ')}.` });
      return;
    }

    const result = await pool.query(
      `INSERT INTO posts (author_id, category, title, body, group_size, tags, move_in_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, category, title, body, group_size, current_size, tags, move_in_date, created_at`,
      [
        userId,
        category.toLowerCase(),
        title.trim(),
        body ?? null,
        group_size ?? null,
        tags ?? [],
        move_in_date ?? null,
      ],
    );

    res.status(201).json({ post: result.rows[0] });
  } catch (err) {
    console.error('[createPost]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

// ─── POST /v1/posts/:id/interest ─────────────────────────────────────────────

export async function expressInterest(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const post = await pool.query('SELECT * FROM posts WHERE id = $1', [id]);
    if (post.rows.length === 0) {
      res.status(404).json({ error: 'Post not found.' });
      return;
    }

    await pool.query(
      `INSERT INTO post_interests (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
      [id, userId],
    );

    // Get matched users (everyone interested in this post)
    const matches = await pool.query(
      `SELECT u.id, u.name, u.avatar_url, u.major, u.home_country
       FROM post_interests pi
       JOIN users u ON u.id = pi.user_id
       WHERE pi.post_id = $1 AND pi.user_id != $2`,
      [id, userId],
    );

    res.json({ interested: true, matches: matches.rows });
  } catch (err) {
    console.error('[expressInterest]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

// ─── POST /v1/posts/:id/favorite ─────────────────────────────────────────────

export async function toggleFavorite(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const existing = await pool.query(
      'SELECT * FROM post_favorites WHERE post_id = $1 AND user_id = $2',
      [id, userId],
    );

    if (existing.rows.length > 0) {
      await pool.query(
        'DELETE FROM post_favorites WHERE post_id = $1 AND user_id = $2',
        [id, userId],
      );
      res.json({ favorited: false });
    } else {
      await pool.query(
        'INSERT INTO post_favorites (post_id, user_id) VALUES ($1, $2)',
        [id, userId],
      );
      res.json({ favorited: true });
    }
  } catch (err) {
    console.error('[toggleFavorite]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}