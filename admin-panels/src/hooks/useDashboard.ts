import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

interface DashboardStats {
  totalRevenue: number;
  totalOrders: number;
  pendingQuotes: number;
  totalCustomers: number;
}

interface RecentOrder {
  id: string;
  occasion: string;
  order_number: string;
  total_amount: number;
  status: string;
  customer_name: string;
  created_at: string;
}

interface ChartPoint {
  name: string;
  revenue: number;
}

export function useAdminDashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalRevenue: 0,
    totalOrders: 0,
    pendingQuotes: 0,
    totalCustomers: 0,
  });
  const [recentOrders, setRecentOrders] = useState<RecentOrder[]>([]);
  const [chartData, setChartData] = useState<ChartPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  async function fetchDashboardData() {
    if (!supabase) {
      setLoading(false);
      setError('Supabase not configured');
      return;
    }

    try {
      setLoading(true);

      // Fetch orders count
      const { count: ordersCount } = await supabase
        .from('orders')
        .select('*', { count: 'exact', head: true });

      // Fetch pending quotations count
      const { count: pendingCount } = await supabase
        .from('orders')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending');

      // Fetch customers count
      const { count: customersCount } = await supabase
        .from('customers')
        .select('*', { count: 'exact', head: true });

      // Fetch total revenue
      const { data: revenueData } = await supabase
        .from('orders')
        .select('total_amount')
        .eq('status', 'delivered');

      const totalRevenue = revenueData?.reduce((sum, o) => sum + (o.total_amount || 0), 0) || 0;

      setStats({
        totalRevenue,
        totalOrders: ordersCount || 0,
        pendingQuotes: pendingCount || 0,
        totalCustomers: customersCount || 0,
      });

      // Fetch recent orders
      const { data: orders } = await supabase
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(5);

      setRecentOrders(orders || []);

      // Fetch chart data (orders grouped by day for last 7 days)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const { data: chartOrders } = await supabase
        .from('orders')
        .select('total_amount, created_at')
        .gte('created_at', sevenDaysAgo.toISOString())
        .eq('status', 'delivered');

      // Group by day
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const grouped: Record<string, number> = {};
      for (let i = 6; i >= 0; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        grouped[days[d.getDay()]] = 0;
      }

      chartOrders?.forEach((o) => {
        const day = days[new Date(o.created_at).getDay()];
        if (grouped[day] !== undefined) {
          grouped[day] += o.total_amount || 0;
        }
      });

      setChartData(Object.entries(grouped).map(([name, revenue]) => ({ name, revenue })));
      setError(null);
    } catch (err: any) {
      // Tables may not exist yet - handle gracefully
      console.warn('Dashboard data fetch failed (tables may not exist yet):', err.message);
      setError(null); // Don't show error to user, just show empty state
    } finally {
      setLoading(false);
    }
  }

  return { stats, recentOrders, chartData, loading, error, refetch: fetchDashboardData };
}

// Super Admin hooks
interface PlatformStats {
  totalShops: number;
  activeCustomers: number;
  totalOrders: number;
  totalRevenue: number;
}

interface ShopInfo {
  id: string;
  name: string;
  city: string;
  revenue: number;
  status: string;
}

export function useSuperAdminDashboard() {
  const [stats, setStats] = useState<PlatformStats>({
    totalShops: 0,
    activeCustomers: 0,
    totalOrders: 0,
    totalRevenue: 0,
  });
  const [topShops, setTopShops] = useState<ShopInfo[]>([]);
  const [chartData, setChartData] = useState<ChartPoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPlatformData();
  }, []);

  async function fetchPlatformData() {
    if (!supabase) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);

      // Fetch shops count
      const { count: shopsCount } = await supabase
        .from('shops')
        .select('*', { count: 'exact', head: true });

      // Fetch customers count
      const { count: customersCount } = await supabase
        .from('customers')
        .select('*', { count: 'exact', head: true });

      // Fetch orders count
      const { count: ordersCount } = await supabase
        .from('orders')
        .select('*', { count: 'exact', head: true });

      // Fetch total revenue
      const { data: revenueData } = await supabase
        .from('orders')
        .select('total_amount')
        .eq('status', 'delivered');

      const totalRevenue = revenueData?.reduce((sum, o) => sum + (o.total_amount || 0), 0) || 0;

      setStats({
        totalShops: shopsCount || 0,
        activeCustomers: customersCount || 0,
        totalOrders: ordersCount || 0,
        totalRevenue,
      });

      // Fetch top shops
      const { data: shops } = await supabase
        .from('shops')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(5);

      setTopShops(shops?.map((s) => ({
        id: s.id,
        name: s.name || 'Unnamed Shop',
        city: s.city || 'Unknown',
        revenue: s.revenue || 0,
        status: s.status || 'active',
      })) || []);

      // Fetch chart data (monthly)
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const currentMonth = new Date().getMonth();
      const monthlyData: ChartPoint[] = [];

      for (let i = 6; i >= 0; i--) {
        const monthIdx = (currentMonth - i + 12) % 12;
        monthlyData.push({ name: monthNames[monthIdx], revenue: 0 });
      }

      const { data: monthlyOrders } = await supabase
        .from('orders')
        .select('total_amount, created_at')
        .eq('status', 'delivered');

      monthlyOrders?.forEach((o) => {
        const month = monthNames[new Date(o.created_at).getMonth()];
        const entry = monthlyData.find((m) => m.name === month);
        if (entry) {
          entry.revenue += o.total_amount || 0;
        }
      });

      setChartData(monthlyData);
    } catch (err: any) {
      console.warn('Platform data fetch failed (tables may not exist yet):', err.message);
    } finally {
      setLoading(false);
    }
  }

  return { stats, topShops, chartData, loading, refetch: fetchPlatformData };
}
