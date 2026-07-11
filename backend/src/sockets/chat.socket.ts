import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import pool from '../config/db';
import {
  saveMessage,
  isConversationMember,
  isGroupConversationMember,
} from '../services/chat.service';
import { sendChatNotification } from '../services/notification.service';

const JWT_SECRET = process.env.JWT_SECRET as string;

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

const onlineUsers = new Map<string, string>();

export function initChatSocket(httpServer: HttpServer): void {
  const io = new SocketServer(httpServer, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
  });

  io.use((socket: AuthenticatedSocket, next) => {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.split(' ')[1];

    if (!token) return next(new Error('Authentication required.'));

    try {
      const payload = jwt.verify(token, JWT_SECRET) as { id: string };
      socket.userId = payload.id;
      next();
    } catch {
      next(new Error('Invalid or expired token.'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    const userId = socket.userId!;
    onlineUsers.set(userId, socket.id);
    console.log(`[socket] User connected: ${userId}`);

    socket.on('join:direct', (conversationId: string) => {
      isConversationMember(userId, conversationId).then((isMember) => {
        if (!isMember) {
          socket.emit('error', { message: 'You are not a member of this conversation.' });
          return;
        }
        socket.join(`direct:${conversationId}`);
      });
    });

    socket.on('join:group', (groupConversationId: string) => {
      isGroupConversationMember(userId, groupConversationId).then((isMember) => {
        if (!isMember) {
          socket.emit('error', { message: 'You are not a member of this group conversation.' });
          return;
        }
        socket.join(`group:${groupConversationId}`);
      });
    });

    socket.on('message:direct', async (data: { conversation_id: string; body: string }) => {
      const { conversation_id, body } = data;
      if (!body?.trim()) return;

      const isMember = await isConversationMember(userId, conversation_id);
      if (!isMember) {
        socket.emit('error', { message: 'You are not a member of this conversation.' });
        return;
      }

      try {
        const message = await saveMessage(userId, body.trim(), conversation_id, undefined);

        io.to(`direct:${conversation_id}`).emit('message:new', {
          ...message,
          conversation_type: 'direct',
        });

        const convResult = await pool.query(
          'SELECT user_a, user_b FROM conversations WHERE id = $1',
          [conversation_id],
        );

        if (convResult.rows.length > 0) {
          const { user_a, user_b } = convResult.rows[0];
          const recipientId = user_a === userId ? user_b : user_a;
          const isRecipientOnline = onlineUsers.has(recipientId);

          if (!isRecipientOnline) {
            const senderResult = await pool.query(
              'SELECT name FROM users WHERE id = $1',
              [userId],
            );
            const senderName = senderResult.rows[0]?.name ?? 'Someone';
            await sendChatNotification(userId, recipientId, senderName, body.trim(), conversation_id, false);
          }
        }
      } catch (err) {
        console.error('[socket] message:direct error', err);
        socket.emit('error', { message: 'Failed to send message.' });
      }
    });

    socket.on('message:group', async (data: { group_conversation_id: string; body: string }) => {
      const { group_conversation_id, body } = data;
      if (!body?.trim()) return;

      const isMember = await isGroupConversationMember(userId, group_conversation_id);
      if (!isMember) {
        socket.emit('error', { message: 'You are not a member of this group conversation.' });
        return;
      }

      try {
        const message = await saveMessage(userId, body.trim(), undefined, group_conversation_id);

        io.to(`group:${group_conversation_id}`).emit('message:new', {
          ...message,
          conversation_type: 'group',
        });

        const membersResult = await pool.query(
          `SELECT gcm.user_id FROM group_conversation_members gcm
           WHERE gcm.conversation_id = $1 AND gcm.user_id != $2`,
          [group_conversation_id, userId],
        );

        const senderResult = await pool.query(
          'SELECT name FROM users WHERE id = $1',
          [userId],
        );
        const senderName = senderResult.rows[0]?.name ?? 'Someone';

        for (const row of membersResult.rows) {
          const recipientId = row.user_id;
          const isRecipientOnline = onlineUsers.has(recipientId);

          if (!isRecipientOnline) {
            await sendChatNotification(
              userId,
              recipientId,
              senderName,
              body.trim(),
              group_conversation_id,
              true,
            );
          }
        }
      } catch (err) {
        console.error('[socket] message:group error', err);
        socket.emit('error', { message: 'Failed to send message.' });
      }
    });

    socket.on('disconnect', () => {
      onlineUsers.delete(userId);
      console.log(`[socket] User disconnected: ${userId}`);
    });
  });
}