import { Request, Response } from 'express';
import * as DeadlineService from '../services/deadline.service';

export async function getDeadlines(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const deadlines = await DeadlineService.getDeadlinesByUser(userId);
    res.json({ data: deadlines, total: deadlines.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch deadlines' });
  }
}

export async function createDeadline(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const deadline = await DeadlineService.createDeadline(userId, req.body);
    res.status(201).json(deadline);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create deadline' });
  }
}

export async function updateDeadline(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const deadline = await DeadlineService.updateDeadline(
      req.params.id, userId, req.body
    );
    if (!deadline) return res.status(404).json({ error: 'Deadline not found' });
    res.json(deadline);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update deadline' });
  }
}

export async function deleteDeadline(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    await DeadlineService.deleteDeadline(req.params.id, userId);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete deadline' });
  }
}