import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import {
  saveMessage,
  isConversationMember,
  isGroupConversationMember,
} from '../services/chat.service';

const JWT_SECRET = process.env.JWT_SECRET as string;

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

export function initChatSocket(httpServer: HttpServer): void {
  const io = new SocketServer(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  io.use((socket: AuthenticatedSocket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];

    if (!token) {
      return next(new Error('Authentication required.'));
    }

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
    console.log(`[socket] User connected: ${userId}`);

    socket.on('join:direct', (conversationId: string) => {
      isConversationMember(userId, conversationId).then((isMember) => {
        if (!isMember) {
          socket.emit('error', { message: 'You are not a member of this conversation.' });
          return;
        }
        socket.join(`direct:${conversationId}`);
        console.log(`[socket] ${userId} joined direct:${conversationId}`);
      });
    });

    socket.on('join:group', (groupConversationId: string) => {
      isGroupConversationMember(userId, groupConversationId).then((isMember) => {
        if (!isMember) {
          socket.emit('error', { message: 'You are not a member of this group conversation.' });
          return;
        }
        socket.join(`group:${groupConversationId}`);
        console.log(`[socket] ${userId} joined group:${groupConversationId}`);
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
      } catch (err) {
        console.error('[socket] message:group error', err);
        socket.emit('error', { message: 'Failed to send message.' });
      }
    });

    socket.on('disconnect', () => {
      console.log(`[socket] User disconnected: ${userId}`);
    });
  });
}