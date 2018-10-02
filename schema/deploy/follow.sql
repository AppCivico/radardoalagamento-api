-- Deploy tupa:follow to pg

BEGIN;

CREATE TABLE user_district (
  user_id INTEGER REFERENCES "user"(id) NOT NULL,
  district_id INTEGER REFERENCES district(id) NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  UNIQUE(user_id, district_id)
);

COMMIT;
