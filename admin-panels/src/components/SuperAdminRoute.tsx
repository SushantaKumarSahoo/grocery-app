import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function SuperAdminRoute() {
  const { user, loading, isSuperAdmin } = useAuth();

  if (loading) {
    return <div className="h-screen w-screen flex items-center justify-center bg-bg-main">Loading...</div>;
  }

  // If not logged in, go to login
  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // If logged in but NOT a super admin, go to shop admin dashboard
  if (!isSuperAdmin) {
    return <Navigate to="/admin" replace />;
  }

  return <Outlet />;
}
