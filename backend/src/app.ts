import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { errorHandler } from './middleware/errorHandler';
import deadlineRoutes from './routes/deadlines.routes';
import listingRoutes from './routes/listings.routes';
import authRoutes from './routes/auth.routes';
import postRoutes from './routes/posts.routes';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/v1/deadlines', deadlineRoutes);

app.use(errorHandler);
export default app;

app.use('/v1/listings', listingRoutes);

app.use('/v1/auth', authRoutes);

app.use('/v1/posts', postRoutes);