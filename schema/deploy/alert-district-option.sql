-- Deploy tupa:alert-district-option to pg

BEGIN;

ALTER TABLE alert
  ALTER COLUMN sensor_sample_id DROP NOT NULL,
  ADD COLUMN district_id INTEGER REFERENCES district(id),
  ADD CONSTRAINT source_check CHECK( district_id IS NOT NULL OR sensor_sample_id IS NOT NULL);
  
COMMIT;
