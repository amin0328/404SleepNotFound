-- Smart buddy-feed signals, curated housing references, and chat attachments.
CREATE TABLE IF NOT EXISTS post_views (
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  viewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (post_id, viewer_id)
);

CREATE INDEX IF NOT EXISTS idx_post_views_viewer ON post_views (viewer_id, viewed_at DESC);
CREATE INDEX IF NOT EXISTS idx_post_views_post ON post_views (post_id, viewed_at DESC);

-- Reference records are maintained by the app and are distinguishable from student submissions.
ALTER TABLE listings ADD COLUMN IF NOT EXISTS reference_provider TEXT;
ALTER TABLE listings ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_listings_reference_provider ON listings (reference_provider)
  WHERE reference_provider IS NOT NULL;

-- The chat schema predates this migration in existing deployments.
ALTER TABLE IF EXISTS messages ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Run periodically when refreshing reference data; source URLs remain visible to students.
INSERT INTO listings (source, reference_provider, title, price_sgd, location, type, room, lease_months, url, available_from, notes, verified_at)
SELECT * FROM (VALUES
  ('reference', 'NUS Housing Guide', 'NUS vicinity housing guide: Clementi', 900::numeric, 'Clementi', 'reference', 'varies', NULL::int, 'https://www.nus.edu.sg/osa/student-services/hostel-admission/undergraduate/hostel-options', NULL::date, 'Reference guide only. Check availability and final rent with the provider.', NOW()),
  ('reference', 'NUS Housing Guide', 'NUS vicinity housing guide: Kent Ridge', 1000::numeric, 'Kent Ridge', 'reference', 'varies', NULL::int, 'https://www.nus.edu.sg/osa/student-services/hostel-admission/undergraduate/hostel-options', NULL::date, 'Reference guide only. Check availability and final rent with the provider.', NOW()),
  ('reference', 'NUS Housing Guide', 'NUS vicinity housing guide: Queenstown', 1050::numeric, 'Queenstown', 'reference', 'varies', NULL::int, 'https://www.nus.edu.sg/osa/student-services/hostel-admission/undergraduate/hostel-options', NULL::date, 'Reference guide only. Check availability and final rent with the provider.', NOW())
) AS reference_data(source, reference_provider, title, price_sgd, location, type, room, lease_months, url, available_from, notes, verified_at)
WHERE NOT EXISTS (
  SELECT 1 FROM listings l WHERE l.reference_provider = reference_data.reference_provider AND l.title = reference_data.title
);
