import { Request, Response } from 'express';
import * as PostService from '../services/post.service';
import pool from '../config/db';

export async function getPosts(req: Request, res: Response) {
  try {
    const { category } = req.query;
    const posts = await PostService.getPosts(category as string);
    res.json({ data: posts, total: posts.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
}

export async function createPost(req: Request, res: Response) {
  try {
    const authorId = (req as any).user.id;
    const post = await PostService.createPost(authorId, req.body);
    res.status(201).json(post);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create post' });
  }
}

export async function getPostById(req: Request, res: Response) {
  try {
    const post = await PostService.getPostById(req.params.id as string);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    res.json(post);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch post' });
  }
}

export async function expressInterest(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const result = await PostService.expressInterest(req.params.id as string, userId);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Failed to express interest' });
  }
}

export async function toggleFavorite(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const postId = req.params.id as string;
    const existing = await pool.query(
      'SELECT * FROM post_favorites WHERE post_id = $1 AND user_id = $2',
      [postId, userId]
    );
    if (existing.rows.length > 0) {
      await pool.query('DELETE FROM post_favorites WHERE post_id = $1 AND user_id = $2', [postId, userId]);
      res.json({ favorited: false });
    } else {
      await pool.query('INSERT INTO post_favorites (post_id, user_id) VALUES ($1, $2)', [postId, userId]);
      res.json({ favorited: true });
    }
  } catch (err) {
    res.status(500).json({ error: 'Failed to toggle favorite' });
  }
}