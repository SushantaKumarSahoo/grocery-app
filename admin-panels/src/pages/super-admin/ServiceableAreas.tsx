import { useEffect, useState } from 'react';
import { MapPin, Plus, Trash2, Ban, CheckCircle } from 'lucide-react';
import {
  fetchServiceablePincodes,
  addServiceablePincode,
  updateServiceablePincode,
  deleteServiceablePincode,
} from '../../lib/api';
import EmptyState from '../../components/EmptyState';

const PINCODE_RE = /^[1-9][0-9]{5}$/;

export default function ServiceableAreas() {
  const [pincodes, setPincodes] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  const [pincode, setPincode] = useState('');
  const [areaName, setAreaName] = useState('');
  const [city, setCity] = useState('');
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    try { setPincodes(await fetchServiceablePincodes()); } catch { /* ignore */ }
    setLoading(false);
  }

  async function handleAdd(e: React.FormEvent) {
    e.preventDefault();
    setFormError('');
    const trimmed = pincode.trim();
    if (!PINCODE_RE.test(trimmed)) {
      setFormError('Enter a valid 6-digit PIN code.');
      return;
    }
    if (pincodes.some(p => p.pincode === trimmed)) {
      setFormError('This PIN code is already in the list.');
      return;
    }
    setSaving(true);
    try {
      const created = await addServiceablePincode({
        pincode: trimmed,
        area_name: areaName.trim(),
        city: city.trim(),
      });
      setPincodes([created, ...pincodes]);
      setPincode('');
      setAreaName('');
      setCity('');
    } catch (err: any) {
      setFormError(err.message || 'Could not add this PIN code.');
    }
    setSaving(false);
  }

  async function toggleActive(row: any) {
    try {
      const updated = await updateServiceablePincode(row.id, { is_active: !row.is_active });
      setPincodes(pincodes.map(p => p.id === row.id ? updated : p));
    } catch (e: any) {
      alert('Failed to update: ' + e.message);
    }
  }

  async function remove(row: any) {
    if (!confirm(`Remove ${row.pincode} from serviceable areas?`)) return;
    try {
      await deleteServiceablePincode(row.id);
      setPincodes(pincodes.filter(p => p.id !== row.id));
    } catch (e: any) {
      alert('Failed to remove: ' + e.message);
    }
  }

  const filtered = pincodes.filter(p => {
    const q = search.toLowerCase();
    return (
      p.pincode.includes(q) ||
      (p.area_name || '').toLowerCase().includes(q) ||
      (p.city || '').toLowerCase().includes(q)
    );
  });

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-2xl font-bold">Serviceable Areas</h2>
        <p className="text-text-muted text-sm">
          PIN codes listed here are where the mobile app allows customers to place bulk orders.
          The app checks a customer's location against this list right after they log in.
        </p>
      </div>

      <form onSubmit={handleAdd} className="card">
        <h3 className="text-lg font-semibold border-b border-border pb-3 mb-4">Add a PIN code</h3>
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 items-start">
          <div className="input-group mb-0">
            <label className="input-label">PIN Code *</label>
            <input
              value={pincode}
              onChange={e => setPincode(e.target.value.replace(/\D/g, '').slice(0, 6))}
              placeholder="751001"
              inputMode="numeric"
              className="input-field"
            />
          </div>
          <div className="input-group mb-0">
            <label className="input-label">Area</label>
            <input
              value={areaName}
              onChange={e => setAreaName(e.target.value)}
              placeholder="Saheed Nagar"
              className="input-field"
            />
          </div>
          <div className="input-group mb-0">
            <label className="input-label">City</label>
            <input
              value={city}
              onChange={e => setCity(e.target.value)}
              placeholder="Bhubaneswar"
              className="input-field"
            />
          </div>
          <button type="submit" disabled={saving} className="btn btn-primary mt-6 sm:mt-[26px]">
            <Plus size={16} /> {saving ? 'Adding...' : 'Add PIN Code'}
          </button>
        </div>
        {formError && <p className="text-error text-sm mt-3">{formError}</p>}
      </form>

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder="Search by PIN code, area or city..."
          className="input-field w-full sm:max-w-xs"
        />
        <p className="text-sm text-text-muted">{pincodes.filter(p => p.is_active).length} active of {pincodes.length}</p>
      </div>

      {loading ? (
        <div className="space-y-3">{[1, 2, 3].map(i => <div key={i} className="h-14 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>PIN Code</th>
                <th>Area</th>
                <th>City</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(row => (
                <tr key={row.id} className={!row.is_active ? 'opacity-60' : ''}>
                  <td className="font-semibold">{row.pincode}</td>
                  <td>{row.area_name || <span className="text-text-muted">—</span>}</td>
                  <td>{row.city || <span className="text-text-muted">—</span>}</td>
                  <td>
                    <span className={`badge ${row.is_active ? 'badge-success' : 'badge-warning'}`}>
                      {row.is_active ? 'Active' : 'Disabled'}
                    </span>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => toggleActive(row)}
                        className={`btn text-xs px-3 py-1.5 ${row.is_active ? 'btn-outline text-warning hover:bg-warning-bg hover:border-warning' : 'btn-primary'}`}
                      >
                        {row.is_active ? <><Ban size={14} /> Disable</> : <><CheckCircle size={14} /> Enable</>}
                      </button>
                      <button
                        onClick={() => remove(row)}
                        className="btn btn-outline text-xs px-3 py-1.5 text-error hover:bg-error-bg hover:border-error"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState
          icon={<MapPin size={32} />}
          title="No serviceable areas yet"
          description={search ? 'Try a different search.' : 'Add PIN codes above to start allowing bulk orders in those areas.'}
        />
      )}
    </div>
  );
}
