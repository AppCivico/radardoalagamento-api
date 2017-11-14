-- Deploy tupa:user-and-session to pg

BEGIN;

CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone_number TEXT,
  password TEXT,

  create_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  active BOOLEAN DEFAULT TRUE
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE user_session (
  user_id INTEGER REFERENCES "user"(id) NOT NULL,
  api_key UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  create_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  valid_until TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now() + interval '10 years'
);
COMMIT;
