-- Deploy tupa:user-push-token to pg

BEGIN;

ALTER TABLE "user" ADD COLUMN push_token TEXT;

create unique index user_active_push_token ON "user"(push_token) WHERE push_token IS NOT NULL AND active IS TRUE;

COMMIT;
