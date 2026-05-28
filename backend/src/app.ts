import express from 'express';
import { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { errorHandler } from './middleware/errorHandler';
import deadlineRoutes from './routes/deadlines.routes';
import listingRoutes from './routes/listings.routes';
import authRoutes from './routes/auth.routes';
import postRoutes from './routes/posts.routes';
import userRoutes from './routes/users.routes';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

app.use('/v1/deadlines', deadlineRoutes);
app.use('/v1/listings', listingRoutes);
app.use('/v1/auth', authRoutes);
app.use('/v1/posts', postRoutes);
app.use('/v1/users', userRoutes);

app.use(errorHandler);

export default app;
