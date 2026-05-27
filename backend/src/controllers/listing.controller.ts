import { Request, Response } from 'express';
import * as ListingService from '../services/listing.service';

export async function getListings(req: Request, res: Response) {
  try {
    const { min_price, max_price, location, type, room, lease } = req.query;
    const listings = await ListingService.getListings({
      min_price: min_price ? Number(min_price) : undefined,
      max_price: max_price ? Number(max_price) : undefined,
      location: location as string,
      type: type as string,
      room: room as string,
      lease: lease as string,
    });
    res.json({ data: listings, total: listings.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch listings' });
  }
}

export async function getListingById(req: Request, res: Response) {
  try {
    const listing = await ListingService.getListingById(req.params.id as string);
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    res.json(listing);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch listing' });
  }
}