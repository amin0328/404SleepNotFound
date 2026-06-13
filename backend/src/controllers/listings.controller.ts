import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth';

//  Singapore Region Mapping
const REGION_MAP: Record<string, string[]> = {
  central: [
    'bishan', 'bukit merah', 'bukit timah', 'downtown', 'geylang',
    'kallang', 'marina', 'marine parade', 'novena', 'orchard',
    'outram', 'queenstown', 'river valley', 'rochor', 'singapore river',
    'southern islands', 'straits view', 'tanglin', 'toa payoh',
    'newton', 'clementi', 'dover', 'ghim moh', 'buona vista',
    'one-north', 'kent ridge', 'west coast', 'pasir panjang',
    'harbourfront', 'telok blangah', 'tiong bahru', 'redhill',
    'commonwealth', 'bukit gombak', 'holland', 'farrer road',
    'botanic gardens', 'caldecott', 'marymount', 'braddell',
    'potong pasir', 'woodleigh', 'serangoon', 'lorong chuan',
    'bartley', 'tai seng', 'macpherson', 'aljunied', 'paya lebar',
    'mountbatten', 'stadium', 'lavender', 'bugis', 'city hall',
    'esplanade', 'promenade', 'bayfront', 'raffles place', 'tanjong pagar',
    'chinatown', 'clarke quay', 'dhoby ghaut', 'little india', 'bras basah',
    'bendemeer', 'boon keng', 'farrer park', 'jalan besar',
    'utown', 'kent ridge', 'haw par villa',
  ],
  northern: [
    'admiralty', 'ang mo kio', 'canberra', 'central water catchment',
    'khatib', 'lim chu kang', 'mandai', 'marsiling', 'sembawang',
    'simpang', 'sungei kadut', 'woodlands', 'yio chu kang', 'yishun',
    'springleaf', 'lentor', 'thomson', 'upper thomson', 'sin ming',
    'mayflower', 'bright hill', 'mount pleasant',
  ],
  southern: [
    'sentosa', 'labrador', 'harbourfront', 'telok blangah',
    'bukit merah', 'pasir panjang', 'west coast',
  ],
  eastern: [
    'bedok', 'changi', 'changi airport', 'kembangan', 'pasir ris',
    'tampines', 'upper changi', 'simei', 'tanah merah', 'expo',
    'chai chee', 'eunos', 'kembangan', 'ubi', 'kaki bukit',
    'bedok north', 'bedok reservoir', 'bedok south',
    'flora', 'loyang', 'pasir ris', 'punggol walk',
  ],
  western: [
    'boon lay', 'bukit batok', 'bukit panjang', 'choa chu kang',
    'clementi', 'dover', 'ghim moh', 'jurong east', 'jurong west',
    'lakeside', 'lim chu kang', 'nanyang', 'pioneer', 'tengah',
    'tuas', 'western islands', 'western water catchment',
    'buona vista', 'one-north', 'kent ridge', 'west coast',
    'pasir panjang', 'commonwealth', 'queenstown',
    'chinese garden', 'lakeside', 'boon lay', 'productivity',
    'joo koon', 'gul circle', 'tuas crescent', 'tuas west',
    'beauty world', 'king albert park', 'sixth avenue',
    'tan kah kee', 'cashew', 'hillview', 'phoenix',
    'bukit panjang', 'senja', 'jelapang', 'bangkit',
  ],
};

function getRegionCondition(region: string): { clause: string; values: string[] } {
  const places = REGION_MAP[region.toLowerCase()];
  if (!places || places.length === 0) return { clause: '', values: [] };

  const conditions = places.map((_, i) => `LOWER(l.location) LIKE $PLACEHOLDER_${i}`);
  return {
    clause: `(${conditions.join(' OR ')})`,
    values: places.map(p => `%${p}%`),
  };
}

