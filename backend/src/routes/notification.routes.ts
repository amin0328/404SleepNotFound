import { Router } from 'express';
import { registerFcmToken } from '../controllers/notification.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.post('/fcm-token', requireAuth, registerFcmToken);

export default router;