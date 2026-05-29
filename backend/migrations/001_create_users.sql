-- Run this in your Supabase SQL editor (or any Postgres client)

CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nusnet_id     VARCHAR(10)  NOT NULL UNIQUE,
  name          TEXT         NOT NULL,
  email         TEXT         NOT NULL UNIQUE,
  password_hash TEXT         NOT NULL,

  -- Onboarding / profile fields (nullable until onboarding is done)
  home_country  CHAR(2),
  major         TEXT,
  home_currency CHAR(3),
  dorm          TEXT,
  arrival_date  DATE,
  grad_year     SMALLINT,
  lifestyle     JSONB,          -- { sleep, cleanliness, cooking, noise, diet, social }

  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Indexes useful for auth lookups
CREATE INDEX IF NOT EXISTS idx_users_email     ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_nusnet_id ON users (nusnet_id);
