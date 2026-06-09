import express from 'express';
import { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { errorHandler } from './middleware/errorHandler';
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/users.routes';
import deadlineRoutes from './routes/deadlines.routes';
import listingRoutes from './routes/listings.routes';
import postRoutes from './routes/posts.routes';
import currencyRoutes from './routes/currency.routes';
import { scrapeSRX } from './scraper/srx.scraper';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

// Temporary scrape test route — remove after testing
app.get('/v1/admin/scrape', async (req: Request, res: Response) => {
  await scrapeSRX();
  res.json({ message: 'Scrape triggered, check logs' });
});

// Routes
app.use('/v1/auth', authRoutes);
app.use('/v1/users', userRoutes);
app.use('/v1/deadlines', deadlineRoutes);
app.use('/v1/listings', listingRoutes);
app.use('/v1/posts', postRoutes);
app.use('/v1/currency', currencyRoutes);

// Error handler must be last
app.use(errorHandler);

export default app;