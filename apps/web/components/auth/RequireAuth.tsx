'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../lib/auth/AuthContext';
import type { UserRole } from '../../lib/auth/types';

interface RequireAuthProps {
  children: React.ReactNode;
  allowRoles?: UserRole[];
}

/**
 * Wraps a page. While the initial silent-refresh check is running, shows a
 * loading state rather than flashing the protected content or bouncing to
 * /login prematurely. Enforced only client-side for now — this is a UX
 * guard, not the security boundary; the real authorization boundary is the
 * API's JwtAuthGuard/RolesGuard, which cannot be bypassed by disabling
 * JavaScript or editing this component (proposal rule 10).
 */
export function RequireAuth({ children, allowRoles }: RequireAuthProps) {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;
    if (!user) {
      router.replace('/login');
      return;
    }
    if (allowRoles && !allowRoles.includes(user.role)) {
      router.replace('/app');
    }
  }, [isLoading, user, allowRoles, router]);

  if (isLoading || !user || (allowRoles && !allowRoles.includes(user.role))) {
    return (
      <div className="min-h-screen bg-agrilink-green-dark flex items-center justify-center">
        <span
          className="h-8 w-8 rounded-full border-2 border-white/30 border-t-agrilink-gold animate-spin"
          aria-label="Loading"
        />
      </div>
    );
  }

  return <>{children}</>;
}
