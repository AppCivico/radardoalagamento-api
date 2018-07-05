-- Deploy tupa:user-report to pg

BEGIN;

CREATE TABLE report (
  id SERIAL PRIMARY KEY NOT NULL,
  description TEXT,
  level TEXT NOT NULL, CHECK (level IN ('attention', 'alert', 'emergency', 'overflow')),
  reported_ts TIMESTAMP WITHOUT TIME ZONE,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  reporter_id INTEGER REFERENCES "user"(id) NOT NULL,
  location geometry(POINT,4326)
);

CREATE INDEX ON sensor USING GIST (location) WHERE location IS NOT NULL;

ALTER TABLE alert ADD COLUMN report_id INTEGER REFERENCES report(id);

COMMIT;
