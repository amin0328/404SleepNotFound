import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';
import { calculateMatchScore, calculateRecommendationScore, countSharedInterests } from '../services/matching.service';
import * as PostService from '../services/post.service';

export async function getPosts(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { category, tags } = req.query;

    const meResult = await pool.query(
      'SELECT id, lifestyle, home_country, major FROM users WHERE id = $1',
      [userId],
    );
    const me = meResult.rows[0];
    const interestTagsResult = await pool.query(
      `SELECT COALESCE(array_agg(DISTINCT tag), ARRAY[]::text[]) AS tags
       FROM (
         SELECT unnest(p.tags) AS tag FROM posts p WHERE p.author_id = $1
         UNION ALL
         SELECT unnest(p.tags) AS tag FROM post_interests pi JOIN posts p ON p.id = pi.post_id WHERE pi.user_id = $1
       ) t`,
      [userId],
    );
    const myInterestTags: string[] = interestTagsResult.rows[0]?.tags ?? [];

    const values: unknown[] = [userId];
    const conditions: string[] = [];   // ← self-exclusion 제거: 본인 글도 포함
    let idx = 2;

    if (category && typeof category === 'string' && category !== 'all') {
      conditions.push(`LOWER(p.category) = $${idx++}`);
      values.push(category.toLowerCase());
    }
    if (tags && typeof tags === 'string') {
      const tagList = tags.split(',').map(t => t.trim()).filter(Boolean);
      if (tagList.length > 0) {
        conditions.push(`p.tags && $${idx++}::text[]`);
        values.push(tagList);
      }
    }

    const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT
         p.id, p.category, p.title, p.body, p.group_size, p.current_size,
         p.tags, p.move_in_date, p.created_at,
         u.id        AS author_id,
         u.name      AS author_name,
         u.major,
         u.home_country,
         u.lifestyle,
         CASE WHEN pf.user_id IS NOT NULL THEN true ELSE false END AS is_favorited,
         CASE WHEN my_view.viewer_id IS NOT NULL THEN true ELSE false END AS viewed_by_me,
         EXISTS (
           SELECT 1 FROM post_views pv
           JOIN posts my_post ON my_post.id = pv.post_id
           WHERE my_post.author_id = $1 AND pv.viewer_id = p.author_id
         ) AS viewed_me,
         (p.author_id = $1) AS is_mine
       FROM posts p
       JOIN users u ON u.id = p.author_id
       LEFT JOIN post_favorites pf ON pf.post_id = p.id AND pf.user_id = $1
       LEFT JOIN post_views my_view ON my_view.post_id = p.id AND my_view.viewer_id = $1
       ${where}
       ORDER BY p.created_at DESC`,
      values,
    );

    // A feed load is an intentional view signal. The unique row preserves its first-view timestamp.
    const visiblePostIds = result.rows.filter((post) => post.author_id !== userId).map((post) => post.id);
    if (visiblePostIds.length) {
      await pool.query(
        'INSERT INTO post_views (post_id, viewer_id) SELECT unnest($1::uuid[]), $2 ON CONFLICT DO NOTHING',
        [visiblePostIds, userId],
      );
    }
    const posts = result.rows.map((post) => {
      const compatibility = calculateMatchScore(me, {
        lifestyle: post.lifestyle,
        home_country: post.home_country,
        major: post.major,
      });
      const recommendation = calculateRecommendationScore({
        compatibility,
        sharedInterests: countSharedInterests(myInterestTags, post.tags ?? []),
        viewedByMe: post.viewed_by_me,
        viewedMe: post.viewed_me,
        createdAt: post.created_at,
      });
      return { ...post, match_percentage: compatibility, recommendation_score: recommendation.score, recommendation_reasons: recommendation.reasons };
    });

    posts.sort((a, b) => b.recommendation_score - a.recommendation_score || b.match_percentage - a.match_percentage);
    res.json({ posts, total: posts.length });
  } catch (err) {
    console.error('[getPosts]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}
export async function deletePost(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const deleted = await PostService.deletePost(req.params.id as string, userId);

    res.json({ message: 'Post deleted.', id: deleted.id });
  } catch (err: any) {
    console.error('[deletePost]', err);
    const status = err.message?.includes('not found') ? 404
      : err.message?.includes('Only the author') ? 403
      : 500;
    res.status(status).json({ error: err.message || 'Internal server error.' });
  }
}
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
      [userId, category.toLowerCase(), title.trim(), body ?? null,
       group_size ?? null, tags ?? [], move_in_date ?? null],
    );

    res.status(201).json({ post: result.rows[0] });
  } catch (err) {
    console.error('[createPost]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

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
      'INSERT INTO post_interests (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [id, userId],
    );

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
