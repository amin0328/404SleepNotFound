import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import * as ListingController from '../controllers/listing.controller';

const router = Router();

router.get('/',     requireAuth, ListingController.getListings);
router.get('/:id',  requireAuth, ListingController.getListingById);

export default router;
