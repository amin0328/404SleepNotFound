import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';

function getUrgency(dueDate: string): { score: number; label: string } {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const due = new Date(dueDate);
  due.setHours(0, 0, 0, 0);
  const daysLeft = Math.ceil((due.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

  if (daysLeft < 0)   return { score: 3, label: 'urgent' };   
  if (daysLeft === 0) return { score: 3, label: 'urgent' };  
  if (daysLeft <= 3)  return { score: 3, label: 'urgent' };  
  if (daysLeft <= 10) return { score: 2, label: 'soon' };     
  return { score: 1, label: 'on_track' };                    
}

export async function getDeadlines(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const result = await pool.query(
      `SELECT id, title, category, due_date, reminder_days,
              notifications_on, notes, created_at
       FROM deadlines
       WHERE user_id = $1
       ORDER BY due_date ASC`,
      [userId],
    );

    const deadlines = result.rows.map((d) => ({
      ...d,
      urgency: getUrgency(d.due_date),
    }));

    res.json({ deadlines });
  } catch (err) {
    console.error('[getDeadlines]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}


export async function createDeadline(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { title, category, due_date, reminder_days, notifications_on, notes } = req.body;

    if (!title || !due_date) {
      res.status(400).json({ error: 'title and due_date are required.' });
      return;
    }

    const result = await pool.query(
      `INSERT INTO deadlines
         (user_id, title, category, due_date, reminder_days, notifications_on, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, title, category, due_date, reminder_days,
                 notifications_on, notes, created_at`,
      [
        userId,
        title.trim(),
        category ?? null,
        due_date,
        reminder_days ?? [],
        notifications_on ?? true,
        notes ?? null,
      ],
    );

    const deadline = {
      ...result.rows[0],
      urgency: getUrgency(result.rows[0].due_date),
    };

    res.status(201).json({ deadline });
  } catch (err) {
    console.error('[createDeadline]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function updateDeadline(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;
    const { title, category, due_date, reminder_days, notifications_on, notes } = req.body;

    const existing = await pool.query(
      'SELECT id FROM deadlines WHERE id = $1 AND user_id = $2',
      [id, userId],
    );
    if (existing.rows.length === 0) {
      res.status(404).json({ error: 'Deadline not found.' });
      return;
    }

    const updates: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    const addField = (col: string, val: unknown) => {
      if (val !== undefined) {
        updates.push(`${col} = $${idx++}`);
        values.push(val);
      }
    };

    addField('title',            title?.trim());
    addField('category',         category);
    addField('due_date',         due_date);
    addField('reminder_days',    reminder_days);
    addField('notifications_on', notifications_on);
    addField('notes',            notes);

    if (updates.length === 0) {
      res.status(400).json({ error: 'No valid fields provided for update.' });
      return;
    }

    values.push(id, userId);

    const result = await pool.query(
      `UPDATE deadlines
       SET ${updates.join(', ')}
       WHERE id = $${idx} AND user_id = $${idx + 1}
       RETURNING id, title, category, due_date, reminder_days,
                 notifications_on, notes, created_at`,
      values,
    );

    const deadline = {
      ...result.rows[0],
      urgency: getUrgency(result.rows[0].due_date),
    };

    res.json({ deadline });
  } catch (err) {
    console.error('[updateDeadline]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function deleteDeadline(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM deadlines WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Deadline not found.' });
      return;
    }

    res.json({ message: 'Deadline deleted.', id });
  } catch (err) {
    console.error('[deleteDeadline]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}