import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import * as OrderController from '../controllers/order.controller';

const router = Router();

router.get('/',              requireAuth, OrderController.getOrders);
router.post('/',             requireAuth, OrderController.createOrder);
router.post('/:id/join',     requireAuth, OrderController.joinOrder);
router.post('/:id/leave',    requireAuth, OrderController.leaveOrder);
router.patch('/:id/status',  requireAuth, OrderController.updateStatus);
router.get('/:id/split',     requireAuth, OrderController.getCostSplit);

export default router;