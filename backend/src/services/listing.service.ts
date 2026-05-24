import { pool } from '../config/db';

export async function getListings(filters: {
  min_price?: number;
  max_price?: number;
  location?: string;
  type?: string;
  room?: string;
  lease?: string;
}) {
  const conditions: string[] = [];
  const values: any[] = [];
  let i = 1;

  if (filters.min_price) {
    conditions.push(`price_sgd >= $${i++}`);
    values.push(filters.min_price);
  }
  if (filters.max_price) {
    conditions.push(`price_sgd <= $${i++}`);
    values.push(filters.max_price);
  }
  if (filters.location) {
    conditions.push(`location = $${i++}`);
    values.push(filters.location);
  }
  if (filters.type) {
    conditions.push(`type = $${i++}`);
    values.push(filters.type);
  }
  if (filters.room) {
    conditions.push(`room = $${i++}`);
    values.push(filters.room);
  }
  if (filters.lease === 'short') {
    conditions.push(`lease_months <= $${i++}`);
    values.push(6);
  } else if (filters.lease === 'long') {
    conditions.push(`lease_months > $${i++}`);
    values.push(6);
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query(
    `SELECT * FROM listings ${where} ORDER BY price_sgd ASC`,
    values
  );
  return result.rows;
}

export async function getListingById(id: string) {
  const result = await pool.query(
    'SELECT * FROM listings WHERE id = $1',
    [id]
  );
  return result.rows[0] || null;
}