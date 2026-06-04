import { Router } from 'express';
import {
  getDeadlines,
  createDeadline,
  updateDeadline,
  deleteDeadline,
} from '../controllers/deadline.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/',     requireAuth, getDeadlines);
router.post('/',    requireAuth, createDeadline);
router.patch('/:id', requireAuth, updateDeadline);
router.delete('/:id', requireAuth, deleteDeadline);

export default router;