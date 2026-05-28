import { pool } from '../config/db';

export function getUrgency(dueDate: string): 'green' | 'amber' | 'red' {
  const days = Math.ceil(
    (new Date(dueDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)
  );
  if (days > 30) return 'green';
  if (days > 7)  return 'amber';
  return 'red';
}

export async function getDeadlinesByUser(userId: string) {
  const result = await pool.query(
    'SELECT * FROM deadlines WHERE user_id = $1 ORDER BY due_date ASC',
    [userId]
  );
  return result.rows.map(d:any => ({ ...d, urgency: getUrgency(d.due_date) }));
}

export async function createDeadline(userId: string, data: {
  title: string; category: string; due_date: string;
  reminder_days: number[]; notifications_on: boolean; notes?: string;
}) {
  const result = await pool.query(
    `INSERT INTO deadlines (user_id, title, category, due_date, reminder_days, notifications_on, notes)
     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [userId, data.title, data.category, data.due_date,
     data.reminder_days, data.notifications_on, data.notes]
  );
  return { ...result.rows[0], urgency: getUrgency(data.due_date) };
}

export async function updateDeadline(id: string, userId: string, data: Partial<{
  title: string; category: string; due_date: string;
  reminder_days: number[]; notifications_on: boolean; notes: string;
}>) {
  const fields = Object.keys(data).map((k, i) => `${k} = $${i + 3}`).join(', ');
  const values = Object.values(data);
  const result = await pool.query(
    `UPDATE deadlines SET ${fields} WHERE id = $1 AND user_id = $2 RETURNING *`,
    [id, userId, ...values]
  );
  return result.rows[0];
}

export async function deleteDeadline(id: string, userId: string) {
  await pool.query(
    'DELETE FROM deadlines WHERE id = $1 AND user_id = $2',
    [id, userId]
  );
}
