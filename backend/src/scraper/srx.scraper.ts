import * as cheerio from 'cheerio';
import pool from '../config/db';

interface ScrapedListing {
  title: string;
  price_sgd: number;
  location: string;
  type: string;
  room: string | null;
  lease_months: number | null;
  url: string;
}

export async function scrapeSRX(): Promise<void> {
  console.log('[scraper] Starting SRX scrape...');

  try {
    const response = await fetch('https://www.srx.com.sg/rent/hdb?district=D05,D10,D11&minprice=500&maxprice=2000', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Cache-Control': 'no-cache',
        'Referer': 'https://www.google.com/',
      },
    });

    if (!response.ok) {
      console.error(`[scraper] HTTP ${response.status} from SRX`);
      return;
    }

    const html = await response.text();
    const $ = cheerio.load(html);
    const listings: ScrapedListing[] = [];

    // Try multiple selectors since SRX may change their HTML
    const cardSelectors = [
      '.listing-card',
      '.property-card', 
      '[class*="listing"]',
      '[class*="property"]',
    ];

    let cards = $();
    for (const selector of cardSelectors) {
      cards = $(selector);
      if (cards.length > 0) {
        console.log(`[scraper] Found cards with selector: ${selector}`);
        break;
      }
    }

    if (cards.length === 0) {
      // Log the page title to see what we got back
      const title = $('title').text();
      console.log(`[scraper] No cards found. Page title: "${title}"`);
      console.log('[scraper] SRX may be blocking requests or changed their HTML structure');
      return;
    }

    cards.each((_, el) => {
      try {
        const card = $(el);
        const title = card.find('h3, .title, [class*="title"]').first().text().trim();
        const priceText = card.find('[class*="price"]').first().text();
        const price = parseInt(priceText.replace(/[^0-9]/g, ''), 10);
        const location = card.find('[class*="location"], [class*="address"]').first().text().trim();
        const link = card.find('a').first().attr('href') ?? '';

        if (title && price && location && price > 0) {
          listings.push({
            title,
            price_sgd: price,
            location,
            type: 'HDB',
            room: null,
            lease_months: 12,
            url: link.startsWith('http') ? link : `https://www.srx.com.sg${link}`,
          });
        }
      } catch {}
    });

    console.log(`[scraper] Parsed ${listings.length} listings`);

    let inserted = 0;
    for (const listing of listings) {
      const existing = await pool.query('SELECT id FROM listings WHERE url = $1', [listing.url]);
      if (existing.rows.length === 0) {
        await pool.query(
          `INSERT INTO listings (source, title, price_sgd, location, type, room, lease_months, url)
           VALUES ('srx', $1, $2, $3, $4, $5, $6, $7)`,
          [listing.title, listing.price_sgd, listing.location, listing.type,
           listing.room, listing.lease_months, listing.url],
        );
        inserted++;
      }
    }

    console.log(`[scraper] Inserted ${inserted} new listings`);
  } catch (err) {
    console.error('[scraper] Error:', err);
  }
}