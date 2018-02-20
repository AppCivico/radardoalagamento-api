-- Deploy tupa:app_report_pending to pg

BEGIN;

ALTER TABLE app_report ADD COLUMN solved_at TIMESTAMP WITHOUT TIME ZONE;

COMMIT;
