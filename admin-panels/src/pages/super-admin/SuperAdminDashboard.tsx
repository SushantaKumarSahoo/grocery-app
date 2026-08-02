import { Store, Users, ShoppingBag, Building2, TrendingUp, RefreshCw } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useSuperAdminDashboard } from '../../hooks/useDashboard';
import EmptyState from '../../components/EmptyState';

const StatCard = ({ title, value, icon, loading }: { title: string; value: string; icon: React.ReactNode; loading: boolean }) => (
  <div className="card flex flex-col gap-4">
    <div className="flex items-center justify-between">
      <span className="text-sm font-medium text-text-muted">{title}</span>
      <div className="w-8 h-8 rounded bg-bg-hover flex items-center justify-center text-secondary">
        {icon}
      </div>
    </div>
    <div>
      {loading ? (
        <div className="h-8 w-24 bg-bg-hover rounded animate-pulse"></div>
      ) : (
        <h3 className="text-2xl font-bold text-text-main">{value}</h3>
      )}
    </div>
  </div>
);

function formatCurrency(amount: number): string {
  if (amount >= 10000000) return `₹${(amount / 10000000).toFixed(1)}Cr`;
  if (amount >= 100000) return `₹${(amount / 100000).toFixed(1)}L`;
  if (amount >= 1000) return `₹${amount.toLocaleString('en-IN')}`;
  return `₹${amount}`;
}

export default function SuperAdminDashboard() {
  const { stats, topShops, chartData, loading, refetch } = useSuperAdminDashboard();

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-bold">Platform Overview</h2>
          <p className="text-text-muted text-sm">Global metrics and platform health.</p>
        </div>
        <button onClick={refetch} className="btn btn-outline gap-2" title="Refresh">
          <RefreshCw size={16} />
          Refresh
        </button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Total Platform GMV" value={formatCurrency(stats.totalRevenue)} icon={<Store size={18} />} loading={loading} />
        <StatCard title="Active Shops" value={stats.totalShops.toString()} icon={<Building2 size={18} />} loading={loading} />
        <StatCard title="Total Orders" value={stats.totalOrders.toLocaleString('en-IN')} icon={<ShoppingBag size={18} />} loading={loading} />
        <StatCard title="Active Users" value={stats.activeCustomers.toLocaleString('en-IN')} icon={<Users size={18} />} loading={loading} />
      </div>

      {/* Chart + Top Shops */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Platform Growth Chart */}
        <div className="card lg:col-span-2">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-semibold text-lg">Platform Growth</h3>
          </div>
          <div className="h-[300px] w-full">
            {loading ? (
              <div className="h-full w-full bg-bg-hover rounded animate-pulse"></div>
            ) : chartData.length > 0 && chartData.some(d => d.revenue > 0) ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenueSA" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#1E3A8A" stopOpacity={0.2} />
                      <stop offset="95%" stopColor="#1E3A8A" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--color-border)" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: 'var(--color-text-muted)' }} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: 'var(--color-text-muted)' }} />
                  <Tooltip
                    contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)', backgroundColor: 'var(--color-bg-card)', color: 'var(--color-text-main)' }}
                    labelStyle={{ fontWeight: 'bold', color: 'var(--color-text-main)' }}
                  />
                  <Area type="monotone" dataKey="revenue" stroke="#1E3A8A" strokeWidth={2} fillOpacity={1} fill="url(#colorRevenueSA)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <EmptyState
                icon={<TrendingUp size={32} />}
                title="No revenue data yet"
                description="Platform revenue will appear here once shops start fulfilling orders."
              />
            )}
          </div>
        </div>

        {/* Top Shops */}
        <div className="card flex flex-col">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-lg">Top Shops</h3>
          </div>

          {loading ? (
            <div className="flex flex-col gap-3">
              {[1, 2, 3].map(i => (
                <div key={i} className="h-16 bg-bg-hover rounded-md animate-pulse"></div>
              ))}
            </div>
          ) : topShops.length > 0 ? (
            <div className="flex flex-col gap-2 flex-1 overflow-y-auto">
              {topShops.map((shop, i) => (
                <div key={shop.id} className="flex items-center justify-between p-3 hover:bg-bg-hover rounded-md transition-colors cursor-pointer border border-transparent hover:border-border">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded bg-primary-light flex items-center justify-center text-primary font-bold">
                      S{i + 1}
                    </div>
                    <div>
                      <p className="font-medium text-sm">{shop.name}</p>
                      <p className="text-xs text-text-muted">{shop.city}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-bold text-sm">{formatCurrency(shop.revenue)}</p>
                    <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${
                      shop.status === 'active' ? 'bg-success-bg text-success' : 'bg-warning-bg text-warning'
                    }`}>
                      {shop.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <EmptyState
              icon={<Store size={32} />}
              title="No shops registered"
              description="Shops will appear here once they register on the platform."
            />
          )}
        </div>
      </div>
    </div>
  );
}
