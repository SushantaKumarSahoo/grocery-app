-- ============================================
-- BulkMart Customer Mobile App Schema — v2
-- Adds map pin-point support to saved addresses.
-- Run this in your Supabase SQL Editor AFTER mobile_app_schema.sql.
-- Safe to re-run (all statements are idempotent).
-- ============================================

ALTER TABLE addresses ADD COLUMN IF NOT EXISTS house_details TEXT DEFAULT '';
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
