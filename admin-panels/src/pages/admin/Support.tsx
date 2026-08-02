import { useEffect, useState } from 'react';
import { Search, LifeBuoy, Send, X } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import {
  fetchShopSupportTickets,
  fetchSupportMessages,
  sendSupportMessage,
  updateTicketStatus,
} from '../../lib/api';
import EmptyState from '../../components/EmptyState';

const STATUS_TABS = ['all', 'open', 'in_progress', 'resolved', 'closed'];

const STATUS_LABEL: Record<string, string> = {
  open: 'Open',
  in_progress: 'In Progress',
  resolved: 'Resolved',
  closed: 'Closed',
};

const STATUS_BADGE: Record<string, string> = {
  open: 'badge-primary',
  in_progress: 'badge-warning',
  resolved: 'badge-success',
  closed: 'badge-error',
};

export default function Support() {
  const { shop } = useShop();
  const [tickets, setTickets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState('all');

  const [activeTicket, setActiveTicket] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [messagesLoading, setMessagesLoading] = useState(false);
  const [reply, setReply] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => { if (shop) load(); }, [shop]);

  async function load() {
    setLoading(true);
    try { setTickets(await fetchShopSupportTickets(shop.id)); } catch { /* ignore */ }
    setLoading(false);
  }

  async function openTicket(ticket: any) {
    setActiveTicket(ticket);
    setMessagesLoading(true);
    try { setMessages(await fetchSupportMessages(ticket.id)); } catch { /* ignore */ }
    setMessagesLoading(false);
  }

  async function handleSend() {
    if (!activeTicket || !reply.trim()) return;
    setSending(true);
    try {
      const msg = await sendSupportMessage(activeTicket.id, reply.trim(), shop?.name || 'Shop', 'shop_admin');
      setMessages([...messages, msg]);
      setReply('');
      if (activeTicket.status === 'open') {
        await handleStatusChange('in_progress', true);
      }
    } catch (e: any) {
      alert('Failed to send reply: ' + e.message);
    }
    setSending(false);
  }

  async function handleStatusChange(status: string, silent = false) {
    if (!activeTicket) return;
    try {
      const updated = await updateTicketStatus(activeTicket.id, status);
      setActiveTicket(updated);
      setTickets(tickets.map(t => t.id === updated.id ? updated : t));
    } catch (e: any) {
      if (!silent) alert('Failed to update status: ' + e.message);
    }
  }

  const filtered = tickets.filter(t => {
    const matchSearch =
      (t.customer_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (t.customer_email || '').toLowerCase().includes(search.toLowerCase()) ||
      (t.subject || '').toLowerCase().includes(search.toLowerCase());
    const matchTab = activeTab === 'all' || t.status === activeTab;
    return matchSearch && matchTab;
  });

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-2xl font-bold">Support</h2>
        <p className="text-text-muted text-sm">Order-related conversations started by customers from the app</p>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by customer, email, or order..."
            className="input-field w-full pl-9"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto">
          {STATUS_TABS.map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`btn text-xs px-3 py-1.5 whitespace-nowrap ${activeTab === tab ? 'btn-primary' : 'btn-outline'}`}
            >
              {tab === 'all' ? 'All' : STATUS_LABEL[tab]}
              {tab !== 'all' && (
                <span className="ml-1">({tickets.filter(t => t.status === tab).length})</span>
              )}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="space-y-3">{[1, 2, 3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Order</th>
                <th>Status</th>
                <th>Last Updated</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(t => (
                <tr key={t.id}>
                  <td>
                    <p className="font-medium">{t.customer_name || 'Customer'}</p>
                    <p className="text-xs text-text-muted">{t.customer_email}</p>
                  </td>
                  <td className="max-w-[220px] truncate" title={t.subject}>{t.subject}</td>
                  <td><span className={`badge ${STATUS_BADGE[t.status] || 'badge-primary'}`}>{STATUS_LABEL[t.status] || t.status}</span></td>
                  <td className="text-sm text-text-muted">{new Date(t.updated_at).toLocaleString('en-IN')}</td>
                  <td>
                    <button onClick={() => openTicket(t)} className="btn btn-outline text-xs px-3 py-1.5">
                      <LifeBuoy size={14} /> Open
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState
          icon={<LifeBuoy size={32} />}
          title="No support requests"
          description={search || activeTab !== 'all' ? 'Try adjusting your search or filters.' : 'When a customer taps "Chat with Shop" on an order in the app, it shows up here.'}
        />
      )}

      {activeTicket && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setActiveTicket(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-lg max-h-[85vh] flex flex-col" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <div>
                <h3 className="text-lg font-semibold">{activeTicket.subject}</h3>
                <p className="text-sm text-text-muted">
                  {activeTicket.customer_name || 'Customer'} • {activeTicket.customer_email}
                </p>
              </div>
              <button onClick={() => setActiveTicket(null)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>

            <div className="flex gap-2 px-5 pt-3">
              {['open', 'in_progress', 'resolved', 'closed'].map(s => (
                <button
                  key={s}
                  onClick={() => handleStatusChange(s)}
                  className={`btn text-xs px-3 py-1.5 ${activeTicket.status === s ? 'btn-primary' : 'btn-outline'}`}
                >
                  {STATUS_LABEL[s]}
                </button>
              ))}
            </div>

            <div className="flex-1 overflow-y-auto p-5 space-y-3">
              {messagesLoading ? (
                <div className="space-y-2">{[1, 2, 3].map(i => <div key={i} className="h-12 bg-bg-hover rounded-md animate-pulse" />)}</div>
              ) : messages.length === 0 ? (
                <p className="text-sm text-text-muted text-center py-8">No messages yet.</p>
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

            <div className="p-4 border-t border-border flex gap-2">
              <input
                value={reply}
                onChange={e => setReply(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleSend()}
                placeholder="Type a reply..."
                className="input-field flex-1"
              />
              <button onClick={handleSend} disabled={sending || !reply.trim()} className="btn btn-primary">
                <Send size={16} /> {sending ? 'Sending...' : 'Send'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
