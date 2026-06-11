import { Request, Response } from 'express';
import * as OrderService from '../services/order.service';

export async function getOrders(req: Request, res: Response) {
  try {
    const { status } = req.query;
    const orders = await OrderService.getOrders(status as string);
    res.json({ data: orders, total: orders.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
}

export async function createOrder(req: Request, res: Response) {
  try {
    const organiserId = (req as any).user.id;
    const order = await OrderService.createOrder(organiserId, req.body);
    res.status(201).json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create order' });
  }
}

export async function joinOrder(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const { items } = req.body;
    const result = await OrderService.joinOrder(req.params.id as string, userId, items || []);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Failed to join order' });
  }
}

export async function leaveOrder(req: Request, res: Response) {
  try {
    const userId = (req as any).user.id;
    const result = await OrderService.leaveOrder(req.params.id as string, userId);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Failed to leave order' });
  }
}

export async function updateStatus(req: Request, res: Response) {
  try {
    const { status, tracking_number } = req.body;
    const order = await OrderService.updateStatus(req.params.id as string, status, tracking_number);
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update status' });
  }
}

export async function getCostSplit(req: Request, res: Response) {
  try {
    const split = await OrderService.getCostSplit(req.params.id as string);
    res.json({ data: split });
  } catch (err) {
    res.status(500).json({ error: 'Failed to calculate split' });
  }
}