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

-- Housing guidance and external search portals are presented in the mobile app's
-- regional Housing Resources section, rather than as misleading static listings.
