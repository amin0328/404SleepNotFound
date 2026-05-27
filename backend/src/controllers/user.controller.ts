import { Request, Response } from 'express';
import * as UserService from '../services/user.service';

export async function getMyProfile(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const profile = await UserService.getProfile(userId);
    if (!profile) return res.status(404).json({ error: 'User not found' });
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
}

export async function updateMyProfile(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const updated = await UserService.updateProfile(userId, req.body);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
}