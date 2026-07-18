CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nusnet_id VARCHAR(10) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  home_country CHAR(2),
  major VARCHAR(100),
  home_currency CHAR(3),
  dorm VARCHAR(100),
  arrival_date DATE,
  grad_year INT,
  lifestyle JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS deadlines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  source VARCHAR(50) NOT NULL DEFAULT 'personal',
  title VARCHAR(200) NOT NULL,
  category VARCHAR(50),
  due_date DATE NOT NULL,
  reminder_days INT[],
  notifications_on BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  posted_by UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200),
  type VARCHAR(50),
  location VARCHAR(50),
  price_sgd DECIMAL,
  lease_months INT,
  room VARCHAR(50),
  is_flagged BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  category VARCHAR(50),
  title VARCHAR(200),
  body TEXT,
  group_size INT,
  tags TEXT[],
  move_in_date DATE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS post_interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(post_id, user_id)
);
