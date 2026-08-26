import { useEffect, useState } from 'react';
import { Plus, Search, Edit2, Trash2, X, Package } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import { fetchProducts, createProduct, updateProduct, deleteProduct, fetchCategories, createCategory } from '../../lib/api';
import EmptyState from '../../components/EmptyState';
import ImageUpload from '../../components/ImageUpload';

const UNITS = ['KG', 'Litre', 'Piece', 'Dozen', 'Packet', 'Box', 'Bag'];
const DEFAULT_CATEGORIES = ['Rice', 'Dal', 'Salt', 'Sugar', 'Dairy Grocery Items', 'Spices/Masala items', 'Flours', 'Oil', 'Dry fruits', 'Sweetener', 'Sauces', 'Papad', 'Plates & glasses', 'Other individual items'];

export default function Products() {
  const { shop } = useShop();
  const [products, setProducts] = useState<any[]>([]);
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterCat, setFilterCat] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<any>(null);
  const [deleting, setDeleting] = useState<any>(null);
  const [saving, setSaving] = useState(false);

  const [form, setForm] = useState({
    name: '', description: '', category_name: '', price: '', unit: 'KG',
    packaging: '', image_url: '',
  });

  useEffect(() => { if (shop) load(); }, [shop]);

  async function load() {
    setLoading(true);
    try {
      const [p, c] = await Promise.all([fetchProducts(shop.id), fetchCategories(shop.id)]);
      setProducts(p);
      setCategories(c);
    } catch { /* tables may not exist */ }
    setLoading(false);
  }

  function openAdd() {
    setEditing(null);
    setForm({ name: '', description: '', category_name: '', price: '', unit: 'KG', packaging: '', image_url: '' });
    setShowModal(true);
  }

  function openEdit(p: any) {
    setEditing(p);
    setForm({
      name: p.name, description: p.description || '', category_name: p.category_name || '',
      price: String(p.price || ''), unit: p.unit || 'KG', packaging: p.packaging || '', image_url: p.image_url || '',
    });
    setShowModal(true);
  }

  async function handleSave() {
    if (!form.name || !form.price) return;
    setSaving(true);
    try {
      const payload = {
        shop_id: shop.id,
        name: form.name,
        description: form.description,
        category_name: form.category_name,
        price: parseFloat(form.price),
        unit: form.unit,
        min_order_qty: 1,
        stock: 9999,
        packaging: form.packaging,
        image_url: form.image_url,
      };
      if (editing) {
        await updateProduct(editing.id, payload);
      } else {
        await createProduct(payload);
      }
      setShowModal(false);
      await load();
    } catch (e: any) { alert(e.message); }
    setSaving(false);
  }

  async function handleDelete() {
    if (!deleting) return;
    try {
      await deleteProduct(deleting.id);
      setDeleting(null);
      await load();
    } catch (e: any) { alert(e.message); }
  }

  async function seedCategories() {
    for (const name of DEFAULT_CATEGORIES) {
      await createCategory(shop.id, name);
    }
    await load();
  }

  const filtered = products.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(search.toLowerCase());
    const matchCat = !filterCat || p.category_name === filterCat;
    return matchSearch && matchCat;
  });

  const uniqueCats = [...new Set(products.map(p => p.category_name).filter(Boolean))];

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold">Products</h2>
          <p className="text-text-muted text-sm">Manage your product catalog</p>
        </div>
        <div className="flex gap-2">
          {categories.length === 0 && (
            <button onClick={seedCategories} className="btn btn-outline text-sm">Seed Categories</button>
          )}
          <button onClick={openAdd} className="btn btn-primary"><Plus size={16} /> Add Product</button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={16} />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search products..." className="input-field w-full pl-9" />
        </div>
        <select value={filterCat} onChange={e => setFilterCat(e.target.value)} className="input-field">
          <option value="">All Categories</option>
          {uniqueCats.map(c => <option key={c} value={c}>{c}</option>)}
        </select>
      </div>

      {/* Product Table */}
      {loading ? (
        <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse" />)}</div>
      ) : filtered.length > 0 ? (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Category</th>
                <th>Price</th>
                <th>Unit</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(p => (
                <tr key={p.id}>
                  <td>
                    <div className="flex items-center gap-3">
                      {p.image_url ? (
                        <img src={p.image_url} alt={p.name} className="w-10 h-10 rounded object-cover" />
                      ) : (
                        <div className="w-10 h-10 rounded bg-primary-light flex items-center justify-center text-primary"><Package size={18} /></div>
                      )}
                      <div>
                        <p className="font-medium">{p.name}</p>
                        {p.description && <p className="text-xs text-text-muted truncate max-w-[200px]">{p.description}</p>}
                      </div>
                    </div>
                  </td>
                  <td><span className="badge badge-primary">{p.category_name || '—'}</span></td>
                  <td className="font-semibold">₹{p.price}</td>
                  <td>{p.unit}</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <button onClick={() => openEdit(p)} className="p-2 hover:bg-bg-hover rounded transition-colors text-text-muted hover:text-primary"><Edit2 size={16} /></button>
                      <button onClick={() => setDeleting(p)} className="p-2 hover:bg-error-bg rounded transition-colors text-text-muted hover:text-error"><Trash2 size={16} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState icon={<Package size={32} />} title="No products yet" description="Add your first product to start receiving bulk orders."
          action={<button onClick={openAdd} className="btn btn-primary"><Plus size={16} /> Add Product</button>} />
      )}

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setShowModal(false)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-5 border-b border-border">
              <h3 className="text-lg font-semibold">{editing ? 'Edit Product' : 'Add Product'}</h3>
              <button onClick={() => setShowModal(false)} className="p-1 hover:bg-bg-hover rounded"><X size={20} /></button>
            </div>
            <div className="p-5 space-y-4">
              <div className="input-group"><label className="input-label">Product Name *</label><input value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="input-field" placeholder="e.g. Basmati Rice" /></div>
              <div className="input-group"><label className="input-label">Description</label><textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="input-field" rows={2} placeholder="Product details..." /></div>
              <div className="input-group"><label className="input-label">Category</label>
                <select value={form.category_name} onChange={e => setForm({...form, category_name: e.target.value})} className="input-field">
                  <option value="">Select category</option>
                  {DEFAULT_CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="input-group"><label className="input-label">Price (₹) *</label><input type="number" value={form.price} onChange={e => setForm({...form, price: e.target.value})} className="input-field" placeholder="0" /></div>
                <div className="input-group"><label className="input-label">Unit</label>
                  <select value={form.unit} onChange={e => setForm({...form, unit: e.target.value})} className="input-field">
                    {UNITS.map(u => <option key={u} value={u}>{u}</option>)}
                  </select>
                </div>
              </div>
              <div className="input-group"><label className="input-label">Packaging</label><input value={form.packaging} onChange={e => setForm({...form, packaging: e.target.value})} className="input-field" placeholder="e.g. 25kg bag, 5L can" /></div>
              <ImageUpload value={form.image_url} onChange={url => setForm({...form, image_url: url})} label="Product Image URL (Upload or Paste Link)" />
            </div>
            <div className="flex justify-end gap-2 p-5 border-t border-border">
              <button onClick={() => setShowModal(false)} className="btn btn-outline">Cancel</button>
              <button onClick={handleSave} disabled={saving} className="btn btn-primary">{saving ? 'Saving...' : editing ? 'Update' : 'Add Product'}</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleting && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setDeleting(null)}>
          <div className="bg-bg-card rounded-lg shadow-xl w-full max-w-sm p-6" onClick={e => e.stopPropagation()}>
            <h3 className="text-lg font-semibold mb-2">Delete Product</h3>
            <p className="text-text-muted text-sm mb-6">Are you sure you want to delete <strong>{deleting.name}</strong>? This cannot be undone.</p>
            <div className="flex justify-end gap-2">
              <button onClick={() => setDeleting(null)} className="btn btn-outline">Cancel</button>
              <button onClick={handleDelete} className="btn bg-error text-white hover:bg-red-600">Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
