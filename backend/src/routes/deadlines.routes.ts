import { Router } from 'express';
import {
  getDeadlines,
  createDeadline,
  updateDeadline,
  deleteDeadline,
  getNusCalendar,
  importNusDeadline,
} from '../controllers/deadlines.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/',     requireAuth, getDeadlines);
router.post('/',    requireAuth, createDeadline);
router.patch('/:id', requireAuth, updateDeadline);
router.delete('/:id', requireAuth, deleteDeadline);
router.get('/nus-calendar', requireAuth, getNusCalendar);
router.post('/nus-calendar/:id/import', requireAuth, importNusDeadline);

export default router;