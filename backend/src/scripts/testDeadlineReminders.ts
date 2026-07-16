
import { sendDeadlineReminders } from '../services/notification.service';

sendDeadlineReminders()
  .then(() => {
    console.log('Done');
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
