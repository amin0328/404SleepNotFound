import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import { getMyProfile, updateMyProfile } from '../controllers/user.controller';

const router = Router();

router.get('/me', requireAuth, getMyProfile);
router.put('/me', requireAuth, updateMyProfile);

export default router;