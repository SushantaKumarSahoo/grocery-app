import { Bell, Search, LogOut, Sun, Moon } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { useNavigate } from 'react-router-dom';

interface TopbarProps {
  title?: string;
}

export default function Topbar({ title }: TopbarProps) {
  const { user, signOut } = useAuth();
  const { isDark, toggle } = useTheme();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await signOut();
    navigate('/login');
  };

  return (
    <header className="topbar">
      <div className="flex-1 flex items-center gap-4">
        <h1 className="text-xl font-semibold text-text-main hidden sm:block">
          {title || 'Overview'}
        </h1>
        
        <div className="relative max-w-md w-full ml-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
          <input 
            type="text" 
            placeholder="Search..." 
            className="w-full pl-10 pr-4 py-2 bg-bg-hover border border-transparent rounded-full text-sm text-text-main focus:border-primary focus:bg-bg-card transition-all outline-none"
          />
        </div>
      </div>
      
      <div className="flex items-center gap-3">
        {/* Dark Mode Toggle */}
        <button
          onClick={toggle}
          className={`theme-toggle ${isDark ? 'active' : ''}`}
          aria-label="Toggle dark mode"
        >
          <div className="theme-toggle-knob">
            {isDark ? <Moon size={14} className="text-secondary" /> : <Sun size={14} className="text-amber-500" />}
          </div>
        </button>

        {/* Notifications */}
        <button className="relative p-2 text-text-muted hover:text-text-main rounded-full hover:bg-bg-hover transition-colors">
          <Bell size={20} />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-error rounded-full border-2 border-bg-card"></span>
        </button>
        
        <div className="h-8 w-px bg-border"></div>
        
        {/* User Info */}
        <div className="flex items-center gap-2 px-2">
          {user?.user_metadata?.avatar_url ? (
            <img src={user.user_metadata.avatar_url} alt="Avatar" className="w-8 h-8 rounded-full" />
          ) : (
            <div className="w-8 h-8 rounded-full bg-primary-light flex items-center justify-center text-primary font-bold text-sm">
              {user?.email?.charAt(0).toUpperCase() || 'A'}
            </div>
          )}
          <span className="text-sm font-medium text-text-main hidden md:block max-w-[120px] truncate">
            {user?.user_metadata?.full_name || user?.email || 'Admin'}
          </span>
        </div>

        {/* Logout */}
        <button
          onClick={handleLogout}
          className="p-2 text-text-muted hover:text-error hover:bg-error-bg rounded-lg transition-colors"
          title="Logout"
        >
          <LogOut size={18} />
        </button>
      </div>
    </header>
  );
}
