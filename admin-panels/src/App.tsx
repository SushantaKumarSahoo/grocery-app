import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import AdminLayout from './layouts/AdminLayout';
import SuperAdminLayout from './layouts/SuperAdminLayout';
import AdminDashboard from './pages/admin/AdminDashboard';
import Products from './pages/admin/Products';
import Orders from './pages/admin/Orders';
import Quotations from './pages/admin/Quotations';
import Customers from './pages/admin/Customers';
import AdminSupport from './pages/admin/Support';
import Profile from './pages/admin/Profile';
import SuperAdminDashboard from './pages/super-admin/SuperAdminDashboard';
import SuperAdminShops from './pages/super-admin/Shops';
import SuperAdminAdmins from './pages/super-admin/Admins';
import SuperAdminAnalytics from './pages/super-admin/Analytics';
import SuperAdminServiceableAreas from './pages/super-admin/ServiceableAreas';
import SuperAdminPayments from './pages/super-admin/Payments';
import SuperAdminSettings from './pages/super-admin/Settings';
import SuperAdminSupport from './pages/super-admin/Support';
import LandingPage from './pages/LandingPage';
import Login from './pages/auth/Login';
import ProtectedRoute from './components/ProtectedRoute';
import SuperAdminRoute from './components/SuperAdminRoute';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <Router>
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/login" element={<Login />} />
            
            <Route element={<ProtectedRoute />}>
              {/* Shop Owner Admin Routes */}
              <Route path="/admin" element={<AdminLayout />}>
                <Route index element={<AdminDashboard />} />
                <Route path="products" element={<Products />} />
                <Route path="orders" element={<Orders />} />
                <Route path="quotations" element={<Quotations />} />
                <Route path="customers" element={<Customers />} />
                <Route path="support" element={<AdminSupport />} />
                <Route path="profile" element={<Profile />} />
              </Route>
            </Route>

            <Route element={<SuperAdminRoute />}>
              {/* Super Admin Routes */}
              <Route path="/super-admin" element={<SuperAdminLayout />}>
                <Route index element={<SuperAdminDashboard />} />
                <Route path="shops" element={<SuperAdminShops />} />
                <Route path="admins" element={<SuperAdminAdmins />} />
                <Route path="analytics" element={<SuperAdminAnalytics />} />
                <Route path="serviceable-areas" element={<SuperAdminServiceableAreas />} />
                <Route path="payments" element={<SuperAdminPayments />} />
                <Route path="support" element={<SuperAdminSupport />} />
                <Route path="settings" element={<SuperAdminSettings />} />
              </Route>
            </Route>
          </Routes>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
