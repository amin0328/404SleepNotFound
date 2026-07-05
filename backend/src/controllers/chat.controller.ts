import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  getOrCreateConversation,
  getOrCreateGroupConversation,
  addGroupConversationMember,
  getMessages,
  getGroupMessages,
  getUserConversations,
  getUserGroupConversations,
  isConversationMember,
  isGroupConversationMember,
} from '../services/chat.service';
import pool from '../config/db';

export async function getMyConversations(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const [direct, group] = await Promise.all([
      getUserConversations(userId),
      getUserGroupConversations(userId),
    ]);

    res.json({ direct, group });
  } catch (err) {
    console.error('[getMyConversations]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function startDirectChat(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { target_user_id } = req.body;

    if (!target_user_id) {
      res.status(400).json({ error: 'target_user_id is required.' });
      return;
    }

    if (target_user_id === userId) {
      res.status(400).json({ error: 'Cannot start a conversation with yourself.' });
      return;
    }

    const targetExists = await pool.query('SELECT id FROM users WHERE id = $1', [target_user_id]);
    if (targetExists.rows.length === 0) {
      res.status(404).json({ error: 'User not found.' });
      return;
    }

    const conversationId = await getOrCreateConversation(userId, target_user_id);
    res.json({ conversation_id: conversationId });
  } catch (err) {
    console.error('[startDirectChat]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function startGroupOrderChat(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { order_id } = req.body;

    if (!order_id) {
      res.status(400).json({ error: 'order_id is required.' });
      return;
    }

    const memberCheck = await pool.query(
      'SELECT user_id FROM order_participants WHERE order_id = $1 AND user_id = $2',
      [order_id, userId],
    );

    const hostCheck = await pool.query(
      'SELECT organiser_id FROM group_orders WHERE id = $1 AND organiser_id = $2',
      [order_id, userId],
    );

    if (memberCheck.rows.length === 0 && hostCheck.rows.length === 0) {
      res.status(403).json({ error: 'You must be a member or host of this order to access its chat.' });
      return;
    }

    const groupConversationId = await getOrCreateGroupConversation(order_id);
    await addGroupConversationMember(groupConversationId, userId);

    res.json({ group_conversation_id: groupConversationId });
  } catch (err) {
    console.error('[startGroupOrderChat]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getDirectMessages(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const conversationId = req.params.conversationId as string;
    const { limit, before } = req.query;

    const isMember = await isConversationMember(userId, conversationId);
    if (!isMember) {
      res.status(403).json({ error: 'You are not a member of this conversation.' });
      return;
    }

    const messages = await getMessages(
      conversationId,
      limit ? parseInt(limit as string) : 50,
      before ? (before as string) : undefined,
    );

    res.json({ messages });
  } catch (err) {
    console.error('[getDirectMessages]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getGroupOrderMessages(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const groupConversationId = req.params.groupConversationId as string;
    const { limit, before } = req.query;

    const isMember = await isGroupConversationMember(userId, groupConversationId);
    if (!isMember) {
      res.status(403).json({ error: 'You are not a member of this group conversation.' });
      return;
    }

    const messages = await getGroupMessages(
      groupConversationId,
      limit ? parseInt(limit as string) : 50,
      before ? (before as string) : undefined,
    );

    res.json({ messages });
  } catch (err) {
    console.error('[getGroupOrderMessages]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}