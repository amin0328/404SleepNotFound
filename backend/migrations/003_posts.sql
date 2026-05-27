CREATE TABLE posts (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  category     VARCHAR(50) NOT NULL,
  title        VARCHAR(200) NOT NULL,
  body         TEXT,
  group_size   INT,
  current_size INT DEFAULT 1,
  tags         TEXT[],
  move_in_date DATE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE post_interests (
  post_id    UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
);