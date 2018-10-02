-- Deploy tupa:user-role to pg

BEGIN;

CREATE TABLE "role" (
  id SERIAL PRIMARY KEY,
  label TEXT NOT NULL,
  name TEXT UNIQUE NOT NULL
);

CREATE TABLE user_role (
  user_id INTEGER REFERENCES "user"(id) NOT NULL,
  role_id INTEGER REFERENCES "role"(id) NOT NULL,
  create_ts TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, role_id)
);

INSERT INTO "role"(label, name) VALUES ('Admin', 'admin');

COMMIT;
