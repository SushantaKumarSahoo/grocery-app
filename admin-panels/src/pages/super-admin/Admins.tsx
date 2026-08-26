import { useEffect, useState } from 'react';
import { Search, Shield, Mail, Phone } from 'lucide-react';
import { fetchAllAdmins } from '../../lib/api';
import EmptyState from '../../components/EmptyState';

export default function Admins() {
  const [admins, setAdmins] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    try { setAdmins(await fetchAllAdmins()); } catch { /* ignore */ }
    setLoading(false);
  }

  const filtered = admins.filter(a => {
    return (a.name || '').toLowerCase().includes(search.toLowerCase()) || 
           (a.email || '').toLowerCase().includes(search.toLowerCase());
  });

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold">Admin Management</h2>
          <p className="text-text-muted text-sm">View all shop owners and platform administrators</p>
        </div>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or email..." className="input-field w-full pl-9" />
      </div>

      {loading ? (
        <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {/* Shop Owners */}
          {filtered.map((admin, idx) => (
            <div key={idx} className="card hover:border-border/80">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-bg-hover flex items-center justify-center text-text-muted font-bold text-lg">
                    {(admin.name || 'U').charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <h3 className="font-semibold">{admin.name || 'Unknown User'}</h3>
                    {admin.email && <div className="flex items-center gap-1 text-xs text-text-muted mt-1"><Mail size={12} /> {admin.email}</div>}
                    {admin.phone && <div className="flex items-center gap-1 text-xs text-text-muted mt-0.5"><Phone size={12} /> {admin.phone}</div>}
                  </div>
                </div>
                <span className="badge badge-success text-xs">Shop Owner</span>
              </div>
              <div className="mt-4 pt-3 border-t border-border flex justify-between items-center text-xs text-text-muted">
                <span>Shop ID: {admin.owner_id ? admin.owner_id.slice(0, 8) : 'N/A'}</span>
                <span>{admin.city || 'No Location'}</span>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <EmptyState 
          icon={<Shield size={32} />} 
          title="No admins found" 
          description={search ? 'Try adjusting your search.' : 'No shop owners are registered yet.'} 
        />
      )}
    </div>
  );
}
