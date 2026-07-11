import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import {
  getOrders,
  createOrder,
  deleteOrder,
  joinOrder,
  leaveOrder,
  updateStatus,
  getCostSplit,
  getOrderItems,
  updateOrderItems,
} from '../controllers/order.controller';

const router = Router();

router.get('/',                requireAuth, getOrders);
router.post('/',               requireAuth, createOrder);
router.delete('/:id',          requireAuth, deleteOrder);
router.post('/:id/join',       requireAuth, joinOrder);
router.post('/:id/leave',      requireAuth, leaveOrder);
router.patch('/:id/status',    requireAuth, updateStatus);
router.get('/:id/split',       requireAuth, getCostSplit);
router.get('/:id/items',       requireAuth, getOrderItems);
router.put('/:id/items',       requireAuth, updateOrderItems);

export default router;