import admin from 'firebase-admin';
import pool from '../config/db';

let initialized = false;

function initFirebase(): void {
  if (initialized) return;
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT as string);
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  initialized = true;
}

export async function sendPushNotification(
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<void> {
  initFirebase();
  try {
    await admin.messaging().send({ token, notification: { title, body }, data });
  } catch (err) {
    console.error('[notification] Failed to send:', err);
  }
}

export async function sendToMultipleTokens(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<void> {
  initFirebase();
  if (tokens.length === 0) return;
  try {
    await admin.messaging().sendEachForMulticast({ tokens, notification: { title, body }, data });
  } catch (err) {
    console.error('[notification] Failed to send multicast:', err);
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
        { type: 'deadline', deadline_id: row.id },
      );
      sent++;
    }
  }

  console.log(`[notification] Sent ${sent} deadline reminders`);
}

export async function sendChatNotification(
  senderId: string,
  recipientId: string,
  senderName: string,
  messageBody: string,
  conversationId: string,
  isGroup: boolean,
): Promise<void> {
  initFirebase();

  const result = await pool.query(
    'SELECT fcm_token FROM users WHERE id = $1 AND fcm_token IS NOT NULL',
    [recipientId],
  );

  if (result.rows.length === 0) return;

  const token = result.rows[0].fcm_token;
  const title = isGroup ? `${senderName} (Group)` : senderName;
  const preview = messageBody.length > 60 ? messageBody.substring(0, 60) + '...' : messageBody;

  await sendPushNotification(token, title, preview, {
    type: 'chat',
    conversation_id: conversationId,
    is_group: String(isGroup),
    sender_id: senderId,
  });
}

export async function sendGroupOrderStatusNotification(
  orderId: string,
  orderName: string,
  newStatus: string,
): Promise<void> {
  initFirebase();

  const statusMessages: Record<string, string> = {
    confirmed: `Your group order "${orderName}" has been confirmed! The host is ready to proceed.`,
    shipped:   `Your group order "${orderName}" has been shipped! Track your delivery.`,
    arrived:   `Your group order "${orderName}" has arrived! Head to the collection point to pick up your items.`,
  };

  const message = statusMessages[newStatus];
  if (!message) return;

  const participants = await pool.query(
    `SELECT u.fcm_token FROM order_participants op
     JOIN users u ON u.id = op.user_id
     WHERE op.order_id = $1 AND u.fcm_token IS NOT NULL`,
    [orderId],
  );

  const hostResult = await pool.query(
    `SELECT u.fcm_token FROM group_orders go
     JOIN users u ON u.id = go.organiser_id
     WHERE go.id = $1 AND u.fcm_token IS NOT NULL`,
    [orderId],
  );

  const allTokens = [
    ...participants.rows.map((r: { fcm_token: string }) => r.fcm_token),
    ...hostResult.rows.map((r: { fcm_token: string }) => r.fcm_token),
  ].filter(Boolean);

  const uniqueTokens = [...new Set(allTokens)];

  await sendToMultipleTokens(
    uniqueTokens,
    'Group Order Update',
    message,
    { type: 'group_order', order_id: orderId, status: newStatus },
  );

  console.log(`[notification] Sent group order status update to ${uniqueTokens.length} users`);
}