'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import { accessTokenHolder } from './access-token-holder';
import { tokenStorage } from './token-storage';
import { authApi, ApiError } from './api-client';
import type { AuthUser, LoginInput, RegisterInput } from './types';

interface AuthContextValue {
  user: AuthUser | null;
  /** True only while the initial silent-refresh-on-load check is running. */
  isLoading: boolean;
  login: (input: LoginInput) => Promise<AuthUser>;
  register: (input: RegisterInput) => Promise<AuthUser>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Session persistence across a page reload: no access token survives in
  // memory across a refresh, so on mount we try to trade the stored
  // refresh token for a fresh pair, then fetch /users/me to find out who
  // that resolves to. Any failure here means "not logged in", not an error
  // shown to the user — an expired/absent refresh token is a normal state.
  useEffect(() => {
    let cancelled = false;

    async function hydrate() {
      const refreshToken = tokenStorage.get();
      if (!refreshToken) {
        setIsLoading(false);
        return;
      }
      try {
        const tokens = await authApi.refresh(refreshToken);
        accessTokenHolder.set(tokens.accessToken);
        tokenStorage.set(tokens.refreshToken);
        const me = await authApi.me();
        if (!cancelled) setUser(me);
      } catch {
        accessTokenHolder.set(null);
        tokenStorage.clear();
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    hydrate();
    return () => {
      cancelled = true;
    };
  }, []);

  const login = useCallback(async (input: LoginInput) => {
    const result = await authApi.login(input);
    accessTokenHolder.set(result.accessToken);
    tokenStorage.set(result.refreshToken);
    setUser(result.user);
    return result.user;
  }, []);

  const register = useCallback(async (input: RegisterInput) => {
    const result = await authApi.register(input);
    accessTokenHolder.set(result.accessToken);
    tokenStorage.set(result.refreshToken);
    setUser(result.user);
    return result.user;
  }, []);

  const logout = useCallback(async () => {
    const refreshToken = tokenStorage.get();
    accessTokenHolder.set(null);
    tokenStorage.clear();
    setUser(null);
    if (refreshToken) {
      // Best-effort server-side revocation. The client-side state is
      // already cleared above regardless of whether this call succeeds —
      // a network failure here must not trap the user in a "logged out
      // locally but the button spins forever" state.
      try {
        await authApi.logout(refreshToken);
      } catch {
        // intentionally swallowed — see comment above
      }
    }
  }, []);

  const value = useMemo(
    () => ({ user, isLoading, login, register, logout }),
    [user, isLoading, login, register, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return ctx;
}

export { ApiError };
