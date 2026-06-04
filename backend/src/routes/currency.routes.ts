import { Router } from 'express';
import { getRates } from '../controllers/currency.controller';

const router = Router();

// Public — no auth required
router.get('/rates', getRates);

export default router;