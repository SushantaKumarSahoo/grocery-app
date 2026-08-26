-- ============================================
-- BulkMart Customer Mobile App Schema — v3
-- Serviceable delivery PIN codes, managed by the super admin.
-- The mobile app checks the customer's PIN code against this table
-- right after login to decide whether bulk orders can be placed.
-- Run this in your Supabase SQL Editor AFTER mobile_app_schema.sql.
-- Safe to re-run (all statements are idempotent).
-- ============================================

CREATE TABLE IF NOT EXISTS serviceable_pincodes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  pincode TEXT UNIQUE NOT NULL,
  area_name TEXT DEFAULT '',
  city TEXT DEFAULT '',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE serviceable_pincodes ENABLE ROW LEVEL SECURITY;

-- Any authenticated user (mobile app + admin panels) can read the list,
-- so the app can check serviceability without needing a superadmin session.
DROP POLICY IF EXISTS "Serviceable pincodes readable by authenticated" ON serviceable_pincodes;
CREATE POLICY "Serviceable pincodes readable by authenticated" ON serviceable_pincodes
  FOR SELECT USING (auth.role() = 'authenticated');

-- Only super admins (matched the same way as elsewhere in this project —
-- by the JWT email against the super_admins table) can add/edit/remove
-- pincodes.
DROP POLICY IF EXISTS "Super admins manage serviceable pincodes" ON serviceable_pincodes;
CREATE POLICY "Super admins manage serviceable pincodes" ON serviceable_pincodes
  FOR ALL USING (
    auth.jwt() ->> 'email' IN (SELECT email FROM super_admins)
  ) WITH CHECK (
    auth.jwt() ->> 'email' IN (SELECT email FROM super_admins)
  );
