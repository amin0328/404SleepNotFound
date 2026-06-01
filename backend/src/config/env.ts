import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const JWT_SECRET = process.env.JWT_SECRET as string;
export const DATABASE_URL = process.env.DATABASE_URL as string;
export const PORT = process.env.PORT || 3000;