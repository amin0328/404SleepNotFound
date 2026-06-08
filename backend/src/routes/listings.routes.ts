import { Router } from 'express';
import {
  getListings,
  getSavedListings,
  getListingById,
  createListing,
  deleteListing,
  saveListing,
  unsaveListing,
} from '../controllers/listings.controller';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/',            requireAuth, getListings);
router.get('/saved',       requireAuth, getSavedListings);  // before /:id
router.get('/:id',         requireAuth, getListingById);
router.post('/',           requireAuth, createListing);
router.delete('/:id',      requireAuth, deleteListing);
router.post('/:id/save',   requireAuth, saveListing);
router.delete('/:id/save', requireAuth, unsaveListing);

export default router;