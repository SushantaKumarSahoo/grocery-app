import { useEffect, useState } from 'react';
import { Search, Eye, ShoppingCart, Calendar, MapPin, Users as UsersIcon, X, Send, MessageCircle, ArrowRight, Ban, Wallet } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import {
  fetchOrders, fetchOrderItems, updateOrderStatus, fetchOrderPaymentSummary,
  fetchOrderSupportTicket, fetchSupportMessages, sendSupportMessage,
} from '../../lib/api';
import EmptyState from '../../components/EmptyState';

const STATUS_TABS = ['all', 'pending', 'quotation_sent', 'accepted', 'preparing', 'ready', 'delivered', 'cancelled'];
const STATUS_COLORS: Record<string, string> = {
  pending: 'badge-warning', quotation_sent: 'badge-primary', accepted: 'badge-success',
  preparing: 'badge-primary', ready: 'badge-success', delivered: 'badge-success', cancelled: 'badge-error',
};

const PAYMENT_METHOD_LABELS: Record<string, string> = {
  advance_online: 'Paid Online',
  cod_cash: 'Cash on Delivery',
  cod_cheque: 'Cheque on Delivery',
};

// The negotiation stages (pending -> quotation_sent -> accepted/cancelled)
// are driven entirely by real events — building a quotation, or the
// customer accepting/rejecting it in the app. Two of the fulfillment
// transitions are ALSO event-driven now, not manual: accepted->preparing
// fires the moment the customer resolves the advance payment step (paid
// online, or chose cash/cheque), and ready->delivered fires the same way
// for the final payment. preparing->ready stays a manual click — the shop
// still has to actually finish preparing the order.
const FULFILLMENT_NEXT: Record<string, { next: string; label: string } | undefined> = {
  preparing: { next: 'ready', label: 'Mark Ready' },
};

function statusNote(order: any): string | null {
  switch (order.status) {
    case 'pending':
      return 'Build a quotation from the Quotations page to move this forward.';
    case 'quotation_sent':
      return 'Waiting for the customer to accept the quotation in the app.';
    case 'accepted':
      return "Waiting for the customer to choose how to pay the advance in the app — moves to Preparing automatically once they do.";
    case 'preparing':
      return order.payment_method
        ? `Moved to Preparing automatically — advance ${(PAYMENT_METHOD_LABELS[order.payment_method] || 'payment').toLowerCase()} confirmed.`
        : null;
    case 'ready':
      return 'Waiting for the customer to complete the final payment in the app — moves to Delivered automatically once they do.';
    case 'delivered':
      return order.payment_status === 'paid'
        ? 'Moved to Delivered automatically once the final payment was confirmed.'
        : null;
    default:
      return null;
  }
}

