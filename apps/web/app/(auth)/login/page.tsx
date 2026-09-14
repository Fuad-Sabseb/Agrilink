'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth, ApiError } from '../../../lib/auth/AuthContext';
import { Card } from '../../../components/ui/Card';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';

const PHONE_PATTERN = /^\+251[79]\d{8}$/;

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();

  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<{ phone?: string; password?: string }>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  function validate(): boolean {
    const errors: typeof fieldErrors = {};
    if (!PHONE_PATTERN.test(phoneNumber)) {
      errors.phone = 'Enter a valid Ethiopian number, e.g. +251912345678';
    }
    if (password.length < 8) {
      errors.password = 'Password must be at least 8 characters';
    }
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    if (!validate()) return;

    setIsSubmitting(true);
    try {
      await login({ phoneNumber, password });
      router.push('/app');
    } catch (err) {
      setFormError(
        err instanceof ApiError
          ? err.message
          : 'Something went wrong. Please try again.',
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="min-h-screen bg-agrilink-green-dark flex flex-col items-center justify-center px-6 py-12">
      <div className="w-full max-w-sm space-y-6">
        <div className="text-center space-y-1">
          <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-agrilink-green text-2xl">
            🌾
          </div>
          <h1 className="text-xl font-bold text-white tracking-wide">AgriLink</h1>
          <p className="text-xs text-white/50">Jimma Zone · Oromia · Ethiopia</p>
        </div>

        <Card>
          <form onSubmit={handleSubmit} noValidate className="space-y-4">
            <h2 className="text-white text-lg font-semibold">Log in</h2>

            {formError && <Alert variant="error">{formError}</Alert>}

            <Input
              label="Phone number"
              name="phoneNumber"
              type="tel"
              inputMode="tel"
              autoComplete="tel"
              placeholder="912345678"
              prefix="+251"
              value={phoneNumber.replace(/^\+251/, '')}
              onChange={(e) => setPhoneNumber(`+251${e.target.value.replace(/\D/g, '')}`)}
              error={fieldErrors.phone}
              disabled={isSubmitting}
            />

            <Input
              label="Password"
              name="password"
              type="password"
              autoComplete="current-password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={fieldErrors.password}
              disabled={isSubmitting}
            />

            <Button type="submit" isLoading={isSubmitting}>
              {isSubmitting ? 'Logging in…' : 'Log in'}
            </Button>

            <p className="text-center text-sm text-white/60">
              Don&apos;t have an account?{' '}
              <Link href="/register" className="text-agrilink-gold font-medium">
                Register
              </Link>
            </p>
          </form>
        </Card>
      </div>
    </main>
  );
}
