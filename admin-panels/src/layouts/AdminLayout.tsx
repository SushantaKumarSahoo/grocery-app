import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Topbar from '../components/Topbar';
import { ShopProvider } from '../context/ShopContext';

export default function AdminLayout() {
  return (
    <ShopProvider>
      <div className="app-container">
        <Sidebar role="admin" />
        <div className="main-content">
          <Topbar title="Shop Admin" />
          <main className="page-content bg-bg-main">
            <Outlet />
          </main>
        </div>
      </div>
    </ShopProvider>
  );
}
