import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import * as DeadlineController from '../controllers/deadline.controller';

const router = Router();

router.get('/',      requireAuth, DeadlineController.getDeadlines);
router.post('/',     requireAuth, DeadlineController.createDeadline);
router.patch('/:id', requireAuth, DeadlineController.updateDeadline);
router.delete('/:id',requireAuth, DeadlineController.deleteDeadline);

export default router;