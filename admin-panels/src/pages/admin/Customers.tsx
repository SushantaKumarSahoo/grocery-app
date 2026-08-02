import { useEffect, useState } from 'react';
import { Search, Plus, Phone, Mail, User } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import { fetchCustomers, createCustomer } from '../../lib/api';
import EmptyState from '../../components/EmptyState';

export default function Customers() {
  const { shop } = useShop();
  const [customers, setCustomers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', phone: '', address: '' });

  useEffect(() => { if (shop) load(); }, [shop]);

  async function load() {
    setLoading(true);
    try { setCustomers(await fetchCustomers(shop.id)); } catch { /* */ }
    setLoading(false);
  }

  async function handleAdd() {
    if (!form.name) return;
    setSaving(true);
    try {
      await createCustomer({ ...form, shop_id: shop.id });
      setShowAdd(false);
      setForm({ name: '', email: '', phone: '', address: '' });
      await load();
    } catch (e: any) { alert(e.message); }
    setSaving(false);
  }

  const filtered = customers.filter(c => c.name.toLowerCase().includes(search.toLowerCase()) || (c.phone || '').includes(search));

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div><h2 className="text-2xl font-bold">Customers</h2><p className="text-text-muted text-sm">Manage your customer database</p></div>
        <button onClick={() => setShowAdd(true)} className="btn btn-primary"><Plus size={16} /> Add Customer</button>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or phone..." className="input-field w-full pl-9" />
      </div>

      {loading ? (
        <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map(c => (
            <div key={c.id} className="card hover:border-primary/20">
              <div className="flex items-start gap-3">
                <div className="w-12 h-12 rounded-full bg-primary-light flex items-center justify-center text-primary font-bold text-lg shrink-0">
                  {c.name?.charAt(0).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-text-main truncate">{c.name}</h3>
                  {c.phone && <div className="flex items-center gap-1 text-xs text-text-muted mt-1"><Phone size={12} />{c.phone}</div>}
                  {c.email && <div className="flex items-center gap-1 text-xs text-text-muted mt-0.5"><Mail size={12} />{c.email}</div>}
                  {c.address && <p className="text-xs text-text-muted mt-1 truncate">{c.address}</p>}
                </div>
              </div>
              <div className="flex items-center justify-between mt-4 pt-3 border-t border-border">
                <div className="text-xs text-text-muted">{c.total_orders || 0} orders</div>
                <div className="text-sm font-semibold text-primary">₹{(c.total_spent || 0).toLocaleString('en-IN')}</div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <EmptyState icon={<User size={32} />} title="No customers yet" description="Your customer list will grow as orders come in."
          action={<button onClick={() => setShowAdd(true)} className="btn btn-primary"><Plus size={16} /> Add Customer</button>} />
      )}

      {/* Add Customer Modal */}
      {showAdd && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setShowAdd(false)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-md" onClick={e => e.stopPropagation()}>
            <div className="p-5 border-b border-border"><h3 className="text-lg font-semibold">Add Customer</h3></div>
            <div className="p-5 space-y-4">
              <div className="input-group"><label className="input-label">Name *</label><input value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="input-field" placeholder="Full name" /></div>
              <div className="input-group"><label className="input-label">Phone</label><input value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} className="input-field" placeholder="+91..." /></div>
              <div className="input-group"><label className="input-label">Email</label><input value={form.email} onChange={e => setForm({...form, email: e.target.value})} className="input-field" placeholder="email@example.com" /></div>
              <div className="input-group"><label className="input-label">Address</label><textarea value={form.address} onChange={e => setForm({...form, address: e.target.value})} className="input-field" rows={2} /></div>
            </div>
            <div className="flex justify-end gap-2 p-5 border-t border-border">
              <button onClick={() => setShowAdd(false)} className="btn btn-outline">Cancel</button>
              <button onClick={handleAdd} disabled={saving} className="btn btn-primary">{saving ? 'Saving...' : 'Add Customer'}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
