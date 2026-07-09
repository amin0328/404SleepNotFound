import http from 'http';
import dotenv from 'dotenv';
import app from './app';
import { startScheduler } from './scraper/scheduler';
import { initChatSocket } from './sockets/chat.socket';

dotenv.config();

const PORT = process.env.PORT || 3000;

const httpServer = http.createServer(app);

initChatSocket(httpServer);

httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);

  if (process.env.NODE_ENV === 'production') {
    startScheduler();
  }
});