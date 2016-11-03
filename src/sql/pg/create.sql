
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;


CREATE TABLE IF NOT EXISTS "L_ACCOUNTS" (
  "ACCOUNT_ID" SERIAL NOT NULL,
  "NAME" CHARACTER VARYING(255) NOT NULL,
  "BALANCE" DECIMAL(32,16) DEFAULT 0 NOT NULL CHECK
    ("BALANCE" >= "MINIMUM_ALLOWED_BALANCE"),
  "CONNECTOR" CHARACTER VARYING(1024) NULL,
  "PASSWORD_HASH" CHARACTER VARYING(1024) NULL,
  "PUBLIC_KEY" CHARACTER VARYING(4000) NULL,
  "IS_ADMIN" SMALLINT DEFAULT 0 NOT NULL,
  "IS_DISABLED" SMALLINT DEFAULT 0 NOT NULL,
  "FINGERPRINT" CHARACTER VARYING(255) NULL,
  "MINIMUM_ALLOWED_BALANCE" DECIMAL(32,16) DEFAULT 0,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_ACCOUNTS" ON "L_ACCOUNTS"
  ("ACCOUNT_ID" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT "L_PK_ACCOUNTS" PRIMARY KEY
  ("ACCOUNT_ID");
CREATE UNIQUE INDEX "L_XAK_ACCOUNTS" ON "L_ACCOUNTS"
  ("NAME" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT "L_AK_ACCOUNTS" UNIQUE
  ("NAME");
CREATE INDEX "L_XIE_FINGERPRINT" ON "L_ACCOUNTS"
  ("FINGERPRINT" ASC);


CREATE TABLE IF NOT EXISTS "L_LU_REJECTION_REASON" (
  "REJECTION_REASON_ID" INTEGER NOT NULL,
  "NAME" CHARACTER VARYING(10) NOT NULL,
  "DESCRIPTION" CHARACTER VARYING(255) NULL,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("REJECTION_REASON_ID" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_PK_LU_TRANSFERS_REJECTION_RE"
  PRIMARY KEY ("REJECTION_REASON_ID");
CREATE INDEX "L_XAK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("NAME" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_AK_LU_TRANSFERS_REJECTION_RE" UNIQUE
  ("NAME");


CREATE TABLE IF NOT EXISTS "L_LU_TRANSFER_STATUS" (
  "STATUS_ID" INTEGER NOT NULL,
  "NAME" CHARACTER VARYING(20) NOT NULL,
  "DESCRIPTION" CHARACTER VARYING(255) NULL,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_LU_TRANSFER_STATUS" ON "L_LU_TRANSFER_STATUS"
  ("STATUS_ID" ASC);
ALTER TABLE "L_LU_TRANSFER_STATUS" ADD CONSTRAINT "L_PK_LU_TRANSFER_STATUS"
  PRIMARY KEY ("STATUS_ID");
CREATE INDEX "L_XAK_LU_TRANSFER_STATUS" ON "L_LU_TRANSFER_STATUS"
  ("NAME" ASC);
ALTER TABLE "L_LU_TRANSFER_STATUS" ADD CONSTRAINT "L_AK_LU_TRANSFER_STATUS"
  UNIQUE ("NAME");


CREATE TABLE IF NOT EXISTS "L_TRANSFERS" (
  "TRANSFER_ID" SERIAL NOT NULL,
  "TRANSFER_UUID" CHARACTER VARYING(36) NOT NULL,
  "LEDGER" CHARACTER VARYING(1024) NOT NULL,
  "DEBIT_ACCOUNT_ID" INTEGER NOT NULL REFERENCES "L_ACCOUNTS" ("ACCOUNT_ID"),
  "CREDIT_ACCOUNT_ID" INTEGER NOT NULL REFERENCES "L_ACCOUNTS" ("ACCOUNT_ID"),
  "AMOUNT" DECIMAL(32,16) DEFAULT 0 NOT NULL,
  "MEMO" CHARACTER VARYING(4000) NULL,
  "STATUS_ID" INTEGER NOT NULL REFERENCES "L_LU_TRANSFER_STATUS" ("STATUS_ID"),
  "REJECTION_REASON_ID" INTEGER NULL
    REFERENCES "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID"),
  "ADDITIONAL_INFO" CHARACTER VARYING(4000) NULL,
  "EXECUTION_CONDITION" CHARACTER VARYING(4000) NULL,
  "CANCELLATION_CONDITION" CHARACTER VARYING(4000) NULL,
  "EXPIRES_DTTM" TIMESTAMP WITH TIME ZONE NULL,
  "PROPOSED_DTTM" TIMESTAMP WITH TIME ZONE NULL,
  "PREPARED_DTTM" TIMESTAMP WITH TIME ZONE NULL,
  "EXECUTED_DTTM" TIMESTAMP WITH TIME ZONE NULL,
  "REJECTED_DTTM" TIMESTAMP WITH TIME ZONE NULL,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_TRANSFERS" ON "L_TRANSFERS"
  ("TRANSFER_ID" ASC);
ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT "L_PK_TRANSFERS" PRIMARY KEY
  ("TRANSFER_ID");
CREATE INDEX "L_XAK_TRANSFERS_EXECUTION_CONDITION" ON "L_TRANSFERS"
   ("EXECUTION_CONDITION" ASC);
CREATE INDEX "L_XAK_TRANSFERS" ON "L_TRANSFERS"
  ("TRANSFER_UUID" ASC);
ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT "L_AK_TRANSFERS" UNIQUE
  ("TRANSFER_UUID");
CREATE INDEX "L_XIF_TRANSFERS_STATE" ON "L_TRANSFERS"
  ("STATUS_ID" ASC);
CREATE INDEX "L_XIF_TRANSFERS_REASON" ON "L_TRANSFERS"
  ("REJECTION_REASON_ID" ASC);

CREATE TABLE IF NOT EXISTS "L_ENTRIES" (
  "ENTRY_ID" SERIAL NOT NULL,
  "TRANSFER_ID" INTEGER NOT NULL REFERENCES "L_TRANSFERS" ("TRANSFER_ID"),
  "ACCOUNT_ID" INTEGER NOT NULL,
  "CREATED_DTTM" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_ENTRIES" ON "L_ENTRIES"
  ("ENTRY_ID" ASC);
ALTER TABLE "L_ENTRIES" ADD CONSTRAINT "L_PK_ENTRIES" PRIMARY KEY
  ("ENTRY_ID");
CREATE INDEX "L_XIF_ENTRIES_ACCOUNT" ON "L_ENTRIES"
  ("ACCOUNT_ID" ASC);
CREATE INDEX "L_XIF_ENTRIES_TRANSFER" ON "L_ENTRIES"
  ("TRANSFER_ID" ASC);
CREATE INDEX "L_XIE_ENTRIES_CREATED_DTTM" ON "L_ENTRIES"
  ("CREATED_DTTM" ASC);


CREATE TABLE IF NOT EXISTS "L_FULFILLMENTS" (
  "FULFILLMENT_ID" SERIAL NOT NULL,
  "TRANSFER_ID" INTEGER NOT NULL REFERENCES "L_TRANSFERS" ("TRANSFER_ID"),
  "CONDITION_FULFILLMENT" CHARACTER VARYING(4000) NOT NULL,
  "DB_CREATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  "DB_UPDATED_USER" CHARACTER VARYING(40) DEFAULT CURRENT_USER NOT NULL
);

CREATE INDEX "L_XPK_FULFILLMENTS" ON "L_FULFILLMENTS"
  ("FULFILLMENT_ID" ASC);
ALTER TABLE "L_FULFILLMENTS" ADD CONSTRAINT "PK_FULFILLMENTS" PRIMARY KEY
  ("FULFILLMENT_ID");
CREATE UNIQUE INDEX "L_XIF_FULFILLMENTS" ON "L_FULFILLMENTS"
  ("TRANSFER_ID" ASC);


CREATE OR REPLACE FUNCTION SYNC_LDB_CREATED_DTTM()
RETURNS TRIGGER AS $$
BEGIN
   IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
      NEW."DB_CREATED_DTTM" = now();
      RETURN NEW;
   ELSE
      RETURN OLD;
   END IF;
END;
$$ language 'plpgsql';


CREATE TRIGGER "L_ACCOUNTS" BEFORE UPDATE ON "L_ACCOUNTS"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();

CREATE TRIGGER "L_LU_REJECTION_REASON" BEFORE UPDATE ON "L_LU_REJECTION_REASON"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();

CREATE TRIGGER "L_LU_TRANSFER_STATUS" BEFORE UPDATE ON "L_LU_TRANSFER_STATUS"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();

CREATE TRIGGER "L_ENTRIES" BEFORE UPDATE ON "L_ENTRIES"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();

CREATE TRIGGER "L_FULFILLMENTS" BEFORE UPDATE ON "L_FULFILLMENTS"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();

CREATE TRIGGER "L_TRANSFERS" BEFORE UPDATE ON "L_TRANSFERS"
  FOR EACH ROW EXECUTE PROCEDURE SYNC_LDB_CREATED_DTTM();


INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (0, 'cancelled', 'The transfer was cancelled');
INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (1, 'expired', 'The transfer expired automatically');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (1, 'prepared');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (2, 'executed');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (3, 'rejected');
