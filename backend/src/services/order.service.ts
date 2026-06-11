import pool from '../config/db';

export async function getOrders(status?: string) {
  const result = await pool.query(
    `SELECT o.*, u.name as host_name, u.avatar_url as host_avatar,
     COUNT(op.user_id) as participant_count
     FROM group_orders o
     JOIN users u ON u.id = o.organiser_id
     LEFT JOIN order_participants op ON op.order_id = o.id
     ${status && status !== 'all' ? 'WHERE o.status = $1' : ''}
     GROUP BY o.id, u.name, u.avatar_url
     ORDER BY o.created_at DESC`,
    status && status !== 'all' ? [status] : []
  );
  return result.rows;
}

export async function createOrder(organiserId: string, data: {
  store: string; country: string; category: string;
  order_name: string; min_participants: number;
  deadline: string; pickup_spot: string; shipping_cost_sgd: number;
}) {
  const result = await pool.query(
    `INSERT INTO group_orders
     (organiser_id, store, country, category, order_name, min_participants, deadline, pickup_spot, shipping_cost_sgd)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
    [organiserId, data.store, data.country, data.category,
     data.order_name, data.min_participants, data.deadline,
     data.pickup_spot, data.shipping_cost_sgd]
  );
  return result.rows[0];
}

export async function joinOrder(orderId: string, userId: string, items: any[]) {
  await pool.query(
    `INSERT INTO order_participants (order_id, user_id, items)
     VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`,
    [orderId, userId, JSON.stringify(items)]
  );

  // Check if min participants reached → auto confirm
  const countResult = await pool.query(
    'SELECT COUNT(*) FROM order_participants WHERE order_id = $1',
    [orderId]
  );
  const orderResult = await pool.query(
    'SELECT min_participants FROM group_orders WHERE id = $1',
    [orderId]
  );
  const count = parseInt(countResult.rows[0].count);
  const min = orderResult.rows[0].min_participants;

  if (count >= min) {
    await pool.query(
      "UPDATE group_orders SET status = 'confirmed' WHERE id = $1 AND status = 'open'",
      [orderId]
    );
  }

  return { joined: true, order_id: orderId };
}

export async function leaveOrder(orderId: string, userId: string) {
  await pool.query(
    'DELETE FROM order_participants WHERE order_id = $1 AND user_id = $2',
    [orderId, userId]
  );
  return { left: true, order_id: orderId };
}

export async function updateStatus(orderId: string, status: string, tracking_number?: string) {
  const result = await pool.query(
    `UPDATE group_orders SET status = $1, tracking_number = $2
     WHERE id = $3 RETURNING *`,
    [status, tracking_number || null, orderId]
  );
  return result.rows[0];
}

export async function getCostSplit(orderId: string) {
  const participants = await pool.query(
    `SELECT op.user_id, u.name, op.items,
     o.shipping_cost_sgd
     FROM order_participants op
     JOIN users u ON u.id = op.user_id
     JOIN group_orders o ON o.id = op.order_id
     WHERE op.order_id = $1`,
    [orderId]
  );

  const rows = participants.rows;
  const shippingTotal = rows[0]?.shipping_cost_sgd || 0;

  const withTotals = rows.map(p => {
    const items = p.items || [];
    const itemTotal = items.reduce((sum: number, i: any) =>
      sum + (i.price_sgd * i.qty), 0);
    return { user_id: p.user_id, name: p.name, itemTotal };
  });

  const grandTotal = withTotals.reduce((s, p) => s + p.itemTotal, 0);

  return withTotals.map(p => ({
    user_id: p.user_id,
    name: p.name,
    items_sgd: p.itemTotal,
    shipping_share_sgd: grandTotal > 0
      ? (p.itemTotal / grandTotal) * shippingTotal
      : shippingTotal / rows.length,
    total_sgd: p.itemTotal + (grandTotal > 0
      ? (p.itemTotal / grandTotal) * shippingTotal
      : shippingTotal / rows.length)
  }));
}