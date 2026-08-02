import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, Package, ShoppingCart, Users, Settings,
  FileText, Store, BarChart3, LifeBuoy
} from 'lucide-react';

interface SidebarProps {
  role: 'admin' | 'super-admin';
}

export default function Sidebar({ role }: SidebarProps) {
  const adminLinks = [
    { name: 'Dashboard', path: '/admin', icon: <LayoutDashboard size={20} /> },
    { name: 'Products', path: '/admin/products', icon: <Package size={20} /> },
    { name: 'Bulk Orders', path: '/admin/orders', icon: <ShoppingCart size={20} /> },
    { name: 'Quotations', path: '/admin/quotations', icon: <FileText size={20} /> },
    { name: 'Customers', path: '/admin/customers', icon: <Users size={20} /> },
    { name: 'Support', path: '/admin/support', icon: <LifeBuoy size={20} /> },
    { name: 'Store Profile', path: '/admin/profile', icon: <Store size={20} /> },
  ];

  const superAdminLinks = [
    { name: 'Dashboard', path: '/super-admin', icon: <LayoutDashboard size={20} /> },
    { name: 'Shops', path: '/super-admin/shops', icon: <ShoppingCart size={20} /> },
    { name: 'Admins', path: '/super-admin/admins', icon: <Users size={20} /> },
    { name: 'Analytics', path: '/super-admin/analytics', icon: <BarChart3 size={20} /> },
    { name: 'Support', path: '/super-admin/support', icon: <LifeBuoy size={20} /> },
    { name: 'Settings', path: '/super-admin/settings', icon: <Settings size={20} /> },
  ];

  const links = role === 'admin' ? adminLinks : superAdminLinks;
  const title = role === 'admin' ? 'Shop Admin' : 'Super Admin';

  return (
    <aside className="sidebar">
      <div className="h-16 flex items-center px-6 border-b border-border">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded bg-primary flex items-center justify-center text-white font-bold text-lg">
            B
          </div>
          <span className="font-bold text-lg text-text-main">{title}</span>
        </div>
      </div>
      
      <nav className="flex-1 py-4 px-3 flex flex-col gap-1 overflow-y-auto">
        {links.map((link) => (
          <NavLink
            key={link.name}
            to={link.path}
            end={link.path === '/admin' || link.path === '/super-admin'}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-sm text-sm font-medium transition-colors ${
                isActive 
                  ? 'bg-primary-light text-primary' 
                  : 'text-text-muted hover:bg-bg-hover hover:text-text-main'
              }`
            }
          >
            {link.icon}
            {link.name}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