export async function getListings(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { location, type, min_price, max_price, region } = req.query;

    const conditions: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    if (region && typeof region === 'string' && region !== 'all') {
      const { clause, values: regionValues } = getRegionCondition(region);
      if (clause) {

        let resolvedClause = clause;
        regionValues.forEach((_, i) => {
          resolvedClause = resolvedClause.replace(`$PLACEHOLDER_${i}`, `$${idx++}`);
          values.push(regionValues[i]);
        });
        conditions.push(resolvedClause);
      }
    }

    if (location && typeof location === 'string') {
      conditions.push(`LOWER(l.location) LIKE $${idx++}`);
      values.push(`%${location.toLowerCase()}%`);
    }

    if (type && typeof type === 'string') {
      conditions.push(`LOWER(l.type) = $${idx++}`);
      values.push(type.toLowerCase());
    }

    if (min_price) {
      conditions.push(`l.price_sgd >= $${idx++}`);
      values.push(Number(min_price));
    }

    if (max_price) {
      conditions.push(`l.price_sgd <= $${idx++}`);
      values.push(Number(max_price));
    }

    const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
    values.push(userId);

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              l.posted_by, l.notes,
              CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END AS is_saved
       FROM listings l
       LEFT JOIN saved_listings sl ON sl.listing_id = l.id AND sl.user_id = $${idx}
       ${where}
       ORDER BY l.available_from ASC NULLS LAST, l.created_at DESC`,
      values,
    );

    res.json({ listings: result.rows, total: result.rowCount });
  } catch (err) {
    console.error('[getListings]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getRegions(_req: Request, res: Response): Promise<void> {
  res.json({
    regions: [
      {
        id: 'all',
        label: 'All',
        places: [],
      },
      {
        id: 'central',
        label: 'Central',
        places: ['Queenstown', 'Clementi', 'Buona Vista', 'Toa Payoh', 'Bishan',
                 'Novena', 'Orchard', 'Geylang', 'Serangoon', 'UTown'],
      },
      {
        id: 'northern',
        label: 'Northern',
        places: ['Woodlands', 'Yishun', 'Sembawang', 'Ang Mo Kio',
                 'Yio Chu Kang', 'Thomson', 'Admiralty'],
      },
      {
        id: 'southern',
        label: 'Southern',
        places: ['Sentosa', 'Labrador', 'HarbourFront',
                 'Telok Blangah', 'Pasir Panjang'],
      },
      {
        id: 'eastern',
        label: 'Eastern',
        places: ['Tampines', 'Bedok', 'Pasir Ris', 'Changi',
                 'Simei', 'Kembangan', 'Eunos'],
      },
      {
        id: 'western',
        label: 'Western',
        places: ['Jurong East', 'Jurong West', 'Bukit Batok', 'Boon Lay',
                 'Choa Chu Kang', 'Bukit Panjang', 'Tengah', 'West Coast'],
      },
    ]
  });
}

export async function getSavedListings(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              l.posted_by, l.notes, true AS is_saved
       FROM listings l
       INNER JOIN saved_listings sl ON sl.listing_id = l.id
       WHERE sl.user_id = $1
       ORDER BY sl.created_at DESC`,
      [userId],
    );

    res.json({ listings: result.rows, total: result.rowCount });
  } catch (err) {
    console.error('[getSavedListings]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function getListingById(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      `SELECT l.id, l.source, l.title, l.price_sgd, l.location, l.type, l.room,
              l.lease_months, l.url, l.available_from, l.created_at,
              l.posted_by, l.notes,
              CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END AS is_saved
       FROM listings l
       LEFT JOIN saved_listings sl ON sl.listing_id = l.id AND sl.user_id = $2
       WHERE l.id = $1`,
      [id, userId],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Listing not found.' });
      return;
    }

    res.json({ listing: result.rows[0] });
  } catch (err) {
    console.error('[getListingById]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function createListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { title, price_sgd, location, type, room, lease_months, url, available_from, notes } = req.body;

    if (!title || !price_sgd || !location || !type) {
      res.status(400).json({ error: 'title, price_sgd, location, and type are required.' });
      return;
    }

    const result = await pool.query(
      `INSERT INTO listings
         (source, title, price_sgd, location, type, room, lease_months, url, available_from, notes, posted_by)
       VALUES ('user', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        title.trim(), Number(price_sgd), location.trim(), type.trim(),
        room ?? null, lease_months ?? null, url ?? null,
        available_from ?? null, notes ?? null, userId,
      ],
    );

    res.status(201).json({ listing: result.rows[0] });
  } catch (err) {
    console.error('[createListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function deleteListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM listings WHERE id = $1 AND posted_by = $2 RETURNING id',
      [id, userId],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Listing not found or you are not the owner.' });
      return;
    }

    res.json({ message: 'Listing deleted.', id });
  } catch (err) {
    console.error('[deleteListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function saveListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const listing = await pool.query('SELECT id FROM listings WHERE id = $1', [id]);
    if (listing.rows.length === 0) {
      res.status(404).json({ error: 'Listing not found.' });
      return;
    }

    await pool.query(
      'INSERT INTO saved_listings (user_id, listing_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [userId, id],
    );

    res.status(201).json({ message: 'Listing saved.', listing_id: id });
  } catch (err) {
    console.error('[saveListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}

export async function unsaveListing(req: Request, res: Response): Promise<void> {
  try {
    const userId = (req as AuthRequest).userId!;
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM saved_listings WHERE user_id = $1 AND listing_id = $2 RETURNING listing_id',
      [userId, id],
    );

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Saved listing not found.' });
      return;
    }

    res.json({ message: 'Listing unsaved.', listing_id: id });
  } catch (err) {
    console.error('[unsaveListing]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}