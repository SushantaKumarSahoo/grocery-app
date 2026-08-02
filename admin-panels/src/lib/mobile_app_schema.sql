-- ============================================
-- BulkMart Customer Mobile App Schema
-- Run this in your Supabase SQL Editor AFTER
-- database.sql and super_admin.sql have been run.
-- ============================================

-- Customer profiles (1:1 with auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  email TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Saved delivery addresses
CREATE TABLE IF NOT EXISTS addresses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  label TEXT NOT NULL DEFAULT 'Home',
  full_address TEXT NOT NULL DEFAULT '',
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Link orders / order_items to the customer's auth account
ALTER TABLE orders ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS packaging TEXT DEFAULT '';
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT '';

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- Profiles: a user can only see/edit their own profile
CREATE POLICY "Profiles are self-managed" ON profiles
  FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Addresses: a user can only see/edit their own addresses
CREATE POLICY "Addresses are self-managed" ON addresses
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ---- Tighten orders / order_items / quotations for customer access ----
-- (Existing "Allow all for authenticated" policies from database.sql already let
--  any authenticated user read/write everything; the policies below add proper
--  customer-scoped access. If you want to fully lock this down, drop the old
--  "Allow all for authenticated" policies on orders/order_items/quotations.)

DROP POLICY IF EXISTS "Allow all for authenticated" ON orders;
CREATE POLICY "Shop owners manage their shop orders" ON orders
  FOR ALL USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
  ) WITH CHECK (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
  );
CREATE POLICY "Customers manage their own orders" ON orders
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow all for authenticated" ON order_items;
CREATE POLICY "Order items follow parent order access" ON order_items
  FOR ALL USING (
    order_id IN (
      SELECT id FROM orders
      WHERE user_id = auth.uid()
         OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    )
  ) WITH CHECK (
    order_id IN (
      SELECT id FROM orders
      WHERE user_id = auth.uid()
         OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Allow all for authenticated" ON quotations;
CREATE POLICY "Quotations follow parent order access" ON quotations
  FOR ALL USING (
    order_id IN (
      SELECT id FROM orders
      WHERE user_id = auth.uid()
         OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    )
  ) WITH CHECK (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
  );

-- Products/categories/shops stay readable by any authenticated user (browsing catalog)
-- via the existing "Allow all for authenticated" policies from database.sql.
