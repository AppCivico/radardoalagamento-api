-- Deploy tupa:alert-district-as-list to pg

BEGIN;

ALTER TABLE alert DROP CONSTRAINT source_check,
  DROP COLUMN district_id;

CREATE TABLE alert_district(
  alert_id INTEGER REFERENCES alert(id) NOT NULL,
  district_id INTEGER REFERENCES district(id) NOT NULL,
  UNIQUE(alert_id, district_id)
);

COMMIT;
