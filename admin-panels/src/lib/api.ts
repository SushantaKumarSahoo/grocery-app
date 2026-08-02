import { supabase } from '../lib/supabase';

// Get or create the current user's shop
export async function getOrCreateShop() {
  if (!supabase) return null;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: existing } = await supabase
    .from('shops')
    .select('*')
    .eq('owner_id', user.id)
    .single();

  if (existing) return existing;

  const { data: created, error } = await supabase
    .from('shops')
    .insert({ owner_id: user.id, name: 'My Store', email: user.email || '' })
    .select()
    .single();

  if (error) { console.warn('Could not create shop:', error.message); return null; }
  return created;
}

// ---- PRODUCTS ----
export async function fetchProducts(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('products').select('*').eq('shop_id', shopId).order('created_at', { ascending: false });
  return data || [];
}

export async function createProduct(product: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('products').insert(product).select().single();
  if (error) throw error;
  return data;
}

export async function updateProduct(id: string, updates: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('products').update(updates).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

export async function deleteProduct(id: string) {
  if (!supabase) return;
  const { error } = await supabase.from('products').delete().eq('id', id);
  if (error) throw error;
}

// ---- CATEGORIES ----
export async function fetchCategories(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('categories').select('*').eq('shop_id', shopId).order('name');
  return data || [];
}

export async function createCategory(shopId: string, name: string) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('categories').insert({ shop_id: shopId, name }).select().single();
  if (error) throw error;
  return data;
}

export async function deleteCategory(id: string) {
  if (!supabase) return;
  await supabase.from('categories').delete().eq('id', id);
}

// ---- ORDERS ----
export async function fetchOrders(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('orders').select('*').eq('shop_id', shopId).order('created_at', { ascending: false });
  return data || [];
}

export async function fetchOrderItems(orderId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('order_items').select('*').eq('order_id', orderId);
  return data || [];
}

export async function updateOrderStatus(id: string, status: string) {
  if (!supabase) return;
  await supabase.from('orders').update({ status }).eq('id', id);
}

// ---- CUSTOMERS ----
export async function fetchCustomers(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('customers').select('*').eq('shop_id', shopId).order('created_at', { ascending: false });
  return data || [];
}

export async function createCustomer(customer: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('customers').insert(customer).select().single();
  if (error) throw error;
  return data;
}

// ---- QUOTATIONS ----
export async function fetchQuotations(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase.from('quotations').select('*, orders(*)').eq('shop_id', shopId).order('created_at', { ascending: false });
  return data || [];
}

// Sends a quotation and automatically moves the order into "quotation_sent"
// — order status is never hand-picked for this step, it's a direct
// consequence of sending the quote.
export async function createQuotation(quotation: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('quotations').insert(quotation).select().single();
  if (error) throw error;
  await supabase.from('orders').update({ status: 'quotation_sent' }).eq('id', quotation.order_id);
  return data;
}

export async function updateQuotation(id: string, updates: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('quotations').update(updates).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

// ---- SHOP PROFILE ----
export async function updateShopProfile(id: string, updates: any) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('shops').update(updates).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

// ============================================
// SUPER ADMIN FUNCTIONS
// ============================================

export async function fetchAllShops() {
  if (!supabase) return [];
  const { data } = await supabase.from('shops').select('*').order('created_at', { ascending: false });
  return data || [];
}

export async function updateShopStatus(shopId: string, status: string) {
  if (!supabase) return null;
  const { data, error } = await supabase.from('shops').update({ status }).eq('id', shopId).select().single();
  if (error) throw error;
  return data;
}

export async function fetchAllAdmins() {
  // We'll fetch all unique shop owners as "admins" for now
  if (!supabase) return [];
  const { data } = await supabase.from('shops').select('owner_id, name, email, phone, city, status');
  return data || [];
}

export async function checkIsSuperAdmin(email: string) {
  if (!supabase || !email) return false;
  try {
    const { data } = await supabase.from('super_admins').select('id').ilike('email', email).maybeSingle();
    return !!data;
  } catch {
    return false;
  }
}

// ---- SUPPORT ----
// Super admin only handles general/app-level tickets — order-related
// issues (shop_id set) are routed to that shop's own admin instead.
export async function fetchAllSupportTickets() {
  if (!supabase) return [];
  const { data } = await supabase
    .from('support_tickets')
    .select('*')
    .is('shop_id', null)
    .order('updated_at', { ascending: false });
  return data || [];
}

export async function fetchSupportMessages(ticketId: string) {
  if (!supabase) return [];
  const { data } = await supabase
    .from('support_messages')
    .select('*')
    .eq('ticket_id', ticketId)
    .order('created_at', { ascending: true });
  return data || [];
}

export async function sendSupportMessage(
  ticketId: string,
  message: string,
  senderName: string,
  senderType: 'super_admin' | 'shop_admin' = 'super_admin'
) {
  if (!supabase) return null;
  const { data, error } = await supabase
    .from('support_messages')
    .insert({ ticket_id: ticketId, message, sender_type: senderType, sender_name: senderName })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateTicketStatus(ticketId: string, status: string) {
  if (!supabase) return null;
  const { data, error } = await supabase
    .from('support_tickets')
    .update({ status })
    .eq('id', ticketId)
    .select()
    .single();
  if (error) throw error;
  return data;
}

// Order-scoped ticket for the shop admin's order detail chat panel.
export async function fetchOrderSupportTicket(orderId: string) {
  if (!supabase) return null;
  const { data } = await supabase
    .from('support_tickets')
    .select('*')
    .eq('order_id', orderId)
    .maybeSingle();
  return data;
}

// All order-related conversations for this shop, for the standalone
// "Support" page in the shop admin sidebar.
export async function fetchShopSupportTickets(shopId: string) {
  if (!supabase) return [];
  const { data } = await supabase
    .from('support_tickets')
    .select('*')
    .eq('shop_id', shopId)
    .order('updated_at', { ascending: false });
  return data || [];
}
