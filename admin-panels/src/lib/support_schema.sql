-- ============================================
-- BulkMart Support Tickets Schema
-- Run this in your Supabase SQL Editor.
-- Safe to re-run (all statements are idempotent).
-- ============================================

CREATE TABLE IF NOT EXISTS support_tickets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  customer_name TEXT DEFAULT '',
  customer_email TEXT DEFAULT '',
  customer_phone TEXT DEFAULT '',
  subject TEXT NOT NULL DEFAULT 'General Support',
  status TEXT NOT NULL DEFAULT 'open', -- open | in_progress | resolved | closed
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS support_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ticket_id UUID REFERENCES support_tickets(id) ON DELETE CASCADE,
  sender_type TEXT NOT NULL DEFAULT 'customer', -- customer | super_admin
  sender_name TEXT DEFAULT '',
  message TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;

-- A super admin is anyone whose JWT email is listed in super_admins.
CREATE OR REPLACE FUNCTION is_super_admin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM super_admins WHERE email = (auth.jwt() ->> 'email')
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

DROP POLICY IF EXISTS "Tickets: customers manage their own, admins manage all" ON support_tickets;
CREATE POLICY "Tickets: customers manage their own, admins manage all" ON support_tickets
  FOR ALL USING (auth.uid() = user_id OR is_super_admin())
  WITH CHECK (auth.uid() = user_id OR is_super_admin());

DROP POLICY IF EXISTS "Messages follow parent ticket access" ON support_messages;
CREATE POLICY "Messages follow parent ticket access" ON support_messages
  FOR ALL USING (
    is_super_admin() OR
    ticket_id IN (SELECT id FROM support_tickets WHERE user_id = auth.uid())
  ) WITH CHECK (
    is_super_admin() OR
    ticket_id IN (SELECT id FROM support_tickets WHERE user_id = auth.uid())
  );

-- Keep ticket.updated_at fresh whenever a new message lands.
CREATE OR REPLACE FUNCTION touch_ticket_on_message() RETURNS TRIGGER AS $$
BEGIN
  UPDATE support_tickets SET updated_at = now() WHERE id = NEW.ticket_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_touch_ticket_on_message ON support_messages;
CREATE TRIGGER trg_touch_ticket_on_message
  AFTER INSERT ON support_messages
  FOR EACH ROW EXECUTE FUNCTION touch_ticket_on_message();

-- Enable realtime streaming for the mobile app's live chat view.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'support_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE support_messages;
  END IF;
END $$;
