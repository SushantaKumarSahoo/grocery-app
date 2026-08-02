import { useState } from 'react';
import { Save, Settings as SettingsIcon, Bell, Shield, Wallet } from 'lucide-react';

export default function Settings() {
  const [saving, setSaving] = useState(false);
  const [success, setSuccess] = useState('');

  // Mock global platform settings state
  const [settings, setSettings] = useState({
    platformName: 'BulkBasket Platform',
    supportEmail: 'support@bulkbasket.com',
    platformCommission: '5',
    defaultGst: '18',
    requireApproval: true,
    maintenanceMode: false
  });

  const handleSave = () => {
    setSaving(true);
    // Simulate API call
    setTimeout(() => {
      setSaving(false);
      setSuccess('Platform settings saved successfully.');
      setTimeout(() => setSuccess(''), 3000);
    }, 800);
  };

  return (
    <div className="flex flex-col gap-6 max-w-4xl">
      <div>
        <h2 className="text-2xl font-bold">Platform Settings</h2>
        <p className="text-text-muted text-sm">Configure global platform behavior and defaults</p>
      </div>

      {success && (
        <div className="bg-success-bg border border-success/20 text-success rounded-md px-4 py-3 text-sm font-medium">
          {success}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Navigation / Sections */}
        <div className="col-span-1 space-y-2">
          <div className="bg-primary-light text-primary font-medium px-4 py-3 rounded-md flex items-center gap-3">
            <SettingsIcon size={18} /> General
          </div>
          <div className="text-text-muted hover:bg-bg-hover hover:text-text-main font-medium px-4 py-3 rounded-md flex items-center gap-3 cursor-pointer transition-colors">
            <Wallet size={18} /> Financial
          </div>
          <div className="text-text-muted hover:bg-bg-hover hover:text-text-main font-medium px-4 py-3 rounded-md flex items-center gap-3 cursor-pointer transition-colors">
            <Shield size={18} /> Security
          </div>
          <div className="text-text-muted hover:bg-bg-hover hover:text-text-main font-medium px-4 py-3 rounded-md flex items-center gap-3 cursor-pointer transition-colors">
            <Bell size={18} /> Notifications
          </div>
        </div>

        {/* Content */}
        <div className="col-span-1 md:col-span-2 space-y-6">
          <div className="card space-y-5">
            <h3 className="text-lg font-semibold border-b border-border pb-3">General Settings</h3>
            
            <div className="input-group">
              <label className="input-label">Platform Name</label>
              <input 
                value={settings.platformName} 
                onChange={e => setSettings({...settings, platformName: e.target.value})} 
                className="input-field" 
              />
            </div>
            
            <div className="input-group">
              <label className="input-label">Support Email</label>
              <input 
                value={settings.supportEmail} 
                onChange={e => setSettings({...settings, supportEmail: e.target.value})} 
                className="input-field" 
              />
            </div>

            <div className="flex items-center justify-between p-3 bg-bg-hover rounded-md mt-4">
              <div>
                <p className="font-medium text-sm">Maintenance Mode</p>
                <p className="text-xs text-text-muted">Disable access to shop owners during updates</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input 
                  type="checkbox" 
                  className="sr-only peer" 
                  checked={settings.maintenanceMode}
                  onChange={(e) => setSettings({...settings, maintenanceMode: e.target.checked})}
                />
                <div className="w-11 h-6 bg-slate-600 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
              </label>
            </div>
          </div>

          <div className="card space-y-5">
            <h3 className="text-lg font-semibold border-b border-border pb-3">Financial Defaults</h3>
            
            <div className="grid grid-cols-2 gap-4">
              <div className="input-group mb-0">
                <label className="input-label">Platform Commission (%)</label>
                <input 
                  type="number"
                  value={settings.platformCommission} 
                  onChange={e => setSettings({...settings, platformCommission: e.target.value})} 
                  className="input-field" 
                />
              </div>
              <div className="input-group mb-0">
                <label className="input-label">Default GST Rate (%)</label>
                <input 
                  type="number"
                  value={settings.defaultGst} 
                  onChange={e => setSettings({...settings, defaultGst: e.target.value})} 
                  className="input-field" 
                />
              </div>
            </div>
          </div>

          <div className="card space-y-5">
            <h3 className="text-lg font-semibold border-b border-border pb-3">Shop Onboarding</h3>
            
            <div className="flex items-center justify-between p-3 bg-bg-hover rounded-md">
              <div>
                <p className="font-medium text-sm">Require Manual Approval</p>
                <p className="text-xs text-text-muted">New shops must be approved by admin before receiving orders</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input 
                  type="checkbox" 
                  className="sr-only peer" 
                  checked={settings.requireApproval}
                  onChange={(e) => setSettings({...settings, requireApproval: e.target.checked})}
                />
                <div className="w-11 h-6 bg-slate-600 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
              </label>
            </div>
          </div>

          <div className="flex justify-end">
            <button onClick={handleSave} disabled={saving} className="btn btn-primary px-8">
              <Save size={16} /> {saving ? 'Saving...' : 'Save All Settings'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
