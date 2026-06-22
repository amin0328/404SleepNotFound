import admin from 'firebase-admin';
import pool from '../config/db';

let initialized = false;

function initFirebase(): void {
  if (initialized) return;

  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT as string);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
}

export async function sendPushNotification(token: string, title: string, body: string): Promise<void> {
  initFirebase();

  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
    });
  } catch (err) {
    console.error('[notification] Failed to send:', err);
  }
}

export async function sendDeadlineReminders(): Promise<void> {
  initFirebase();

  const result = await pool.query(`
    SELECT d.id, d.title, d.due_date, d.reminder_days, u.fcm_token
    FROM deadlines d
    JOIN users u ON u.id = d.user_id
    WHERE d.notifications_on = true AND u.fcm_token IS NOT NULL
  `);

  let sent = 0;

  for (const row of result.rows) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const due = new Date(row.due_date);
    due.setHours(0, 0, 0, 0);
    const daysLeft = Math.ceil((due.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

    if (row.reminder_days.includes(daysLeft)) {
      await sendPushNotification(
        row.fcm_token,
        'Deadline Reminder',
        `${row.title} is due in ${daysLeft} day(s).`,
      );
      sent++;
    }
  }

  console.log(`[notification] Sent ${sent} deadline reminders`);
}