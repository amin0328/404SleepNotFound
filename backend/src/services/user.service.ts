import { pool } from '../config/db';

export async function getProfile(userId: string) {
  const result = await pool.query(
    `SELECT id, nusnet_id, name, email, home_country, major,
            home_currency, dorm, arrival_date, grad_year, lifestyle
     FROM users WHERE id = $1`,
    [userId]
  );
  return result.rows[0] || null;
}

export async function updateProfile(userId: string, data: any) {
  const fields = Object.keys(data).map((k, i) => `${k} = $${i + 2}`).join(', ');
  const values = Object.values(data);
  const result = await pool.query(
    `UPDATE users SET ${fields} WHERE id = $1 RETURNING
     id, nusnet_id, name, email, home_country, major,
     home_currency, dorm, arrival_date, grad_year, lifestyle`,
    [userId, ...values]
  );
  return result.rows[0];
}