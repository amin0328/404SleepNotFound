import { Request, Response } from 'express';
import { randomUUID } from 'crypto';
import { supabase, STORAGE_BUCKET } from '../config/supabase';
import { AuthRequest } from '../middleware/auth';
import multer from 'multer';

const upload = multer();

export async function uploadListingImage(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const file = (req as Request & { file?: any }).file;

    if (!file) {
      res.status(400).json({ error: 'No image file provided.' });
      return;
    }

    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.mimetype)) {
      res.status(400).json({ error: 'Only JPEG, PNG, or WEBP images are allowed.' });
      return;
    }

    const ext = file.mimetype === 'image/png' ? 'png'
              : file.mimetype === 'image/webp' ? 'webp'
              : 'jpg';
    const path = `${userId}/${randomUUID()}.${ext}`;

    const { error: uploadError } = await supabase.storage
      .from(STORAGE_BUCKET)
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (uploadError) {
      console.error('[uploadListingImage] Supabase upload error:', uploadError);
      res.status(500).json({ error: 'Failed to upload image.' });
      return;
    }

    const { data } = supabase.storage.from(STORAGE_BUCKET).getPublicUrl(path);

    res.status(201).json({ image_url: data.publicUrl });
  } catch (err) {
    console.error('[uploadListingImage]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}