import { useEffect, useState } from 'react';
import { Wallet, Send, X, History, Landmark } from 'lucide-react';
import { fetchShopPaymentBalances, fetchAllShops, fetchShopPayouts, releaseShopPayout } from '../../lib/api';
import EmptyState from '../../components/EmptyState';

export default function Payments() {
  const [balances, setBalances] = useState<any[]>([]);
  const [shopsById, setShopsById] = useState<Record<string, any>>({});
  const [loading, setLoading] = useState(true);

  const [releasing, setReleasing] = useState<any>(null); // balance row being released
  const [amount, setAmount] = useState('0');
  const [note, setNote] = useState('');
  const [releaseError, setReleaseError] = useState('');
  const [saving, setSaving] = useState(false);

  const [history, setHistory] = useState<any>(null); // balance row whose history is open
  const [historyRows, setHistoryRows] = useState<any[]>([]);
  const [historyLoading, setHistoryLoading] = useState(false);

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    try {
      const [b, shops] = await Promise.all([fetchShopPaymentBalances(), fetchAllShops()]);
      setBalances(b);
      setShopsById(Object.fromEntries(shops.map((s: any) => [s.id, s])));
    } catch { /* ignore */ }
    setLoading(false);
  }

  function openRelease(row: any) {
    setReleasing(row);
    setAmount(String(row.pending_balance || 0));
    setNote('');
    setReleaseError('');
  }

  async function handleRelease() {
    if (!releasing) return;
    setReleaseError('');
    const val = parseFloat(amount) || 0;
    setSaving(true);
    try {
      await releaseShopPayout(releasing.shop_id, val, note);
      setReleasing(null);
      await load();
    } catch (e: any) {
      setReleaseError(e.message || 'Could not release this payout.');
    }
    setSaving(false);
  }

  async function openHistory(row: any) {
    setHistory(row);
    setHistoryLoading(true);
    try { setHistoryRows(await fetchShopPayouts(row.shop_id)); } catch { setHistoryRows([]); }
    setHistoryLoading(false);
  }

  const totalPending = balances.reduce((sum, b) => sum + (b.pending_balance || 0), 0);

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-2xl font-bold">Payments</h2>
        <p className="text-text-muted text-sm">
          Advance and final payments collected online land here first. Release a payout once you've
          paid the shop separately (bank transfer/cash) — this just records that it happened.
        </p>
      </div>

      {!loading && balances.length > 0 && (
        <div className="card flex items-center gap-3">
          <Wallet size={20} className="text-primary" />
          <div>
            <p className="text-sm text-text-muted">Total pending across all shops</p>
            <p className="text-xl font-bold">₹{totalPending.toLocaleString('en-IN')}</p>
          </div>
        </div>
      )}

      {loading ? (
        <div className="space-y-3">{[1, 2, 3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : balances.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr><th>Shop</th><th>Collected</th><th>Released</th><th>Pending</th><th>Payout Details</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {balances.map(row => {
                const shop = shopsById[row.shop_id];
                return (
                  <tr key={row.shop_id}>
                    <td className="font-medium">{row.shop_name}</td>
                    <td>₹{(row.total_collected || 0).toLocaleString('en-IN')}</td>
                    <td>₹{(row.total_released || 0).toLocaleString('en-IN')}</td>
                    <td className={`font-bold ${row.pending_balance > 0 ? 'text-primary' : ''}`}>
                      ₹{(row.pending_balance || 0).toLocaleString('en-IN')}
                    </td>
                    <td>
                      {shop?.upi_id || shop?.bank_account_number ? (
                        <div className="flex items-start gap-1.5 text-xs text-text-muted">
                          <Landmark size={13} className="shrink-0 mt-0.5" />
                          <span>
                            {shop.upi_id && <span className="block">UPI: {shop.upi_id}</span>}
                            {shop.bank_account_number && (
                              <span className="block">
                                {shop.bank_name || 'Bank'} · {shop.bank_account_number} · {shop.bank_ifsc}
                              </span>
                            )}
                          </span>
                        </div>
                      ) : <span className="text-text-muted text-xs">Not on file</span>}
                    </td>
                    <td>
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => openRelease(row)}
                          disabled={!row.pending_balance}
                          className="btn btn-primary text-xs px-3 py-1.5 disabled:opacity-40 disabled:cursor-not-allowed"
                        >
                          <Send size={14} /> Release
                        </button>
                        <button
                          onClick={() => openHistory(row)}
                          className="p-2 hover:bg-bg-hover rounded text-text-muted hover:text-primary"
                          title="Payout history"
                        >
                          <History size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState icon={<Wallet size={32} />} title="No payments yet" description="Collected advance/final payments will show up here once customers start paying online." />
      )}

      {/* Release Payout Modal */}
      {releasing && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setReleasing(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-md" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <h3 className="text-lg font-semibold">Release Payout — {releasing.shop_name}</h3>
              <button onClick={() => setReleasing(null)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5 space-y-4">
              <p className="text-sm text-text-muted">
                Pending balance: <strong>₹{(releasing.pending_balance || 0).toLocaleString('en-IN')}</strong>
              </p>
              <div className="input-group">
                <label className="input-label">Amount (₹)</label>
                <input type="number" value={amount} onChange={e => setAmount(e.target.value)} className="input-field" />
              </div>
              <div className="input-group">
                <label className="input-label">Note (optional)</label>
                <textarea value={note} onChange={e => setNote(e.target.value)} className="input-field" rows={2} placeholder="e.g. UPI transfer reference" />
              </div>
              {releaseError && <p className="text-error text-sm">{releaseError}</p>}
            </div>
            <div className="flex justify-end gap-2 p-5 border-t border-border">
              <button onClick={() => setReleasing(null)} className="btn btn-outline">Cancel</button>
              <button onClick={handleRelease} disabled={saving} className="btn btn-primary">
                <Send size={16} /> {saving ? 'Releasing...' : 'Confirm Release'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Payout History Modal */}
      {history && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setHistory(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-md max-h-[80vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <h3 className="text-lg font-semibold">Payout History — {history.shop_name}</h3>
              <button onClick={() => setHistory(null)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5">
              {historyLoading ? (
                <div className="space-y-2">{[1, 2].map(i => <div key={i} className="h-12 bg-bg-hover rounded-md animate-pulse" />)}</div>
              ) : historyRows.length > 0 ? (
                <div className="space-y-2">
                  {historyRows.map(row => (
                    <div key={row.id} className="p-3 bg-bg-hover rounded-md text-sm">
                      <div className="flex justify-between">
                        <span className="font-semibold">₹{Number(row.amount).toLocaleString('en-IN')}</span>
                        <span className="text-text-muted text-xs">{new Date(row.created_at).toLocaleDateString('en-IN')}</span>
                      </div>
                      {row.note && <p className="text-text-muted text-xs mt-1">{row.note}</p>}
                      <p className="text-text-muted text-xs mt-1">Released by {row.released_by}</p>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-text-muted">No payouts released yet.</p>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
