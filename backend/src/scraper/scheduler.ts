import cron from 'node-cron';
import { scrapeSRX } from './srx.scraper';

// Runs every day at 3am Singapore time (UTC+8 = 19:00 UTC)
export function startScheduler(): void {
  console.log('[scheduler] Starting scraper scheduler...');

  cron.schedule('0 19 * * *', async () => {
    console.log('[scheduler] Running daily SRX scrape...');
    await scrapeSRX();
  });
}
