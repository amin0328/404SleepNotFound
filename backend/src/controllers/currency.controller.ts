import { Request, Response } from 'express';

export async function getRates(req: Request, res: Response): Promise<void> {
  try {
    const response = await fetch('https://open.er-api.com/v6/latest/SGD');

    if (!response.ok) {
      res.status(502).json({ error: 'Failed to fetch exchange rates.' });
      return;
    }

    const data = await response.json() as {
      result: string;
      time_last_update_utc: string;
      base_code: string;
      rates: Record<string, number>;
    };

    if (data.result !== 'success') {
      res.status(502).json({ error: 'Exchange rate provider returned an error.' });
      return;
    }

    const { query } = req.query;
    let rates = data.rates;

    if (query && typeof query === 'string') {
      const code = query.toUpperCase();
      if (!rates[code]) {
        res.status(404).json({ error: `Currency ${code} not found.` });
        return;
      }

      res.json({
        base: 'SGD',
        last_updated: data.time_last_update_utc,
        rates: { [code]: rates[code] },
      });
      return;
    }

    res.json({
      base: 'SGD',
      last_updated: data.time_last_update_utc,
      rates,
    });
  } catch (err) {
    console.error('[getRates]', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
}