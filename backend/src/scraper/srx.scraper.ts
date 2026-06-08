import puppeteer from 'puppeteer';
import pool from '../config/db';

interface ScrapedListing {
  title: string;
  price_sgd: number;
  location: string;
  type: string;
  room: string | null;
  lease_months: number | null;
  url: string;
  available_from: string | null;
}

export async function scrapeSRX(): Promise<void> {
  console.log('[scraper] Starting SRX scrape...');

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();

    await page.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    );

    const url = 'https://www.srx.com.sg/rent/hdb?district=D05,D10,D11&minprice=500&maxprice=2000';
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });

    await page.waitForSelector('.listing-card, .property-card', { timeout: 10000 }).catch(() => {
      console.log('[scraper] Selector not found — SRX may have changed their HTML');
    });

    const listings: ScrapedListing[] = await page.evaluate(() => {
      const cards = document.querySelectorAll('.listing-card, .property-card');
      const results: ScrapedListing[] = [];

      cards.forEach((card) => {
        try {
          const title = card.querySelector('.listing-title, h3')?.textContent?.trim() ?? '';
          const priceText = card.querySelector('.listing-price, .price')?.textContent ?? '';
          const price = parseInt(priceText.replace(/[^0-9]/g, ''), 10);
          const location = card.querySelector('.listing-location, .location')?.textContent?.trim() ?? '';
          const link = card.querySelector('a')?.getAttribute('href') ?? '';

          if (title && price && location) {
            results.push({
              title,
              price_sgd: price,
              location,
              type: 'HDB',
              room: null,
              lease_months: 12,
              url: link.startsWith('http') ? link : `https://www.srx.com.sg${link}`,
              available_from: null,
            });
          }
        } catch {}
      });

      return results;
    });

    console.log(`[scraper] Found ${listings.length} listings`);

    let inserted = 0;
    for (const listing of listings) {
      const existing = await pool.query('SELECT id FROM listings WHERE url = $1', [listing.url]);
      if (existing.rows.length === 0) {
        await pool.query(
          `INSERT INTO listings (source, title, price_sgd, location, type, room, lease_months, url, available_from)
           VALUES ('srx', $1, $2, $3, $4, $5, $6, $7, $8)`,
          [listing.title, listing.price_sgd, listing.location, listing.type,
           listing.room, listing.lease_months, listing.url, listing.available_from],
        );
        inserted++;
      }
    }

    console.log(`[scraper] Inserted ${inserted} new listings`);
  } catch (err) {
    console.error('[scraper] Error:', err);
  } finally {
    await browser.close();
  }
}