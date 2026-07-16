import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import {
  getMyConversations,
  getConversationById,
  startDirectChat,
  startGroupOrderChat,
  getDirectMessages,
  getGroupOrderMessages,
} from '../controllers/chat.controller';

const router = Router();

router.get('/',                                        requireAuth, getMyConversations);
router.get('/:conversationId',                        requireAuth, getConversationById);
router.post('/direct',                                 requireAuth, startDirectChat);
router.post('/group-order',                            requireAuth, startGroupOrderChat);
router.get('/direct/:conversationId/messages',         requireAuth, getDirectMessages);
router.get('/group/:groupConversationId/messages',     requireAuth, getGroupOrderMessages);

export default router;