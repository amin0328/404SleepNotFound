import { Router } from 'express';
import { getPosts, createPost, expressInterest, toggleFavorite } from '../controllers/post.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/',                requireAuth, getPosts);
router.post('/',               requireAuth, createPost);
router.post('/:id/interest',   requireAuth, expressInterest);
router.post('/:id/favorite',   requireAuth, toggleFavorite);

export default router;