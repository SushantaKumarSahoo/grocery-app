import { useEffect, useState } from 'react';
import { BarChart3, TrendingUp, Users, ShoppingCart } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { fetchAllShops, fetchAllPlatformOrders } from '../../lib/api';

export default function Analytics() {
  const [shops, setShops] = useState<any[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    try { 
      const [shopsData, ordersData] = await Promise.all([
        fetchAllShops(),
        fetchAllPlatformOrders()
      ]);
      setShops(shopsData);
      setOrders(ordersData);
    } catch { /* ignore */ }
    setLoading(false);
  }

  // Calculate dynamic monthly revenue and orders for the past 6 months
  const monthlyData = (() => {
    const months = [];
    const now = new Date();
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      months.push({
        name: d.toLocaleString('default', { month: 'short' }),
        year: d.getFullYear(),
        month: d.getMonth(),
        revenue: 0,
        orders: 0
      });
    }

    orders.forEach(order => {
      const d = new Date(order.created_at);
      const m = months.find(x => x.month === d.getMonth() && x.year === d.getFullYear());
      if (m) {
        m.orders += 1;
        m.revenue += (Number(order.total_amount) || 0);
      }
    });

    return months;
  })();

  const totalRevenue = shops.reduce((sum, s) => sum + (Number(s.revenue) || 0), 0);
  const activeShops = shops.filter(s => s.status === 'active').length;

  const topShops = [...shops].sort((a, b) => (Number(b.revenue) || 0) - (Number(a.revenue) || 0)).slice(0, 5);
  const chartData = topShops.map(s => ({ name: s.name || 'Unnamed', revenue: Number(s.revenue) || 0 }));

  if (loading) {
    return <div className="space-y-4">{[1,2,3].map(i => <div key={i} className="h-32 bg-bg-hover rounded-xl animate-pulse" />)}</div>;
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-2xl font-bold">Platform Analytics</h2>
        <p className="text-text-muted text-sm">Monitor platform-wide growth and performance</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="card">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-full bg-primary-light flex items-center justify-center text-primary"><TrendingUp size={20} /></div>
            <h3 className="font-semibold text-text-muted">Total GMV</h3>
          </div>
          <p className="text-2xl font-bold">₹{totalRevenue.toLocaleString('en-IN')}</p>
        </div>
        <div className="card">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-full bg-blue-500/10 flex items-center justify-center text-blue-500"><Users size={20} /></div>
            <h3 className="font-semibold text-text-muted">Total Shops</h3>
          </div>
          <p className="text-2xl font-bold">{shops.length}</p>
        </div>
        <div className="card">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-full bg-success/10 flex items-center justify-center text-success"><CheckCircleIcon size={20} /></div>
            <h3 className="font-semibold text-text-muted">Active Shops</h3>
          </div>
          <p className="text-2xl font-bold">{activeShops}</p>
        </div>
        <div className="card">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-full bg-purple-500/10 flex items-center justify-center text-purple-500"><ShoppingCart size={20} /></div>
            <h3 className="font-semibold text-text-muted">Platform Orders</h3>
          </div>
          <p className="text-2xl font-bold">{orders.length.toLocaleString('en-IN')}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* GMV Over Time */}
        <div className="card col-span-1 lg:col-span-2">
          <h3 className="font-semibold mb-6 flex items-center gap-2"><BarChart3 size={18} /> Platform Revenue Trend</h3>
          <div className="h-80 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={monthlyData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#16A34A" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#16A34A" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#334155" />
                <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(val) => `₹${val/1000}k`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#1e293b', borderColor: '#334155', color: '#f8fafc', borderRadius: '8px' }}
                  itemStyle={{ color: '#16A34A' }}
                  formatter={(value: any) => [`₹${Number(value).toLocaleString('en-IN')}`, 'Revenue']}
                />
                <Area type="monotone" dataKey="revenue" stroke="#16A34A" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Top Shops */}
        <div className="card">
          <h3 className="font-semibold mb-6">Top Shops by Revenue</h3>
          <div className="h-64 w-full">
            {chartData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} layout="vertical" margin={{ top: 0, right: 30, left: 40, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#334155" />
                  <XAxis type="number" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis dataKey="name" type="category" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} width={100} />
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#1e293b', borderColor: '#334155', color: '#f8fafc', borderRadius: '8px' }}
                    cursor={{fill: '#334155', opacity: 0.4}}
                  />
                  <Bar dataKey="revenue" fill="#16A34A" radius={[0, 4, 4, 0]} barSize={24} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex items-center justify-center h-full text-text-muted text-sm">No revenue data available</div>
            )}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="card">
          <h3 className="font-semibold mb-6">Recent Shop Registrations</h3>
          <div className="space-y-4">
            {shops.slice(0, 5).map(s => (
              <div key={s.id} className="flex items-center justify-between pb-3 border-b border-border last:border-0 last:pb-0">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded bg-bg-hover flex items-center justify-center font-bold text-text-muted">
                    {s.name.charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <p className="font-medium text-sm">{s.name}</p>
                    <p className="text-xs text-text-muted">{s.city || 'No Location'}</p>
                  </div>
                </div>
                <span className="text-xs text-text-muted">{new Date(s.created_at).toLocaleDateString()}</span>
              </div>
            ))}
            {shops.length === 0 && <p className="text-sm text-text-muted text-center py-4">No shops registered yet</p>}
          </div>
        </div>
      </div>
    </div>
  );
}

// Temporary icon to replace CheckCircle to avoid too many imports if not used
function CheckCircleIcon({ size }: { size: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
      <polyline points="22 4 12 14.01 9 11.01"></polyline>
    </svg>
  );
}
