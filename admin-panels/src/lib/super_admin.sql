-- ============================================
-- Super Admin Table Setup
-- Run this in your Supabase SQL Editor
-- ============================================

-- Create the super_admins table
CREATE TABLE IF NOT EXISTS super_admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE super_admins ENABLE ROW LEVEL SECURITY;

-- Allow anyone authenticated to read the super_admins table
-- (Needed so the app can check if the logged-in user is a super admin)
CREATE POLICY "Allow all for authenticated" ON super_admins FOR SELECT USING (auth.role() = 'authenticated');

-- Insert your super admin email(s) here
-- Replace with the Google email you use to log in
INSERT INTO super_admins (email) 
VALUES 
  ('gasburry@gmail.com'),
  ('admin@bulkbasket.com')
ON CONFLICT (email) DO NOTHING;
