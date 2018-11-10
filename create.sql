CREATE TABLE users (
  user_id VARCHAR(30) PRIMARY KEY,
  tracking_type BIT(1) NOT NULL,
  measurement_days SMALLINT NOT NULL,
  users VARCHAR(100) NOT NULL,
  setup_link VARCHAR(300)
  );

INSERT INTO users (user_id, tracking_type, measurement_days, users) VALUES
  ('kasperid', b'0', 30, '[kasper, peter]'),
  ('peterid', b'1', 20, '[soeren, peter]'),
  ('tomid', b'0', 30, '[tom, peter]');
