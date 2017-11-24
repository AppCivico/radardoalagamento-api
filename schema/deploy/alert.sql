-- Deploy tupa:alert to pg

BEGIN;

CREATE TABLE alert (
  id SERIAL PRIMARY KEY,
  sensor_sample_id INTEGER REFERENCES sensor_sample(id) NOT NULL,
  description TEXT,
  level TEXT NOT NULL, CHECK (level IN ('attention', 'alert', 'emergency', 'overflow')),
  pushed_to_users BOOLEAN DEFAULT false,
  reporter_id INTEGER REFERENCES "user"(id) NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

COMMIT;
