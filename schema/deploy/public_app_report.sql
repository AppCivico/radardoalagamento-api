-- Deploy tupa:public_app_report to pg

BEGIN;

ALTER TABLE app_report DROP COLUMN user_id, DROP COLUMN status;

COMMIT;
