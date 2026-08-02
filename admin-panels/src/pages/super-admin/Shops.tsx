import { useEffect, useState } from 'react';
import { Search, Building2, Store, Ban, CheckCircle } from 'lucide-react';
import { fetchAllShops, updateShopStatus } from '../../lib/api';
import EmptyState from '../../components/EmptyState';

export default function Shops() {
  const [shops, setShops] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    try { setShops(await fetchAllShops()); } catch { /* ignore */ }
    setLoading(false);
  }

  async function toggleStatus(shopId: string, currentStatus: string) {
    const newStatus = currentStatus === 'active' ? 'blocked' : 'active';
    try {
      await updateShopStatus(shopId, newStatus);
      setShops(shops.map(s => s.id === shopId ? { ...s, status: newStatus } : s));
    } catch (e: any) {
      alert('Failed to update status: ' + e.message);
    }
  }

  const filtered = shops.filter(s => {
    const matchSearch = s.name.toLowerCase().includes(search.toLowerCase()) || (s.email || '').toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter === 'all' || s.status === statusFilter;
    return matchSearch && matchStatus;
  });

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold">Shop Management</h2>
          <p className="text-text-muted text-sm">Monitor and manage all registered shops on the platform</p>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or email..." className="input-field w-full pl-9" />
        </div>
        <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)} className="input-field">
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="blocked">Blocked</option>
        </select>
      </div>

      {loading ? (
        <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Shop</th>
                <th>Location</th>
                <th>Contact</th>
                <th>Revenue</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(shop => (
                <tr key={shop.id} className={shop.status === 'blocked' ? 'opacity-75' : ''}>
                  <td>
                    <div className="flex items-center gap-3">
                      {shop.logo_url ? (
                        <img src={shop.logo_url} alt={shop.name} className="w-10 h-10 rounded object-cover" />
                      ) : (
                        <div className="w-10 h-10 rounded bg-primary-light flex items-center justify-center text-primary"><Store size={18} /></div>
                      )}
                      <div>
                        <p className="font-medium">{shop.name}</p>
                        <p className="text-xs text-text-muted">Joined {new Date(shop.created_at).toLocaleDateString()}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    {shop.city || shop.state ? (
                      <p className="text-sm">{shop.city}{shop.city && shop.state ? ', ' : ''}{shop.state}</p>
                    ) : <span className="text-text-muted text-sm">—</span>}
                  </td>
                  <td>
                    <div className="flex flex-col gap-0.5 text-xs text-text-muted">
                      {shop.email && <span className="truncate max-w-[150px]" title={shop.email}>{shop.email}</span>}
                      {shop.phone && <span>{shop.phone}</span>}
                      {!shop.email && !shop.phone && <span>—</span>}
                    </div>
                  </td>
                  <td className="font-semibold text-primary">₹{(shop.revenue || 0).toLocaleString('en-IN')}</td>
                  <td>
                    <span className={`badge ${shop.status === 'active' ? 'badge-success' : 'badge-error'}`}>
                      {shop.status}
                    </span>
                  </td>
                  <td>
                    <button 
                      onClick={() => toggleStatus(shop.id, shop.status)}
                      className={`btn text-xs px-3 py-1.5 ${shop.status === 'active' ? 'btn-outline text-error hover:bg-error-bg hover:border-error' : 'btn-primary'}`}
                    >
                      {shop.status === 'active' ? <><Ban size={14} /> Block</> : <><CheckCircle size={14} /> Unblock</>}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState 
          icon={<Building2 size={32} />} 
          title="No shops found" 
          description={search || statusFilter !== 'all' ? 'Try adjusting your search or filters.' : 'No shops have registered on the platform yet.'} 
        />
      )}
    </div>
  );
}
