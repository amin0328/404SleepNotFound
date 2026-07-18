import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import multer from 'multer';
import { uploadChatImage } from '../controllers/upload.controller';
import {
  getMyConversations,
  getConversationById,
  startDirectChat,
  startGroupOrderChat,
  getDirectMessages,
  getGroupOrderMessages,
} from '../controllers/chat.controller';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.get('/',                                        requireAuth, getMyConversations);
router.get('/:conversationId',                        requireAuth, getConversationById);
router.post('/direct',                                 requireAuth, startDirectChat);
router.post('/group-order',                            requireAuth, startGroupOrderChat);
router.post('/upload-image',                           requireAuth, upload.single('image'), uploadChatImage);
router.get('/direct/:conversationId/messages',         requireAuth, getDirectMessages);
router.get('/group/:groupConversationId/messages',     requireAuth, getGroupOrderMessages);

export default router;
