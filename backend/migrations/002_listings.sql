CREATE TABLE listings (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source         VARCHAR(50),
  title          VARCHAR(200),
  price_sgd      NUMERIC(10,2),
  location       VARCHAR(50),
  type           VARCHAR(50),
  room           VARCHAR(50),
  lease_months   INT,
  url            TEXT,
  available_from DATE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO listings (source, title, price_sgd, location, type, room, lease_months, available_from)
VALUES
  ('seed', 'Cozy room near Clementi MRT', 800, 'western', 'hdb', 'share', 12, '2025-08-01'),
  ('seed', 'Private room in Bishan condo', 1400, 'central', 'condo', 'private', 6, '2025-07-15'),
  ('seed', 'Studio near UTown NUS', 2200, 'central', 'condo', 'studio', 12, '2025-08-01'),
  ('seed', 'HDB room in Tampines', 700, 'eastern', 'hdb', 'share', 12, '2025-07-01'),
  ('seed', 'Landed house room in Buona Vista', 1100, 'western', 'landed', 'private', 6, '2025-08-15');