import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Topbar from '../components/Topbar';

export default function SuperAdminLayout() {
  return (
    <div className="app-container">
      <Sidebar role="super-admin" />
      <div className="main-content">
        <Topbar title="Super Admin Dashboard" />
        <main className="page-content bg-bg-main">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
