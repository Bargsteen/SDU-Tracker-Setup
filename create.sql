CREATE TABLE users (
  user_id VARCHAR(30) PRIMARY KEY,
  tracking_type BIT(1) NOT NULL,
  measurement_days SMALLINT NOT NULL,
  users VARCHAR(100) NOT NULL,
  setup_link VARCHAR(300)
  );
