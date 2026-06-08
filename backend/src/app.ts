import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { errorHandler } from './middleware/errorHandler';
import deadlineRoutes from './routes/deadlines.routes';

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

import { scrapeSRX } from './scraper/srx.scraper';

// Temporary test route — remove after testing
app.get('/v1/admin/scrape', async (req, res) => {
  await scrapeSRX();
  res.json({ message: 'Scrape triggered, check logs' });
});