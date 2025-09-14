-- Demo data for users table. Uses INSERT IGNORE to avoid duplicate errors.
INSERT IGNORE INTO demo_db.users (nom, email) VALUES
  ('Alice Doe', 'alice@example.com'),
  ('Bob Smith', 'bob@example.com'),
  ('Charlie Ray', 'charlie@example.com'),
  ('Diana Cruz', 'diana@example.com'),
  ('Eric Adams', 'eric@example.com'),
  ('Fiona West', 'fiona@example.com'),
  ('George Lin', 'george@example.com'),
  ('Hana Lee', 'hana@example.com'),
  ('Ivan North', 'ivan@example.com'),
  ('Jade Black', 'jade@example.com');
