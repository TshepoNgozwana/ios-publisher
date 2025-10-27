CREATE OR REPLACE FUNCTION public.log_access(actor uuid, action text, resource text, meta jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO access_logs (actor, action, resource, meta) VALUES (actor, action, resource, meta);
END;
$$ LANGUAGE plpgsql;
