import { useState } from 'react';
import { Save, Store, CreditCard, MapPin } from 'lucide-react';
import { useShop } from '../../context/ShopContext';
import { updateShopProfile } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import ImageUpload from '../../components/ImageUpload';

export default function Profile() {
  const { shop, refresh } = useShop();
  const { user } = useAuth();
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState<'store' | 'bank'>('store');
  const [success, setSuccess] = useState('');

  const [form, setForm] = useState({
    name: shop?.name || '',
    description: shop?.description || '',
    logo_url: shop?.logo_url || '',
    address: shop?.address || '',
    city: shop?.city || '',
    state: shop?.state || '',
    pincode: shop?.pincode || '',
    phone: shop?.phone || '',
    email: shop?.email || user?.email || '',
    bank_name: shop?.bank_name || '',
    bank_account_number: shop?.bank_account_number || '',
    bank_ifsc: shop?.bank_ifsc || '',
    upi_id: shop?.upi_id || '',
  });

  async function handleSave() {
    if (!shop) return;
    setSaving(true);
    try {
      await updateShopProfile(shop.id, form);
      await refresh();
      setSuccess('Profile saved successfully!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (e: any) { alert(e.message); }
    setSaving(false);
  }

  const tabs = [
    { key: 'store' as const, label: 'Store Details', icon: <Store size={16} /> },
    { key: 'bank' as const, label: 'Payment Details', icon: <CreditCard size={16} /> },
  ];

  return (
    <div className="flex flex-col gap-6 max-w-3xl">
      <div>
        <h2 className="text-2xl font-bold">Store Profile</h2>
        <p className="text-text-muted text-sm">Manage your store information and payment settings</p>
      </div>

      {success && (
        <div className="bg-success-bg border border-success/20 text-success rounded-md px-4 py-3 text-sm font-medium">
          {success}
        </div>
      )}

      {/* Tabs */}
      <div className="flex gap-1 border-b border-border">
        {tabs.map(tab => (
          <button key={tab.key} onClick={() => setActiveTab(tab.key)}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
              activeTab === tab.key ? 'border-primary text-primary' : 'border-transparent text-text-muted hover:text-text-main'
            }`}>
            {tab.icon} {tab.label}
          </button>
        ))}
      </div>

      {/* Store Details Tab */}
      {activeTab === 'store' && (
        <div className="card space-y-5">
          <div className="mb-4">
            <ImageUpload 
              value={form.logo_url} 
              onChange={url => setForm({...form, logo_url: url})} 
              label="Store Logo" 
              size="sm"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="input-group"><label className="input-label">Store Name</label><input value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="input-field" placeholder="Your Store Name" /></div>
            <div className="input-group"><label className="input-label">Phone</label><input value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} className="input-field" placeholder="+91..." /></div>
          </div>

          <div className="input-group"><label className="input-label">Email</label><input value={form.email} onChange={e => setForm({...form, email: e.target.value})} className="input-field" placeholder="store@example.com" /></div>

          <div className="input-group"><label className="input-label">Description</label><textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="input-field" rows={3} placeholder="Tell customers about your store..." /></div>

          <div className="flex items-center gap-2 text-text-muted text-sm mb-2"><MapPin size={16} /> <span className="font-semibold">Address</span></div>
          <div className="input-group"><label className="input-label">Street Address</label><input value={form.address} onChange={e => setForm({...form, address: e.target.value})} className="input-field" placeholder="Street address" /></div>
          <div className="grid grid-cols-3 gap-4">
            <div className="input-group"><label className="input-label">City</label><input value={form.city} onChange={e => setForm({...form, city: e.target.value})} className="input-field" placeholder="City" /></div>
            <div className="input-group"><label className="input-label">State</label><input value={form.state} onChange={e => setForm({...form, state: e.target.value})} className="input-field" placeholder="State" /></div>
            <div className="input-group"><label className="input-label">Pincode</label><input value={form.pincode} onChange={e => setForm({...form, pincode: e.target.value})} className="input-field" placeholder="560001" /></div>
          </div>
        </div>
      )}

      {/* Bank Details Tab */}
      {activeTab === 'bank' && (
        <div className="card space-y-5">
          <div className="flex items-center gap-2 text-text-muted text-sm"><CreditCard size={16} /> <span className="font-semibold">Bank Account Details</span></div>
          <div className="input-group"><label className="input-label">Bank Name</label><input value={form.bank_name} onChange={e => setForm({...form, bank_name: e.target.value})} className="input-field" placeholder="e.g. State Bank of India" /></div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="input-group"><label className="input-label">Account Number</label><input value={form.bank_account_number} onChange={e => setForm({...form, bank_account_number: e.target.value})} className="input-field" placeholder="Account number" /></div>
            <div className="input-group"><label className="input-label">IFSC Code</label><input value={form.bank_ifsc} onChange={e => setForm({...form, bank_ifsc: e.target.value})} className="input-field" placeholder="e.g. SBIN0001234" /></div>
          </div>

          <div className="border-t border-border pt-5">
            <div className="flex items-center gap-2 text-text-muted text-sm mb-4"><span className="font-semibold">UPI Details</span></div>
            <div className="input-group"><label className="input-label">UPI ID</label><input value={form.upi_id} onChange={e => setForm({...form, upi_id: e.target.value})} className="input-field" placeholder="yourstore@upi" /></div>
          </div>
        </div>
      )}

      {/* Save Button */}
      <div className="flex justify-end">
        <button onClick={handleSave} disabled={saving} className="btn btn-primary px-8">
          <Save size={16} /> {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>
    </div>
  );
}
