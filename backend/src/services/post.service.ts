import pool from '../config/db';
import { calculateMatchScore } from './matching.service';


export async function getPosts(category?: string) {
  const result = await pool.query(
    `SELECT p.*, u.name as author_name
     FROM posts p
     JOIN users u ON u.id = p.author_id
     ${category ? 'WHERE p.category = $1' : ''}
     ORDER BY p.created_at DESC`,
    category ? [category] : []
  );
  return result.rows;
}

export async function createPost(authorId: string, data: {
  category: string; title: string; body?: string;
  group_size?: number; tags?: string[]; move_in_date?: string;
}) {
  const result = await pool.query(
    `INSERT INTO posts (author_id, category, title, body, group_size, tags, move_in_date)
     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [authorId, data.category, data.title, data.body,
     data.group_size, data.tags, data.move_in_date]
  );
  return result.rows[0];
}

export async function expressInterest(postId: string, userId: string) {
  // Record interest
  await pool.query(
    `INSERT INTO post_interests (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [postId, userId]
  );

  // Get the interested user's lifestyle
  const userResult = await pool.query(
    'SELECT lifestyle FROM users WHERE id = $1', [userId]
  );
  const userLifestyle = userResult.rows[0]?.lifestyle || {};

  // Get all other interested users and score compatibility
  const othersResult = await pool.query(
    `SELECT u.id, u.name, u.lifestyle, p.id as post_id, p.title
     FROM post_interests pi
     JOIN users u ON u.id = pi.user_id
     JOIN posts p ON p.id = pi.post_id
     WHERE pi.post_id = $1 AND pi.user_id != $2`,
    [postId, userId]
  );

const recommendations = othersResult.rows.map((other: {
  id: string;
  name: string;
  lifestyle: Record<string, unknown>;
  post_id: string;
  title: string;
}) => ({
  post_id: other.post_id,
  user: { id: other.id, name: other.name },
  match_score: calculateMatchScore(
  { lifestyle: userLifestyle },
  { lifestyle: other.lifestyle || {} }
),
})).sort((a: { match_score: number }, b: { match_score: number }) => b.match_score - a.match_score);

  return { post_id: postId, interested: true, recommendations };
}

export async function getPostById(id: string) {
  const result = await pool.query(
    `SELECT p.*, u.name as author_name FROM posts p
     JOIN users u ON u.id = p.author_id WHERE p.id = $1`,
    [id]
  );
  return result.rows[0] || null;
}
