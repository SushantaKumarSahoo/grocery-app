import { useEffect, useState } from 'react';
import { FileText, Plus, Eye, Send, X, Calculator, MessageSquareWarning } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import { fetchQuotations, fetchOrders, createQuotation, fetchProducts } from '../../lib/api';
import EmptyState from '../../components/EmptyState';

export default function Quotations() {
  const { shop } = useShop();
  const [quotations, setQuotations] = useState<any[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [products, setProducts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showBuilder, setShowBuilder] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [revising, setRevising] = useState<any>(null); // the changes_requested quotation being replaced
  const [viewQuote, setViewQuote] = useState<any>(null);
  const [saving, setSaving] = useState(false);

  // Builder state
  const [items, setItems] = useState<any[]>([]);
  const [transport, setTransport] = useState('0');
  const [gstPercent, setGstPercent] = useState('18');
  const [discountPercent, setDiscountPercent] = useState('0');
  const [notes, setNotes] = useState('');

  useEffect(() => { if (shop) load(); }, [shop]);

  async function load() {
    setLoading(true);
    try {
      const [q, o, p] = await Promise.all([fetchQuotations(shop.id), fetchOrders(shop.id), fetchProducts(shop.id)]);
      setQuotations(q);
      setOrders(o);
      setProducts(p);
    } catch { /* */ }
    setLoading(false);
  }

  // fetchQuotations is already ordered by created_at desc, so the first
  // match per order is the latest one.
  function latestQuotationFor(orderId: string) {
    return quotations.find(q => q.order_id === orderId) || null;
  }

  // An order only ever needs a NEW quotation when it's never been quoted,
  // or the customer explicitly asked for changes to the last one — that's
  // the only path that lets a second quotation exist for the same order.
  const needsQuotation = orders
    .map(o => ({ order: o, latest: latestQuotationFor(o.id) }))
    .filter(({ order, latest }) =>
      order.status === 'pending' || latest?.status === 'changes_requested'
    );

  function openBuilder(order: any, revisionOf: any = null) {
    setSelectedOrder(order);
    setRevising(revisionOf);
    if (revisionOf) {
      setItems((revisionOf.items || []).map((i: any) => ({ ...i })));
      setTransport(String(revisionOf.transport_charge ?? 0));
      setGstPercent(String(revisionOf.gst_percent ?? 18));
      setDiscountPercent(String(revisionOf.discount_percent ?? 0));
      setNotes('');
    } else {
      setItems(products.slice(0, 3).map(p => ({ product_name: p.name, quantity: p.min_order_qty || 1, unit: p.unit, price_per_unit: p.price })));
      setTransport('0'); setGstPercent('18'); setDiscountPercent('0'); setNotes('');
    }
    setShowBuilder(true);
  }

  function addItem() {
    setItems([...items, { product_name: '', quantity: 1, unit: 'KG', price_per_unit: 0 }]);
  }

  function updateItem(idx: number, field: string, value: any) {
    const updated = [...items];
    updated[idx] = { ...updated[idx], [field]: value };
    setItems(updated);
  }

  function removeItem(idx: number) {
    setItems(items.filter((_, i) => i !== idx));
  }

  const subtotal = items.reduce((sum, item) => sum + (item.quantity * item.price_per_unit), 0);
  const transportVal = parseFloat(transport) || 0;
  const gstVal = (subtotal * (parseFloat(gstPercent) || 0)) / 100;
  const discountVal = (subtotal * (parseFloat(discountPercent) || 0)) / 100;
  const grandTotal = subtotal + transportVal + gstVal - discountVal;

  async function handleSend() {
    if (!selectedOrder || items.length === 0) return;
    setSaving(true);
    try {
      await createQuotation({
        order_id: selectedOrder.id, shop_id: shop.id,
        items: items, subtotal, transport_charge: transportVal,
        gst_percent: parseFloat(gstPercent) || 0, gst_amount: gstVal,
        discount_percent: parseFloat(discountPercent) || 0, discount_amount: discountVal,
        grand_total: grandTotal, notes, status: 'sent',
      });
      setShowBuilder(false);
      setRevising(null);
      await load();
    } catch (e: any) { alert(e.message); }
    setSaving(false);
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div><h2 className="text-2xl font-bold">Quotations</h2><p className="text-text-muted text-sm">Build and send quotations to customers</p></div>
      </div>

      {/* Orders needing a (new or revised) quotation */}
      {needsQuotation.length > 0 && (
        <div>
          <h3 className="font-semibold mb-3 text-sm text-text-muted uppercase tracking-wider">Needs a Quotation</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {needsQuotation.map(({ order: o, latest }) => {
              const isRevision = latest?.status === 'changes_requested';
              return (
                <div key={o.id} className={`card ${isRevision ? 'border-warning/40' : 'hover:border-primary/20'}`}>
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-semibold text-sm">#{o.order_number || o.id?.slice(0, 8)}</span>
                    <span className={`badge ${isRevision ? 'badge-warning' : 'badge-warning'}`}>{isRevision ? 'changes requested' : o.status}</span>
                  </div>
                  <p className="text-sm text-text-muted">{o.customer_name || 'Customer'} • {o.occasion || 'Bulk Order'}</p>
                  <p className="text-xs text-text-muted mt-1">{o.event_date ? new Date(o.event_date).toLocaleDateString('en-IN') : ''}</p>
                  {isRevision && latest?.notes && (
                    <div className="mt-2 p-2 bg-warning-bg rounded text-xs flex gap-2 items-start">
                      <MessageSquareWarning size={14} className="shrink-0 mt-0.5" />
                      <span className="line-clamp-3">{latest.notes}</span>
                    </div>
                  )}
                  <button
                    onClick={() => openBuilder(o, isRevision ? latest : null)}
                    className="btn btn-primary w-full mt-3 text-sm"
                  >
                    <Calculator size={14} /> {isRevision ? 'Send Updated Quotation' : 'Build Quotation'}
                  </button>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Quotation List */}
      <div>
        <h3 className="font-semibold mb-3 text-sm text-text-muted uppercase tracking-wider">Sent Quotations</h3>
        {loading ? (
          <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
        ) : quotations.length > 0 ? (
          <div className="table-container">
            <table className="table">
              <thead><tr><th>Order</th><th>Items</th><th>Subtotal</th><th>GST</th><th>Total</th><th>Status</th><th>Actions</th></tr></thead>
              <tbody>
                {quotations.map(q => (
                  <tr key={q.id}>
                    <td className="font-medium">#{q.orders?.order_number || q.order_id?.slice(0, 8)}</td>
                    <td>{(q.items || []).length} items</td>
                    <td>₹{(q.subtotal || 0).toLocaleString('en-IN')}</td>
                    <td>₹{(q.gst_amount || 0).toLocaleString('en-IN')}</td>
                    <td className="font-bold">₹{(q.grand_total || 0).toLocaleString('en-IN')}</td>
                    <td>
                      <span className={`badge ${
                        q.status === 'sent' ? 'badge-primary'
                        : q.status === 'accepted' ? 'badge-success'
                        : q.status === 'rejected' ? 'badge-error'
                        : q.status === 'changes_requested' ? 'badge-warning'
                        : 'badge-warning'
                      }`}>
                        {q.status.replace('_', ' ')}
                      </span>
                    </td>
                    <td><button onClick={() => setViewQuote(q)} className="p-2 hover:bg-bg-hover rounded text-text-muted hover:text-primary"><Eye size={16} /></button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <EmptyState icon={<FileText size={32} />} title="No quotations yet" description="Create quotations from the list above." />
        )}
      </div>

      {/* Quotation Builder Modal */}
      {showBuilder && selectedOrder && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setShowBuilder(false)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-3xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <div>
                <h3 className="text-lg font-semibold">{revising ? 'Revise Quotation' : 'Quotation Builder'}</h3>
                <p className="text-sm text-text-muted">Order #{selectedOrder.order_number || selectedOrder.id?.slice(0, 8)} • {selectedOrder.customer_name}</p>
              </div>
              <button onClick={() => setShowBuilder(false)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5 space-y-6">
              {revising?.notes && (
                <div className="p-3 bg-warning-bg rounded-md text-sm flex gap-2 items-start">
                  <MessageSquareWarning size={16} className="shrink-0 mt-0.5" />
                  <div><strong>Customer's request:</strong> {revising.notes}</div>
                </div>
              )}
              {/* Items */}
              <div>
                <div className="flex items-center justify-between mb-3">
                  <h4 className="font-semibold">Line Items</h4>
                  <button onClick={addItem} className="btn btn-outline text-sm"><Plus size={14} /> Add Item</button>
                </div>
                <div className="space-y-2">
                  {items.map((item, idx) => (
                    <div key={idx} className="grid grid-cols-12 gap-2 items-end p-3 bg-bg-hover rounded-md">
                      <div className="col-span-4">
                        <label className="text-xs text-text-muted">Product</label>
                        <input value={item.product_name} onChange={e => updateItem(idx, 'product_name', e.target.value)} className="input-field w-full mt-1" placeholder="Product name" />
                      </div>
                      <div className="col-span-2">
                        <label className="text-xs text-text-muted">Qty</label>
                        <input type="number" value={item.quantity} onChange={e => updateItem(idx, 'quantity', parseFloat(e.target.value) || 0)} className="input-field w-full mt-1" />
                      </div>
                      <div className="col-span-2">
                        <label className="text-xs text-text-muted">Unit</label>
                        <select value={item.unit} onChange={e => updateItem(idx, 'unit', e.target.value)} className="input-field w-full mt-1">
                          {['KG', 'Litre', 'Piece', 'Dozen', 'Packet'].map(u => <option key={u}>{u}</option>)}
                        </select>
                      </div>
                      <div className="col-span-2">
                        <label className="text-xs text-text-muted">₹/Unit</label>
                        <input type="number" value={item.price_per_unit} onChange={e => updateItem(idx, 'price_per_unit', parseFloat(e.target.value) || 0)} className="input-field w-full mt-1" />
                      </div>
                      <div className="col-span-1 text-right font-semibold text-sm pt-5">₹{(item.quantity * item.price_per_unit).toLocaleString('en-IN')}</div>
                      <div className="col-span-1 pt-5"><button onClick={() => removeItem(idx)} className="p-1 hover:bg-error-bg rounded text-text-muted hover:text-error"><X size={16} /></button></div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Charges */}
              <div className="grid grid-cols-3 gap-4">
                <div className="input-group"><label className="input-label">Transport (₹)</label><input type="number" value={transport} onChange={e => setTransport(e.target.value)} className="input-field" /></div>
                <div className="input-group"><label className="input-label">GST (%)</label><input type="number" value={gstPercent} onChange={e => setGstPercent(e.target.value)} className="input-field" /></div>
                <div className="input-group"><label className="input-label">Discount (%)</label><input type="number" value={discountPercent} onChange={e => setDiscountPercent(e.target.value)} className="input-field" /></div>
              </div>

              <div className="input-group"><label className="input-label">Notes</label><textarea value={notes} onChange={e => setNotes(e.target.value)} className="input-field" rows={2} placeholder="Any additional notes..." /></div>

              {/* Summary */}
              <div className="bg-bg-hover rounded-lg p-4 space-y-2">
                <div className="flex justify-between text-sm"><span className="text-text-muted">Subtotal</span><span>₹{subtotal.toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Transport</span><span>₹{transportVal.toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">GST ({gstPercent}%)</span><span>₹{gstVal.toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm text-success"><span>Discount ({discountPercent}%)</span><span>-₹{discountVal.toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-lg font-bold pt-2 border-t border-border"><span>Grand Total</span><span>₹{grandTotal.toLocaleString('en-IN')}</span></div>
              </div>
            </div>
            <div className="flex justify-end gap-2 p-5 border-t border-border">
              <button onClick={() => setShowBuilder(false)} className="btn btn-outline">Cancel</button>
              <button onClick={handleSend} disabled={saving} className="btn btn-primary"><Send size={16} /> {saving ? 'Sending...' : 'Send Quotation'}</button>
            </div>
          </div>
        </div>
      )}

      {/* View Quotation Modal */}
      {viewQuote && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setViewQuote(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <h3 className="text-lg font-semibold">Quotation Details</h3>
              <button onClick={() => setViewQuote(null)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5 space-y-4">
              <div className="space-y-2">
                {(viewQuote.items || []).map((item: any, idx: number) => (
                  <div key={idx} className="flex justify-between text-sm p-2 bg-bg-hover rounded">
                    <span>{item.product_name} × {item.quantity} {item.unit}</span>
                    <span className="font-semibold">₹{(item.quantity * item.price_per_unit).toLocaleString('en-IN')}</span>
                  </div>
                ))}
              </div>
              <div className="bg-bg-hover rounded-lg p-4 space-y-2">
                <div className="flex justify-between text-sm"><span>Subtotal</span><span>₹{(viewQuote.subtotal || 0).toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm"><span>Transport</span><span>₹{(viewQuote.transport_charge || 0).toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm"><span>GST ({viewQuote.gst_percent}%)</span><span>₹{(viewQuote.gst_amount || 0).toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-sm text-success"><span>Discount</span><span>-₹{(viewQuote.discount_amount || 0).toLocaleString('en-IN')}</span></div>
                <div className="flex justify-between text-lg font-bold pt-2 border-t border-border"><span>Grand Total</span><span>₹{(viewQuote.grand_total || 0).toLocaleString('en-IN')}</span></div>
              </div>
              {viewQuote.notes && <div className="p-3 bg-bg-hover rounded text-sm"><strong>Notes:</strong> {viewQuote.notes}</div>}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
