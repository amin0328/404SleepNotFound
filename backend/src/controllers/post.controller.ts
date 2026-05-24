import { Request, Response } from 'express';
import * as PostService from '../services/post.service';

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
    const post = await PostService.getPostById(req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    res.json(post);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch post' });
  }
}

export async function expressInterest(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const result = await PostService.expressInterest(req.params.id, userId);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Failed to express interest' });
  }
}