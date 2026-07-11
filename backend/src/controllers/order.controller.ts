import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import * as OrderService from '../services/order.service';
import pool from '../config/db';

export async function getOrders(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { status, search } = req.query;
    const orders = await OrderService.getOrders(userId, status as string, search as string);
    res.json({ data: orders, total: orders.length });
  } catch (err) {
    console.error('[getOrders]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function createOrder(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { store, order_name, deadline, pickup_spot } = req.body;

    if (!store || !order_name || !deadline || !pickup_spot) {
      res.status(400).json({ error: 'store, order_name, deadline, and pickup_spot are required.' });
      return;
    }

    const order = await OrderService.createOrder(userId, req.body);
    res.status(201).json({ order });
  } catch (err) {
    console.error('[createOrder]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function deleteOrder(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    await OrderService.deleteOrder(req.params.id as string, userId);
    res.json({ message: 'Order deleted.', id: req.params.id });
  } catch (err: any) {
    console.error('[deleteOrder]', err);
    const status = err.message?.includes('not found') ? 404
                 : err.message?.includes('Only the host') ? 403
                 : err.message?.includes('Only open') ? 409
                 : 500;
    res.status(status).json({ error: err.message || 'Internal server error.' });
  }
}

export async function joinOrder(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { items } = req.body;
    const result = await OrderService.joinOrder(req.params.id as string, userId, items || []);
    res.json(result);
  } catch (err: any) {
    console.error('[joinOrder]', err);
    const status = err.message?.includes('not found') ? 404
                 : err.message?.includes('no longer open') ? 409
                 : 500;
    res.status(status).json({ error: err.message || 'Internal server error.' });
  }
}

export async function leaveOrder(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const result = await OrderService.leaveOrder(req.params.id as string, userId);
    res.json(result);
  } catch (err: any) {
    console.error('[leaveOrder]', err);
    const status = err.message?.includes('Cannot leave') ? 409 : 500;
    res.status(status).json({ error: err.message || 'Internal server error.' });
  }
}

export async function updateStatus(req: Request, res: Response): Promise<void> {
  try {
    const { status, tracking_number } = req.body;
    if (!status) {
      res.status(400).json({ error: 'status is required.' });
      return;
    }
    const order = await OrderService.updateStatus(req.params.id as string, status, tracking_number);
    res.json({ order });
  } catch (err: any) {
    console.error('[updateStatus]', err);
    const httpStatus = err.message?.includes('Invalid status') ? 400
                     : err.message?.includes('not found') ? 404
                     : 500;
    res.status(httpStatus).json({ error: err.message || 'Internal server error.' });
  }
}

export async function getCostSplit(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const userResult = await pool.query(
      'SELECT home_currency FROM users WHERE id = $1', [userId]
    );
    const userCurrency = userResult.rows[0]?.home_currency;
    const split = await OrderService.getCostSplit(req.params.id as string, userCurrency);
    res.json({ data: split });
  } catch (err) {
    console.error('[getCostSplit]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getOrderItems(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const result = await OrderService.getOrderItems(req.params.id as string, userId);
    res.json(result);
  } catch (err) {
    console.error('[getOrderItems]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function updateOrderItems(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { items } = req.body;

    if (!items || !Array.isArray(items)) {
      res.status(400).json({ error: 'items must be an array.' });
      return;
    }

    for (const item of items) {
      if (!item.name || item.price_sgd == null || item.qty == null) {
        res.status(400).json({ error: 'Each item must have name, price_sgd, and qty.' });
        return;
      }
    }

    const result = await OrderService.updateOrderItems(
      req.params.id as string,
      userId,
      items,
    );
    res.json(result);
  } catch (err: any) {
    console.error('[updateOrderItems]', err);
    const status = err.message?.includes('not joined') ? 403
                 : err.message?.includes('Cannot update') ? 409
                 : 500;
    res.status(status).json({ error: err.message || 'Internal server error.' });
  }
}