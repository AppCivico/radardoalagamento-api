-- Deploy tupa:user-phone-unique to pg

BEGIN;

create unique index user_active_phone_number
  ON "user"(phone_number)
  WHERE phone_number IS NOT NULL AND active IS TRUE;

COMMIT;