export default function Orders() {
  const { shop } = useShop();
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState('all');
  const [viewOrder, setViewOrder] = useState<any>(null);
  const [orderItems, setOrderItems] = useState<any[]>([]);
  const [paymentSummary, setPaymentSummary] = useState<any>(null);
  const [ticket, setTicket] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [messagesLoading, setMessagesLoading] = useState(false);
  const [reply, setReply] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => { if (shop) load(); }, [shop]);

  async function load() {
    setLoading(true);
    try { setOrders(await fetchOrders(shop.id)); } catch { /* */ }
    setLoading(false);
  }

  async function openDetail(order: any) {
    setViewOrder(order);
    setTicket(null);
    setMessages([]);
    setPaymentSummary(null);
    try { setOrderItems(await fetchOrderItems(order.id)); } catch { setOrderItems([]); }
    try { setPaymentSummary(await fetchOrderPaymentSummary(order.id)); } catch { /* no accepted quotation yet */ }
    setMessagesLoading(true);
    try {
      const t = await fetchOrderSupportTicket(order.id);
      setTicket(t);
      if (t) setMessages(await fetchSupportMessages(t.id));
    } catch { /* no chat for this order yet */ }
    setMessagesLoading(false);
  }

  async function handleSendReply() {
    if (!ticket || !reply.trim()) return;
    setSending(true);
    try {
      const msg = await sendSupportMessage(ticket.id, reply.trim(), shop?.name || 'Shop', 'shop_admin');
      setMessages([...messages, msg]);
      setReply('');
    } catch (e: any) {
      alert('Failed to send reply: ' + e.message);
    }
    setSending(false);
  }

  async function changeStatus(orderId: string, status: string) {
    await updateOrderStatus(orderId, status);
    await load();
    if (viewOrder?.id === orderId) setViewOrder({ ...viewOrder, status });
  }

  const filtered = orders.filter(o => {
    const matchSearch = (o.customer_name || '').toLowerCase().includes(search.toLowerCase()) || (o.order_number || '').includes(search);
    const matchTab = activeTab === 'all' || o.status === activeTab;
    return matchSearch && matchTab;
  });

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-2xl font-bold">Bulk Orders</h2>
        <p className="text-text-muted text-sm">View and manage customer bulk order requests</p>
      </div>

      {/* Status Tabs */}
      <div className="flex gap-1 overflow-x-auto pb-1">
        {STATUS_TABS.map(tab => (
          <button key={tab} onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${activeTab === tab ? 'bg-primary text-white' : 'bg-bg-hover text-text-muted hover:text-text-main'}`}>
            {tab === 'all' ? 'All' : tab.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
            {tab !== 'all' && <span className="ml-1 text-xs">({orders.filter(o => o.status === tab).length})</span>}
          </button>
        ))}
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by customer or order #" className="input-field w-full pl-9" />
      </div>

      {/* Orders Table */}
      {loading ? (
        <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr><th>Order</th><th>Customer</th><th>Occasion</th><th>Event Date</th><th>Amount</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {filtered.map(o => (
                <tr key={o.id}>
                  <td className="font-medium">#{o.order_number || o.id?.slice(0, 8)}</td>
                  <td>
                    <div>
                      <p className="font-medium">{o.customer_name || 'Unknown'}</p>
                      <p className="text-xs text-text-muted">{o.customer_phone || o.customer_email}</p>
                    </div>
                  </td>
                  <td>{o.occasion || '—'}</td>
                  <td>{o.event_date ? new Date(o.event_date).toLocaleDateString('en-IN') : '—'}</td>
                  <td className="font-semibold">₹{(o.total_amount || 0).toLocaleString('en-IN')}</td>
                  <td><span className={`badge ${STATUS_COLORS[o.status] || 'badge-primary'}`}>{o.status}</span></td>
                  <td>
                    <button onClick={() => openDetail(o)} className="p-2 hover:bg-bg-hover rounded transition-colors text-text-muted hover:text-primary"><Eye size={16} /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState icon={<ShoppingCart size={32} />} title="No orders yet" description="Customer bulk order requests will appear here." />
      )}

      {/* Order Detail Modal */}
      {viewOrder && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setViewOrder(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <h3 className="text-lg font-semibold">Order #{viewOrder.order_number || viewOrder.id?.slice(0, 8)}</h3>
              <button onClick={() => setViewOrder(null)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5 space-y-6">
              {/* Event Details */}
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2 text-sm"><Calendar size={16} className="text-text-muted" /><span><strong>Event:</strong> {viewOrder.occasion || '—'}</span></div>
                <div className="flex items-center gap-2 text-sm"><Calendar size={16} className="text-text-muted" /><span><strong>Date:</strong> {viewOrder.event_date ? new Date(viewOrder.event_date).toLocaleDateString('en-IN') : '—'}</span></div>
                <div className="flex items-center gap-2 text-sm"><UsersIcon size={16} className="text-text-muted" /><span><strong>Guests:</strong> {viewOrder.expected_guests || '—'}</span></div>
                <div className="flex items-center gap-2 text-sm"><MapPin size={16} className="text-text-muted" /><span><strong>Delivery:</strong> {viewOrder.delivery_address || '—'}</span></div>
              </div>
              {viewOrder.additional_notes && (
                <div className="p-3 bg-bg-hover rounded-md text-sm"><strong>Notes:</strong> {viewOrder.additional_notes}</div>
              )}

              {/* Items */}
              <div>
                <h4 className="font-semibold mb-3">Order Items</h4>
                {orderItems.length > 0 ? (
                  <div className="table-container">
                    <table className="table">
                      <thead><tr><th>Product</th><th>Qty</th><th>Unit</th><th>Price</th><th>Total</th></tr></thead>
                      <tbody>
                        {orderItems.map(item => (
                          <tr key={item.id}>
                            <td>{item.product_name}</td><td>{item.quantity}</td><td>{item.unit}</td>
                            <td>₹{item.price_per_unit}</td><td className="font-semibold">₹{item.total_price}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : <p className="text-sm text-text-muted">No items in this order yet.</p>}
              </div>

              {/* Status Actions — forward-only, event-driven */}
              <div>
                <h4 className="font-semibold mb-3">Order Progress</h4>
                <div className="flex items-center gap-2 mb-3">
                  <span className={`badge ${STATUS_COLORS[viewOrder.status] || 'badge-primary'}`}>
                    {viewOrder.status.replace('_', ' ')}
                  </span>
                  {statusNote(viewOrder) && (
                    <span className="text-xs text-text-muted">{statusNote(viewOrder)}</span>
                  )}
                </div>
                {(['accepted', 'preparing', 'ready', 'delivered', 'cancelled'].includes(viewOrder.status) || viewOrder.payment_method) && (
                  <div className="mb-3 p-3 bg-bg-hover rounded-md flex items-start gap-3 text-sm">
                    <Wallet size={16} className="text-text-muted shrink-0 mt-0.5" />
                    <div className="flex-1">
                      <p className="flex items-center gap-2">
                        <span className="font-medium">
                          {viewOrder.payment_method ? PAYMENT_METHOD_LABELS[viewOrder.payment_method] || viewOrder.payment_method : 'Payment method not chosen yet'}
                        </span>
                        {viewOrder.payment_status && viewOrder.payment_status !== 'not_required' && (
                          <span className={`badge ${
                            viewOrder.payment_status === 'paid' ? 'badge-success'
                            : viewOrder.payment_status === 'failed' ? 'badge-error'
                            : 'badge-warning'
                          }`}>
                            {viewOrder.payment_status}
                          </span>
                        )}
                      </p>
                      {paymentSummary && (
                        <p className="text-xs text-text-muted mt-1">
                          ₹{(paymentSummary.total_paid || 0).toLocaleString('en-IN')} paid of ₹{(paymentSummary.grand_total || 0).toLocaleString('en-IN')}
                          {paymentSummary.remaining_amount > 0 && ` · ₹${paymentSummary.remaining_amount.toLocaleString('en-IN')} remaining`}
                        </p>
                      )}
                    </div>
                  </div>
                )}
                <div className="flex flex-wrap gap-2">
                  {FULFILLMENT_NEXT[viewOrder.status] && (
                    <button
                      onClick={() => changeStatus(viewOrder.id, FULFILLMENT_NEXT[viewOrder.status]!.next)}
                      className="btn btn-primary text-xs"
                    >
                      {FULFILLMENT_NEXT[viewOrder.status]!.label} <ArrowRight size={14} />
                    </button>
                  )}
                  {viewOrder.status !== 'delivered' && viewOrder.status !== 'cancelled' && (
                    <button
                      onClick={() => {
                        if (confirm('Cancel this order? This cannot be undone.')) {
                          changeStatus(viewOrder.id, 'cancelled');
                        }
                      }}
                      className="btn btn-outline text-xs text-error hover:bg-error-bg hover:border-error"
                    >
                      <Ban size={14} /> Cancel Order
                    </button>
                  )}
                </div>
              </div>

              {/* Customer Chat */}
              <div>
                <h4 className="font-semibold mb-3 flex items-center gap-2"><MessageCircle size={16} /> Customer Chat</h4>
                {messagesLoading ? (
                  <div className="space-y-2">{[1, 2].map(i => <div key={i} className="h-12 bg-bg-hover rounded-md animate-pulse" />)}</div>
                ) : !ticket ? (
                  <p className="text-sm text-text-muted p-3 bg-bg-hover rounded-md">
                    The customer hasn't started a chat about this order yet.
                  </p>
                ) : (
                  <div className="border border-border rounded-lg flex flex-col">
                    <div className="max-h-64 overflow-y-auto p-3 space-y-2">
                      {messages.length === 0 ? (
                        <p className="text-sm text-text-muted text-center py-4">No messages yet.</p>
                      ) : (
                        messages.map(m => (
                          <div key={m.id} className={`flex ${m.sender_type === 'shop_admin' ? 'justify-end' : 'justify-start'}`}>
                            <div className={`max-w-[80%] rounded-lg px-3 py-2 text-sm ${
                              m.sender_type === 'shop_admin' ? 'bg-primary text-white' : 'bg-bg-hover'
                            }`}>
                              {m.sender_type !== 'shop_admin' && (
                                <p className="text-xs font-semibold opacity-70 mb-0.5">{m.sender_name || 'Customer'}</p>
                              )}
                              <p>{m.message}</p>
                              <p className={`text-[10px] mt-1 ${m.sender_type === 'shop_admin' ? 'text-white/70' : 'text-text-muted'}`}>
                                {new Date(m.created_at).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}
                              </p>
                            </div>
                          </div>
                        ))
                      )}
                    </div>
                    <div className="p-2 border-t border-border flex gap-2">
                      <input
                        value={reply}
                        onChange={e => setReply(e.target.value)}
                        onKeyDown={e => e.key === 'Enter' && handleSendReply()}
                        placeholder="Reply to customer..."
                        className="input-field flex-1 text-sm"
                      />
                      <button onClick={handleSendReply} disabled={sending || !reply.trim()} className="btn btn-primary text-sm px-3">
                        <Send size={14} />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
