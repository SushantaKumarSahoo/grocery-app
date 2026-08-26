import React, { createContext, useContext, useEffect, useState } from 'react';
import type { User, Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { checkIsSuperAdmin } from '../lib/api';

interface AuthContextType {
  user: User | null;
  session: Session | null;
  loading: boolean;
  isSuperAdmin: boolean;
  signInWithGoogle: () => Promise<void>;
  signInWithPassword: (email: string, password: string) => Promise<{ error: Error | null }>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  session: null,
  loading: true,
  isSuperAdmin: false,
  signInWithGoogle: async () => {},
  signInWithPassword: async () => ({ error: null }),
  signOut: async () => {},
});

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);

  const previousUserId = React.useRef<string | null>(null);

  useEffect(() => {
    if (!supabase) {
      setLoading(false);
      return;
    }

    const handleSession = async (currentSession: Session | null) => {
      setSession(currentSession);
      const currentUser = currentSession?.user ?? null;
      
      if (previousUserId.current !== (currentUser?.id ?? null)) {
        previousUserId.current = currentUser?.id ?? null;
        
        if (currentUser?.email) {
          const adminStatus = await checkIsSuperAdmin(currentUser.email);
          setIsSuperAdmin(adminStatus);
        } else {
          setIsSuperAdmin(false);
        }
        
        setUser(currentUser);
      }
      
      setLoading(false);
    };

    // Check active session
    supabase.auth.getSession().then(({ data: { session } }) => {
      handleSession(session);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      // Don't set loading to true on every event (like token refreshes on tab switch)
      // to avoid full page reloads/spinners.
      handleSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signInWithGoogle = async () => {
    if (!supabase) {
      alert("Supabase is not configured. Please add keys to .env.local");
      return;
    }
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
      }
    });
  };

  const signInWithPassword = async (email: string, password: string) => {
    if (!supabase) return { error: new Error("Supabase is not configured.") };
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error };
  };

  const signOut = async () => {
    if (!supabase) return;
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, session, loading, isSuperAdmin, signInWithGoogle, signInWithPassword, signOut }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
