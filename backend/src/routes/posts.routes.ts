import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import * as PostController from '../controllers/post.controller';

const router = Router();

router.get('/',           requireAuth, PostController.getPosts);
router.post('/',          requireAuth, PostController.createPost);
router.get('/:id',        requireAuth, PostController.getPostById);
router.post('/:id/interest', requireAuth, PostController.expressInterest);

export default router;