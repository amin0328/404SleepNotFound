import pool from '../config/db';

export async function getOrCreateConversation(userA: string, userB: string): Promise<string> {
  const [a, b] = [userA, userB].sort();

  const existing = await pool.query(
    'SELECT id FROM conversations WHERE user_a = $1 AND user_b = $2',
    [a, b],
  );

  if (existing.rows.length > 0) return existing.rows[0].id;

  const result = await pool.query(
    'INSERT INTO conversations (user_a, user_b) VALUES ($1, $2) RETURNING id',
    [a, b],
  );

  return result.rows[0].id;
}

export async function getOrCreateGroupConversation(orderId: string): Promise<string> {
  const existing = await pool.query(
    'SELECT id FROM group_conversations WHERE order_id = $1',
    [orderId],
  );

  if (existing.rows.length > 0) return existing.rows[0].id;

  const result = await pool.query(
    'INSERT INTO group_conversations (order_id) VALUES ($1) RETURNING id',
    [orderId],
  );

  return result.rows[0].id;
}

export async function addGroupConversationMember(conversationId: string, userId: string): Promise<void> {
  await pool.query(
    `INSERT INTO group_conversation_members (conversation_id, user_id)
     VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [conversationId, userId],
  );
}

export async function saveMessage(
  senderId: string,
  body: string,
  conversationId?: string,
  groupConversationId?: string,
): Promise<Record<string, unknown>> {
  const result = await pool.query(
    `INSERT INTO messages (sender_id, body, conversation_id, group_conversation_id)
     VALUES ($1, $2, $3, $4)
     RETURNING id, sender_id, body, conversation_id, group_conversation_id, created_at`,
    [senderId, body, conversationId ?? null, groupConversationId ?? null],
  );

  const message = result.rows[0];

  const userResult = await pool.query(
    'SELECT name, avatar_url FROM users WHERE id = $1',
    [senderId],
  );

  return {
    ...message,
    sender_name: userResult.rows[0]?.name ?? null,
    sender_avatar: userResult.rows[0]?.avatar_url ?? null,
  };
}

export async function getMessages(
  conversationId: string,
  limit = 50,
  before?: string,
): Promise<Record<string, unknown>[]> {
  const values: unknown[] = [conversationId, limit];
  let beforeClause = '';

  if (before) {
    beforeClause = 'AND m.created_at < $3';
    values.push(before);
  }

  const result = await pool.query(
    `SELECT m.id, m.body, m.created_at,
            m.sender_id, u.name AS sender_name, u.avatar_url AS sender_avatar
     FROM messages m
     JOIN users u ON u.id = m.sender_id
     WHERE m.conversation_id = $1
     ${beforeClause}
     ORDER BY m.created_at DESC
     LIMIT $2`,
    values,
  );

  return result.rows.reverse();
}

export async function getGroupMessages(
  groupConversationId: string,
  limit = 50,
  before?: string,
): Promise<Record<string, unknown>[]> {
  const values: unknown[] = [groupConversationId, limit];
  let beforeClause = '';

  if (before) {
    beforeClause = 'AND m.created_at < $3';
    values.push(before);
  }

  const result = await pool.query(
    `SELECT m.id, m.body, m.created_at,
            m.sender_id, u.name AS sender_name, u.avatar_url AS sender_avatar
     FROM messages m
     JOIN users u ON u.id = m.sender_id
     WHERE m.group_conversation_id = $1
     ${beforeClause}
     ORDER BY m.created_at DESC
     LIMIT $2`,
    values,
  );

  return result.rows.reverse();
}

export async function getUserConversations(userId: string): Promise<Record<string, unknown>[]> {
  const result = await pool.query(
    `SELECT
       c.id,
       'direct' AS type,
       CASE WHEN c.user_a = $1 THEN c.user_b ELSE c.user_a END AS other_user_id,
       u.name AS other_user_name,
       u.avatar_url AS other_user_avatar,
       m.body AS last_message,
       m.created_at AS last_message_at
     FROM conversations c
     JOIN users u ON u.id = CASE WHEN c.user_a = $1 THEN c.user_b ELSE c.user_a END
     LEFT JOIN LATERAL (
       SELECT body, created_at FROM messages
       WHERE conversation_id = c.id
       ORDER BY created_at DESC LIMIT 1
     ) m ON true
     WHERE c.user_a = $1 OR c.user_b = $1
     ORDER BY m.created_at DESC NULLS LAST`,
    [userId],
  );

  return result.rows;
}

export async function getUserGroupConversations(userId: string): Promise<Record<string, unknown>[]> {
  const result = await pool.query(
    `SELECT
       gc.id,
       'group' AS type,
       gc.order_id,
       go.order_name,
       go.store,
       m.body AS last_message,
       m.created_at AS last_message_at
     FROM group_conversation_members gcm
     JOIN group_conversations gc ON gc.id = gcm.conversation_id
     JOIN group_orders go ON go.id = gc.order_id
     LEFT JOIN LATERAL (
       SELECT body, created_at FROM messages
       WHERE group_conversation_id = gc.id
       ORDER BY created_at DESC LIMIT 1
     ) m ON true
     WHERE gcm.user_id = $1
     ORDER BY m.created_at DESC NULLS LAST`,
    [userId],
  );

  return result.rows;
}

export async function getConversationForUser(userId: string, conversationId: string): Promise<Record<string, unknown> | null> {
  const directResult = await pool.query(
    `SELECT
       c.id,
       'direct' AS type,
       CASE WHEN c.user_a = $2 THEN c.user_b ELSE c.user_a END AS other_user_id,
       u.name AS other_user_name,
       u.avatar_url AS other_user_avatar,
       m.body AS last_message,
       m.created_at AS last_message_at
     FROM conversations c
     JOIN users u ON u.id = CASE WHEN c.user_a = $2 THEN c.user_b ELSE c.user_a END
     LEFT JOIN LATERAL (
       SELECT body, created_at FROM messages
       WHERE conversation_id = c.id
       ORDER BY created_at DESC LIMIT 1
     ) m ON true
     WHERE c.id = $1 AND (c.user_a = $2 OR c.user_b = $2)`,
    [conversationId, userId],
  );

  if (directResult.rows.length > 0) {
    return directResult.rows[0];
  }

  const groupResult = await pool.query(
    `SELECT
       gc.id,
       'group' AS type,
       gc.order_id,
       go.order_name,
       go.store,
       m.body AS last_message,
       m.created_at AS last_message_at
     FROM group_conversations gc
     JOIN group_conversation_members gcm ON gcm.conversation_id = gc.id AND gcm.user_id = $2
     JOIN group_orders go ON go.id = gc.order_id
     LEFT JOIN LATERAL (
       SELECT body, created_at FROM messages
       WHERE group_conversation_id = gc.id
       ORDER BY created_at DESC LIMIT 1
     ) m ON true
     WHERE gc.id = $1`,
    [conversationId, userId],
  );

  return groupResult.rows[0] || null;
}

export async function isConversationMember(userId: string, conversationId: string): Promise<boolean> {
  const result = await pool.query(
    'SELECT id FROM conversations WHERE id = $1 AND (user_a = $2 OR user_b = $2)',
    [conversationId, userId],
  );

  return result.rows.length > 0;
}

export async function isGroupConversationMember(userId: string, groupConversationId: string): Promise<boolean> {
  const result = await pool.query(
    'SELECT * FROM group_conversation_members WHERE conversation_id = $1 AND user_id = $2',
    [groupConversationId, userId],
  );

  return result.rows.length > 0;
}