import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';

export async function registerFcmToken(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { token } = req.body;

    if (!token) {
      res.status(400).json({ error: 'token is required.' });
      return;
    }

    await pool.query(
      'UPDATE users SET fcm_token = $1 WHERE id = $2',
      [token, userId],
    );

    res.json({ message: 'FCM token registered.' });
  } catch (err) {
    console.error('[registerFcmToken]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}