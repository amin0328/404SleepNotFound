import cron from 'node-cron';
import { scrapeSRX } from './srx.scraper';
import { sendDeadlineReminders } from '../services/notification.service';

export function startScheduler(): void {
  console.log('[scheduler] Starting scheduler...');

  cron.schedule('0 19 * * *', async () => {
    console.log('[scheduler] Running daily SRX scrape...');
    await scrapeSRX();
  });

  cron.schedule('0 1 * * *', async () => {
    console.log('[scheduler] Sending deadline reminders...');
    await sendDeadlineReminders();
  });
}
