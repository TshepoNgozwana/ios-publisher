-- Enable RLS on sensitive tables
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE athletes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Parents: owner only
CREATE POLICY parents_owner_select ON parents
  FOR SELECT USING (owner = auth.uid());

CREATE POLICY parents_owner_update ON parents
  FOR UPDATE USING (owner = auth.uid())
  WITH CHECK (owner = auth.uid());

CREATE POLICY parents_owner_insert ON parents
  FOR INSERT WITH CHECK (owner = auth.uid());

-- Athletes: owner or service_role
CREATE POLICY athletes_owner_select ON athletes
  FOR SELECT USING (owner = auth.uid() OR auth.role() = 'service_role');

CREATE POLICY athletes_owner_update ON athletes
  FOR UPDATE USING (owner = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (owner = auth.uid() OR auth.role() = 'service_role');

CREATE POLICY athletes_owner_insert ON athletes
  FOR INSERT WITH CHECK (owner = auth.uid() OR auth.role() = 'service_role');

-- Bookings: team/ school-based management or service_role
CREATE POLICY bookings_school_manage ON bookings
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM teams t WHERE t.id = bookings.team_id AND t.school_id IN (
        SELECT school_id FROM parents WHERE owner = auth.uid()
      )
    ) OR auth.role() = 'service_role'
  );

-- Access logs: only service_role read
CREATE POLICY access_logs_service_read ON access_logs
  FOR SELECT USING (auth.role() = 'service_role');
