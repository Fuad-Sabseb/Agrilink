'use client';

import Link from 'next/link';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../lib/auth/AuthContext';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

export default function Home() {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && user) {
      router.replace('/app');
    }
  }, [isLoading, user, router]);

  return (
    <main className="min-h-screen bg-agrilink-green-dark text-white flex flex-col items-center justify-center px-6">
      <Card className="max-w-sm text-center space-y-4">
        <h1 className="text-2xl font-bold tracking-wide">AgriLink</h1>
        <p className="text-sm text-white/70">
          Market intelligence, buyers, and logistics for Jimma Zone farmers.
        </p>

        {!isLoading && !user && (
          <div className="space-y-3 pt-2">
            <Link href="/login">
              <Button variant="primary">Log in</Button>
            </Link>
            <Link href="/register">
              <Button variant="secondary">Create an account</Button>
            </Link>
          </div>
        )}

        <div className="pt-2">
          <span className="inline-block rounded-full bg-agrilink-gold text-agrilink-green-dark text-xs font-semibold px-4 py-1">
            DEMO DATA
          </span>
        </div>
      </Card>
    </main>
  );
}
