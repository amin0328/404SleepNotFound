import pool from '../config/db';
import { sendGroupOrderStatusNotification } from './notification.service';

const VALID_TRANSITIONS: Record<string, string[]> = {
  open:      ['confirmed'],
  confirmed: ['shipped'],
  shipped:   ['arrived'],
  arrived:   [],
};

export function isValidTransition(from: string, to: string): boolean {
  return VALID_TRANSITIONS[from]?.includes(to) ?? false;
}

async function getExchangeRate(currency: string): Promise<number> {
  try {
    const res = await fetch('https://open.er-api.com/v6/latest/SGD');
    const data = await res.json() as { rates: Record<string, number> };
    return data.rates[currency.toUpperCase()] ?? 1;
  } catch {
    return 1;
  }
}

export async function getOrders(userId: string, status?: string, search?: string) {
  const values: unknown[] = [userId];
  const conditions: string[] = [];
  let idx = 2;

  if (status && status !== 'all') {
    conditions.push(`o.status = $${idx++}`);
    values.push(status);
  }

  if (search && typeof search === 'string') {
    conditions.push(`(LOWER(o.store) LIKE $${idx} OR LOWER(o.order_name) LIKE $${idx})`);
    values.push(`%${search.toLowerCase()}%`);
    idx++;
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(
    `SELECT
       o.*,
       u.name        AS host_name,
       u.avatar_url  AS host_avatar,
       COUNT(DISTINCT op.user_id)::int AS participant_count,
       CASE WHEN om.user_id IS NOT NULL THEN true ELSE false END AS is_joined,
       om.item_cost_sgd      AS my_item_cost_sgd,
       om.split_shipping_sgd AS my_split_shipping_sgd
     FROM group_orders o
     JOIN users u ON u.id = o.organiser_id
     LEFT JOIN order_participants op ON op.order_id = o.id
     LEFT JOIN order_participants om ON om.order_id = o.id AND om.user_id = $1
     ${where}
     GROUP BY o.id, u.name, u.avatar_url, om.user_id, om.item_cost_sgd, om.split_shipping_sgd
     ORDER BY o.created_at DESC`,
    values,
  );

  return result.rows;
}

export async function createOrder(organiserId: string, data: {
  store: string;
  country: string;
  category: string;
  order_name: string;
  min_participants: number;
  deadline: string;
  pickup_spot: string;
  shipping_cost_sgd: number;
}) {
  const result = await pool.query(
    `INSERT INTO group_orders
       (organiser_id, store, country, category, order_name,
        min_participants, deadline, pickup_spot, shipping_cost_sgd)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
     RETURNING *`,
    [
      organiserId, data.store, data.country, data.category,
      data.order_name, data.min_participants, data.deadline,
      data.pickup_spot, data.shipping_cost_sgd,
    ],
  );
  return result.rows[0];
}

export async function deleteOrder(orderId: string, userId: string): Promise<void> {
  const order = await pool.query(
    'SELECT organiser_id, status FROM group_orders WHERE id = $1',
    [orderId],
  );

  if (order.rows.length === 0) throw new Error('Order not found.');
  if (order.rows[0].organiser_id !== userId) throw new Error('Only the host can delete this order.');
  if (order.rows[0].status !== 'open') throw new Error('Only open orders can be deleted.');

  await pool.query('DELETE FROM group_orders WHERE id = $1', [orderId]);
}

export async function joinOrder(
  orderId: string,
  userId: string,
  items: Array<{ name: string; price_sgd: number; qty: number }>,
) {
  const orderResult = await pool.query(
    'SELECT status, min_participants FROM group_orders WHERE id = $1',
    [orderId],
  );
  if (orderResult.rows.length === 0) throw new Error('Order not found.');
  if (orderResult.rows[0].status !== 'open') throw new Error('This order is no longer open.');

  const itemTotal = items.reduce((sum, i) => sum + i.price_sgd * i.qty, 0);

  await pool.query(
    `INSERT INTO order_participants (order_id, user_id, items, item_cost_sgd)
     VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING`,
    [orderId, userId, JSON.stringify(items), itemTotal],
  );

  await recalculateSplitShipping(orderId);

  const countResult = await pool.query(
    'SELECT COUNT(*) FROM order_participants WHERE order_id = $1',
    [orderId],
  );
  const count = parseInt(countResult.rows[0].count);
  const min = orderResult.rows[0].min_participants;

  if (count >= min) {
    await pool.query(
      "UPDATE group_orders SET status = 'confirmed' WHERE id = $1 AND status = 'open'",
      [orderId],
    );
  }

  return { joined: true, order_id: orderId };
}

export async function leaveOrder(orderId: string, userId: string) {
  const orderResult = await pool.query(
    'SELECT status FROM group_orders WHERE id = $1',
    [orderId],
  );
  if (orderResult.rows[0]?.status !== 'open') {
    throw new Error('Cannot leave an order that is already confirmed or shipped.');
  }

  await pool.query(
    'DELETE FROM order_participants WHERE order_id = $1 AND user_id = $2',
    [orderId, userId],
  );

  await recalculateSplitShipping(orderId);
  return { left: true, order_id: orderId };
}

export async function updateStatus(orderId: string, newStatus: string, trackingNumber?: string) {
  const current = await pool.query(
    'SELECT status FROM group_orders WHERE id = $1',
    [orderId],
  );

  if (current.rows.length === 0) throw new Error('Order not found.');

  const currentStatus = current.rows[0].status;

  if (!isValidTransition(currentStatus, newStatus)) {
    throw new Error(
      `Invalid status transition: ${currentStatus} → ${newStatus}. ` +
      `Allowed: ${VALID_TRANSITIONS[currentStatus]?.join(', ') || 'none'}.`
    );
  }

  const result = await pool.query(
    `UPDATE group_orders SET status = $1, tracking_number = $2
     WHERE id = $3 RETURNING *`,
    [newStatus, trackingNumber ?? null, orderId],
  );

  const order = result.rows[0];
  await sendGroupOrderStatusNotification(orderId, order.order_name, newStatus);
  return order;
}

export async function getCostSplit(orderId: string, userCurrency?: string) {
  const participants = await pool.query(
    `SELECT op.user_id, u.name, u.home_currency,
            op.items, op.item_cost_sgd, op.split_shipping_sgd,
            o.shipping_cost_sgd
     FROM order_participants op
     JOIN users u ON u.id = op.user_id
     JOIN group_orders o ON o.id = op.order_id
     WHERE op.order_id = $1`,
    [orderId],
  );

  const rows = participants.rows;
  if (rows.length === 0) return [];

  const currencies = [...new Set(rows.map((r) => r.home_currency).filter(Boolean))];
  if (userCurrency) currencies.push(userCurrency);

  const rates: Record<string, number> = {};
  for (const currency of currencies) {
    if (currency) rates[currency] = await getExchangeRate(currency);
  }

  return rows.map((p) => {
    const totalSgd = (p.item_cost_sgd || 0) + (p.split_shipping_sgd || 0);
    const currency = userCurrency || p.home_currency || 'SGD';
    const rate = rates[currency] ?? 1;

    return {
      user_id:            p.user_id,
      name:               p.name,
      items_sgd:          parseFloat(p.item_cost_sgd) || 0,
      shipping_share_sgd: parseFloat(p.split_shipping_sgd) || 0,
      total_sgd:          totalSgd,
      currency,
      total_local:        Math.round(totalSgd * rate),
      exchange_rate:      rate,
    };
  });
}

export async function getOrderItems(orderId: string, userId: string) {
  const result = await pool.query(
    `SELECT op.user_id, u.name, op.items, op.item_cost_sgd
     FROM order_participants op
     JOIN users u ON u.id = op.user_id
     WHERE op.order_id = $1 AND op.user_id = $2`,
    [orderId, userId],
  );

  if (result.rows.length === 0) return { items: [], item_cost_sgd: 0 };

  return {
    items: result.rows[0].items || [],
    item_cost_sgd: parseFloat(result.rows[0].item_cost_sgd) || 0,
  };
}

export async function updateOrderItems(
  orderId: string,
  userId: string,
  items: Array<{ name: string; price_sgd: number; qty: number }>,
) {
  const membership = await pool.query(
    'SELECT user_id FROM order_participants WHERE order_id = $1 AND user_id = $2',
    [orderId, userId],
  );

  if (membership.rows.length === 0) throw new Error('You have not joined this order.');

  const orderStatus = await pool.query(
    'SELECT status FROM group_orders WHERE id = $1',
    [orderId],
  );

  if (orderStatus.rows[0]?.status !== 'open') {
    throw new Error('Cannot update items on a confirmed or shipped order.');
  }

  const itemTotal = items.reduce((sum, i) => sum + i.price_sgd * i.qty, 0);

  await pool.query(
    `UPDATE order_participants
     SET items = $1, item_cost_sgd = $2
     WHERE order_id = $3 AND user_id = $4`,
    [JSON.stringify(items), itemTotal, orderId, userId],
  );

  await recalculateSplitShipping(orderId);

  return { items, item_cost_sgd: itemTotal };
}

async function recalculateSplitShipping(orderId: string): Promise<void> {
  const result = await pool.query(
    `SELECT op.user_id, op.item_cost_sgd, o.shipping_cost_sgd
     FROM order_participants op
     JOIN group_orders o ON o.id = op.order_id
     WHERE op.order_id = $1`,
    [orderId],
  );

  const rows = result.rows;
  if (rows.length === 0) return;

  const shippingTotal = parseFloat(rows[0].shipping_cost_sgd) || 0;
  const grandTotal = rows.reduce((s, r) => s + (parseFloat(r.item_cost_sgd) || 0), 0);

  for (const row of rows) {
    const share = grandTotal > 0
      ? ((parseFloat(row.item_cost_sgd) || 0) / grandTotal) * shippingTotal
      : shippingTotal / rows.length;

    await pool.query(
      'UPDATE order_participants SET split_shipping_sgd = $1 WHERE order_id = $2 AND user_id = $3',
      [Math.round(share * 100) / 100, orderId, row.user_id],
    );
  }
}