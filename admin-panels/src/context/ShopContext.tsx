import React, { createContext, useContext, useEffect, useState } from 'react';
import { getOrCreateShop } from '../lib/api';
import { useAuth } from './AuthContext';

interface ShopContextType {
  shop: any;
  loading: boolean;
  refresh: () => Promise<void>;
}

const ShopContext = createContext<ShopContextType>({ shop: null, loading: true, refresh: async () => {} });

export const ShopProvider = ({ children }: { children: React.ReactNode }) => {
  const { user } = useAuth();
  const [shop, setShop] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const refresh = async () => {
    if (!user) { setLoading(false); return; }
    try {
      const s = await getOrCreateShop();
      setShop(s);
    } catch { /* ignore */ }
    setLoading(false);
  };

  useEffect(() => { refresh(); }, [user]);

  return <ShopContext.Provider value={{ shop, loading, refresh }}>{children}</ShopContext.Provider>;
};

export const useShop = () => useContext(ShopContext);
