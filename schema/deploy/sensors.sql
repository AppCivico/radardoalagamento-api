-- Deploy tupa:sensors to pg

BEGIN;

CREATE TABLE sensor_source (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);
  
CREATE TABLE sensor (
  id SERIAL PRIMARY KEY,
  source_id INTEGER REFERENCES sensor_source(id) NOT NULL,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  type TEXT,
  location geometry(POINT,4326),
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);
CREATE INDEX ON sensor USING GIST (location) WHERE location IS NOT NULL;

CREATE TABLE sensor_sample (
  id SERIAL PRIMARY KEY,
  sensor_id INTEGER REFERENCES sensor(id) NOT NULL,
  value TEXT NOT NULL,
  location geometry(POINT,4326),
  event_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  extra JSON
);
CREATE INDEX ON sensor_sample (sensor_id, event_ts DESC);
CREATE INDEX ON sensor_sample USING GIST (location) WHERE location IS NOT NULL;

COMMIT;
