import { Router } from 'express';
import multer from 'multer';
import {
  getListings,
  getRegions,
  getSavedListings,
  getListingById,
  getListingReviews,
  createListingReview,
  deleteListingReview,
  createListing,
  deleteListing,
  saveListing,
  unsaveListing,
} from '../controllers/listings.controller';
import { uploadListingImage } from '../controllers/upload.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

router.get('/regions',       requireAuth, getRegions);      // must be before /:id
router.get('/',              requireAuth, getListings);
router.get('/saved',         requireAuth, getSavedListings); // must be before /:id
router.post('/upload-image', requireAuth, upload.single('image'), uploadListingImage);
router.get('/:id',           requireAuth, getListingById);
router.get('/:id/reviews',   requireAuth, getListingReviews);
router.post('/:id/reviews',  requireAuth, createListingReview);
router.delete('/:id/reviews/:reviewId', requireAuth, deleteListingReview);
router.post('/',             requireAuth, createListing);
router.delete('/:id',        requireAuth, deleteListing);
router.post('/:id/save',     requireAuth, saveListing);
router.delete('/:id/save',   requireAuth, unsaveListing);

export default router;