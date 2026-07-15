import { Router } from 'express';
import { getPosts, createPost, expressInterest, toggleFavorite, deletePost } from '../controllers/post.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/',                requireAuth, getPosts);
router.post('/',               requireAuth, createPost);
router.delete('/:id',          requireAuth, deletePost);
router.post('/:id/interest',   requireAuth, expressInterest);
router.post('/:id/favorite',   requireAuth, toggleFavorite);

export default router;