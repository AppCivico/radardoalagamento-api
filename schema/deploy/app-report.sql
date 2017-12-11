-- Deploy tupa:app-report to pg

BEGIN;

CREATE TABLE app_report (
  id SERIAL PRIMARY KEY NOT NULL,
  user_id INTEGER REFERENCES "user"(id) NOT NULL,
  create_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  status TEXT NOT NULL CHECK (status IN ('info', 'warning', 'error', 'debug')),
  payload TEXT NOT NULL
);

COMMIT;
