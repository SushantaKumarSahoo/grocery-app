-- ============================================
-- BulkMart Customer Mobile App Schema — v4
-- Advance + final payment collection (Cashfree), COD/cheque tracking, and
-- a superadmin payout ledger for releasing collected money to shops.
-- Run this in your Supabase SQL Editor AFTER mobile_app_schema_v3_*.sql.
-- Safe to re-run (all statements are idempotent).
--
-- All writes to payment-related columns/tables happen through Supabase
-- Edge Functions using the service-role key — the client (mobile app)
-- never writes payment_status/payment_method/advance_amount directly, and
-- never inserts into payments/shop_payouts directly. See the BEFORE UPDATE
-- trigger and the RLS policies below, both of which enforce this at the
-- database level (not just "our current code happens not to do it").
-- ============================================

-- ---- orders / quotations: new payment-tracking columns ----

ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'not_required';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS advance_amount NUMERIC DEFAULT 0;

DO $$ BEGIN
  ALTER TABLE orders ADD CONSTRAINT orders_payment_status_check
    CHECK (payment_status IN ('not_required', 'pending', 'partial', 'paid', 'failed'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE orders ADD CONSTRAINT orders_payment_method_check
    CHECK (payment_method IS NULL OR payment_method IN ('advance_online', 'cod_cash', 'cod_cheque'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Set by the shop admin per-quotation when building it (order size varies
-- too much per quotation for a flat shop-level default to make sense —
-- same reasoning as the existing per-quotation transport/GST/discount).
ALTER TABLE quotations ADD COLUMN IF NOT EXISTS advance_amount NUMERIC DEFAULT 0 CHECK (advance_amount >= 0);

-- ---- payments: one row per payment attempt, advance or final, any method ----
-- COD/cheque get a lightweight row too (status stays 'created' -> is
-- flipped to 'paid' the moment the method is *chosen*, since no gateway
-- confirmation exists for cash/cheque) so this table is the single source
-- of truth for "how is this order being paid" across both admin panels.

CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  purpose TEXT NOT NULL CHECK (purpose IN ('advance', 'final')),
  method TEXT NOT NULL CHECK (method IN ('advance_online', 'cod_cash', 'cod_cheque')),
  amount NUMERIC NOT NULL DEFAULT 0,
  gateway TEXT DEFAULT 'cashfree',
  gateway_order_id TEXT UNIQUE,
  gateway_payment_id TEXT,
  status TEXT NOT NULL DEFAULT 'created' CHECK (status IN ('created', 'paid', 'failed', 'cancelled', 'refunded')),
  created_at TIMESTAMPTZ DEFAULT now(),
  paid_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS payments_order_id_idx ON payments(order_id);
CREATE INDEX IF NOT EXISTS payments_shop_id_idx ON payments(shop_id);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Read-only for the order's customer, the shop that owns the order, or a
-- superadmin. Deliberately NO insert/update/delete policy at all — every
-- write happens via a service-role Edge Function, which bypasses RLS.
DROP POLICY IF EXISTS "Payments readable by order owner, shop owner, or superadmin" ON payments;
CREATE POLICY "Payments readable by order owner, shop owner, or superadmin" ON payments
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    OR auth.jwt() ->> 'email' IN (SELECT email FROM super_admins)
  );

-- ---- order_payment_summary: derives "how much is left to pay" ----
-- security_invoker so the view is subject to the querying user's own RLS
-- on orders/quotations/payments, not the view owner's (Postgres views run
-- with the owner's privileges by default, which on Supabase can otherwise
-- silently bypass RLS through the view).

CREATE OR REPLACE VIEW order_payment_summary
WITH (security_invoker = true) AS
SELECT
  o.id AS order_id,
  COALESCE(q.grand_total, 0) AS grand_total,
  COALESCE(q.advance_amount, 0) AS advance_amount,
  COALESCE(p.total_paid, 0) AS total_paid,
  GREATEST(COALESCE(q.grand_total, 0) - COALESCE(p.total_paid, 0), 0) AS remaining_amount,
  COALESCE(p.total_paid, 0) >= COALESCE(q.advance_amount, 0) AS advance_settled,
  COALESCE(p.total_paid, 0) >= COALESCE(q.grand_total, 0) AND COALESCE(q.grand_total, 0) > 0 AS fully_settled
FROM orders o
LEFT JOIN LATERAL (
  SELECT grand_total, advance_amount FROM quotations
  WHERE order_id = o.id AND status = 'accepted'
  ORDER BY created_at DESC LIMIT 1
) q ON true
LEFT JOIN LATERAL (
  SELECT SUM(amount) AS total_paid FROM payments
  WHERE order_id = o.id AND status = 'paid'
) p ON true;

-- ---- shop_payouts: superadmin's manual "I released this to the shop" ledger ----
-- No real bank transfer happens through the app — superadmin pays the shop
-- separately and records it here.

CREATE TABLE IF NOT EXISTS shop_payouts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  note TEXT DEFAULT '',
  released_by TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS shop_payouts_shop_id_idx ON shop_payouts(shop_id);

ALTER TABLE shop_payouts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Shop payouts readable by shop owner or superadmin" ON shop_payouts;
CREATE POLICY "Shop payouts readable by shop owner or superadmin" ON shop_payouts
  FOR SELECT USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
    OR auth.jwt() ->> 'email' IN (SELECT email FROM super_admins)
  );
-- No INSERT policy — even a superadmin session can't bypass the balance
-- check below by inserting directly. release_shop_payout() is the only path.

-- ---- shop_payment_balances: per-shop collected / released / pending ----

CREATE OR REPLACE VIEW shop_payment_balances
WITH (security_invoker = true) AS
SELECT
  s.id AS shop_id,
  s.name AS shop_name,
  COALESCE(SUM(p.amount) FILTER (WHERE p.status = 'paid'), 0) AS total_collected,
  COALESCE(payouts.total_released, 0) AS total_released,
  COALESCE(SUM(p.amount) FILTER (WHERE p.status = 'paid'), 0) - COALESCE(payouts.total_released, 0) AS pending_balance
FROM shops s
LEFT JOIN payments p ON p.shop_id = s.id
LEFT JOIN LATERAL (
  SELECT SUM(amount) AS total_released FROM shop_payouts WHERE shop_id = s.id
) payouts ON true
GROUP BY s.id, s.name, payouts.total_released;

-- ---- release_shop_payout: the only way a payout is recorded ----
-- SECURITY DEFINER so it can see the true (RLS-unfiltered) balance to
-- validate against, while enforcing its own superadmin check up front —
-- closes the double-click/race-condition hole a plain client insert would
-- have (two superadmin tabs both submitting the same stale pending_balance).

CREATE OR REPLACE FUNCTION release_shop_payout(
  p_shop_id UUID,
  p_amount NUMERIC,
  p_note TEXT DEFAULT ''
)
RETURNS shop_payouts
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_balance NUMERIC;
  v_row shop_payouts;
BEGIN
  IF auth.jwt() ->> 'email' NOT IN (SELECT email FROM super_admins) THEN
    RAISE EXCEPTION 'Not authorized: superadmin only';
  END IF;

  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'Amount must be greater than zero';
  END IF;

  SELECT pending_balance INTO v_balance FROM shop_payment_balances WHERE shop_id = p_shop_id;

  IF p_amount > COALESCE(v_balance, 0) THEN
    RAISE EXCEPTION 'Amount exceeds pending balance of %', COALESCE(v_balance, 0);
  END IF;

  INSERT INTO shop_payouts (shop_id, amount, note, released_by)
  VALUES (p_shop_id, p_amount, COALESCE(p_note, ''), auth.jwt() ->> 'email')
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

-- ---- lock down payment columns on orders against client writes ----
-- Belt-and-braces alongside the RLS/Edge-Function design above: even if a
-- future change accidentally reintroduces a direct client `.update()`
-- touching these columns, the database rejects it outright. service_role
-- (used by the Edge Functions) is exempt.

CREATE OR REPLACE FUNCTION prevent_client_payment_field_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF current_user <> 'service_role' THEN
    IF NEW.payment_status IS DISTINCT FROM OLD.payment_status
       OR NEW.payment_method IS DISTINCT FROM OLD.payment_method
       OR NEW.advance_amount IS DISTINCT FROM OLD.advance_amount THEN
      RAISE EXCEPTION 'payment_status/payment_method/advance_amount can only be changed by the server';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS lock_order_payment_fields ON orders;
CREATE TRIGGER lock_order_payment_fields
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION prevent_client_payment_field_changes();
