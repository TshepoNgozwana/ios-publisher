-- Enable pgcrypto (required for symmetric encryption)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Audit table
CREATE TABLE IF NOT EXISTS audit_logs (
  id bigserial PRIMARY KEY,
  ts timestamptz NOT NULL DEFAULT now(),
  actor uuid NULL,                -- supabase auth uid (if available)
  action text NOT NULL,           -- insert/update/delete
  table_name text NOT NULL,
  row_id text NULL,
  details jsonb NULL
);

-- Core schema
CREATE TABLE IF NOT EXISTS schools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS parents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner uuid REFERENCES auth.users (id) ON DELETE SET NULL,
  full_name text NOT NULL,
  email text,
  phone text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS athletes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner uuid REFERENCES auth.users (id) ON DELETE SET NULL,
  school_id uuid REFERENCES schools (id) ON DELETE SET NULL,
  full_name text NOT NULL,
  -- Encrypted sensitive fields (store ciphertext)
  id_number bytea,
  birthdate_encrypted bytea,
  medical_info_encrypted bytea,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS umpires (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  phone text,
  email text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  school_id uuid REFERENCES schools (id),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid REFERENCES teams (id),
  venue text,
  start timestamptz,
  "end" timestamptz,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid REFERENCES schools (id),
  plan text,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS access_logs (
  id bigserial PRIMARY KEY,
  ts timestamptz DEFAULT now(),
  actor uuid NULL,
  action text,
  resource text,
  ip inet NULL,
  meta jsonb
);

-- Convenience function to write audits via trigger
CREATE OR REPLACE FUNCTION public.log_audit() RETURNS TRIGGER AS $$
DECLARE
  payload jsonb;
  r_id text;
BEGIN
  IF (TG_OP = 'DELETE') THEN
    payload := to_jsonb(OLD);
    r_id := OLD.id::text;
  ELSE
    payload := to_jsonb(NEW);
    r_id := NEW.id::text;
  END IF;

  -- remove decrypted sensitive fields if present (we store ciphertext fields only)
  payload = payload - 'id_number' - 'medical_info' - 'birthdate';

  INSERT INTO audit_logs (actor, action, table_name, row_id, details)
  VALUES (
    current_setting('request.jwt.claims.sub', true)::uuid,
    TG_OP,
    TG_TABLE_NAME,
    r_id,
    payload
  );

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach audit trigger to sensitive tables
DO $$
DECLARE
  tbl text;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['parents','athletes','teams','bookings','subscriptions','access_logs']) LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%1$s ON %1$s;', tbl);
    EXECUTE format('CREATE TRIGGER trg_audit_%1$s AFTER INSERT OR UPDATE OR DELETE ON %1$s FOR EACH ROW EXECUTE FUNCTION public.log_audit();', tbl);
  END LOOP;
END;
$$;
