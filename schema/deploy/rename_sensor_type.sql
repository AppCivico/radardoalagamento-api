-- Deploy tupa:rename_sensor_type to pg

BEGIN;

ALTER TABLE sensor RENAME COLUMN type TO sensor_type;

COMMIT;
