-- ============================================
-- BulkMart Support Schema — v2
-- Routes order-related support to the specific shop instead of the
-- platform super admin. Run AFTER support_schema.sql.
-- Safe to re-run (all statements are idempotent).
-- ============================================

ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE SET NULL;
ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS order_id UUID REFERENCES orders(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_support_tickets_order_id ON support_tickets(order_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_shop_id ON support_tickets(shop_id);

-- Tickets: the customer who opened it, the owning shop's admin (when
-- shop_id is set), or the platform super admin.
DROP POLICY IF EXISTS "Tickets: customers manage their own, admins manage all" ON support_tickets;
DROP POLICY IF EXISTS "Tickets: customer, shop admin, or super admin" ON support_tickets;
CREATE POLICY "Tickets: customer, shop admin, or super admin" ON support_tickets
  FOR ALL USING (
    auth.uid() = user_id
    OR is_super_admin()
    OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
  ) WITH CHECK (
    auth.uid() = user_id
    OR is_super_admin()
    OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
  );

DROP POLICY IF EXISTS "Messages follow parent ticket access" ON support_messages;
CREATE POLICY "Messages follow parent ticket access" ON support_messages
  FOR ALL USING (
    is_super_admin() OR
    ticket_id IN (
      SELECT id FROM support_tickets
      WHERE user_id = auth.uid()
         OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    )
  ) WITH CHECK (
    is_super_admin() OR
    ticket_id IN (
      SELECT id FROM support_tickets
      WHERE user_id = auth.uid()
         OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    )
  );
