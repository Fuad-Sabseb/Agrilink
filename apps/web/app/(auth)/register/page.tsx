'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth, ApiError } from '../../../lib/auth/AuthContext';
import type { PreferredLanguage, UserRole } from '../../../lib/auth/types';
import { Card } from '../../../components/ui/Card';
import { Input } from '../../../components/ui/Input';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { StepDots } from '../../../components/ui/StepDots';
import { RoleOption } from '../../../components/auth/RoleOption';

const PHONE_PATTERN = /^\+251[79]\d{8}$/;
const TOTAL_STEPS = 3;

// Only the three self-registrable roles the proposal defines (§6) — admin
// accounts are provisioned out of band and the API rejects them here
// anyway (defense in depth: this list is also why there's no "Admin" tile
// to tap in the first place).
const ROLE_OPTIONS: { role: UserRole; label: string; description: string; icon: string }[] = [
  { role: 'farmer', label: 'Farmer', description: 'Sell crops, see market prices', icon: '🌾' },
  { role: 'buyer', label: 'Buyer', description: 'Find and buy from farmers', icon: '🧺' },
  { role: 'transporter', label: 'Transporter', description: 'Move produce, earn per trip', icon: '🚚' },
];

const LANGUAGE_OPTIONS: { value: PreferredLanguage; label: string }[] = [
  { value: 'om', label: 'Afaan Oromoo' },
  { value: 'am', label: 'Amharic' },
  { value: 'en', label: 'English' },
];

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();

  const [step, setStep] = useState(1);
  const [role, setRole] = useState<UserRole | null>(null);
  const [fullName, setFullName] = useState('');
  const [phoneDigits, setPhoneDigits] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [preferredLanguage, setPreferredLanguage] = useState<PreferredLanguage>('om');

  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const phoneNumber = `+251${phoneDigits}`;

  function validateStep2(): boolean {
    const errors: Record<string, string> = {};
    if (fullName.trim().length < 2) errors.fullName = 'Enter your full name';
    if (!PHONE_PATTERN.test(phoneNumber)) {
      errors.phone = 'Enter a valid Ethiopian number, e.g. +251912345678';
    }
    if (password.length < 8) errors.password = 'Password must be at least 8 characters';
    if (password !== confirmPassword) errors.confirmPassword = 'Passwords do not match';
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  function goNext() {
    setFormError(null);
    if (step === 1) {
      if (!role) {
        setFormError('Choose an account type to continue');
        return;
      }
      setStep(2);
      return;
    }
    if (step === 2) {
      if (!validateStep2()) return;
      setStep(3);
    }
  }

  function goBack() {
    setFormError(null);
    setStep((s) => Math.max(1, s - 1));
  }

  async function handleSubmit() {
    if (!role) return;
    setFormError(null);
    setIsSubmitting(true);
    try {
      await register({ phoneNumber, fullName: fullName.trim(), password, role, preferredLanguage });
      router.push('/app');
    } catch (err) {
      setFormError(
        err instanceof ApiError ? err.message : 'Something went wrong. Please try again.',
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
          <h1 className="text-xl font-bold text-white tracking-wide">Create your account</h1>
          <p className="text-xs text-white/50">Jimma Zone · Oromia · Ethiopia</p>
        </div>

        <StepDots total={TOTAL_STEPS} current={step} />

        <Card>
          {formError && (
            <div className="mb-4">
              <Alert variant="error">{formError}</Alert>
            </div>
          )}

          {step === 1 && (
            <div className="space-y-4">
              <h2 className="text-white text-lg font-semibold">
                Step 1 · Choose account type
              </h2>
              <div className="space-y-3">
                {ROLE_OPTIONS.map((opt) => (
                  <RoleOption
                    key={opt.role}
                    label={opt.label}
                    description={opt.description}
                    icon={opt.icon}
                    selected={role === opt.role}
                    onSelect={() => setRole(opt.role)}
                  />
                ))}
              </div>
              <Button type="button" onClick={goNext}>
                Continue
              </Button>
            </div>
          )}

          {step === 2 && (
            <div className="space-y-4">
              <h2 className="text-white text-lg font-semibold">
                Step 2 · Your information
              </h2>
              <Input
                label="Full name"
                name="fullName"
                autoComplete="name"
                placeholder="Tolosa Bekele"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                error={fieldErrors.fullName}
                disabled={isSubmitting}
              />
              <Input
                label="Phone number"
                name="phoneNumber"
                type="tel"
                inputMode="tel"
                autoComplete="tel"
                placeholder="912345678"
                prefix="+251"
                value={phoneDigits}
                onChange={(e) => setPhoneDigits(e.target.value.replace(/\D/g, ''))}
                error={fieldErrors.phone}
                disabled={isSubmitting}
              />
              <Input
                label="Password"
                name="password"
                type="password"
                autoComplete="new-password"
                placeholder="At least 8 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                error={fieldErrors.password}
                disabled={isSubmitting}
              />
              <Input
                label="Confirm password"
                name="confirmPassword"
                type="password"
                autoComplete="new-password"
                placeholder="Re-enter password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                error={fieldErrors.confirmPassword}
                disabled={isSubmitting}
              />

              <div>
                <span className="block text-xs font-medium uppercase tracking-wide text-white/60 mb-1.5">
                  Preferred language
                </span>
                <div className="flex gap-2">
                  {LANGUAGE_OPTIONS.map((opt) => (
                    <button
                      key={opt.value}
                      type="button"
                      onClick={() => setPreferredLanguage(opt.value)}
                      className={`flex-1 rounded-full border px-2 py-2 text-xs font-medium transition-colors ${
                        preferredLanguage === opt.value
                          ? 'border-agrilink-gold bg-agrilink-gold/10 text-agrilink-gold'
                          : 'border-white/15 text-white/60 hover:bg-white/5'
                      }`}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex gap-3 pt-1">
                <Button type="button" variant="secondary" onClick={goBack}>
                  Back
                </Button>
                <Button type="button" onClick={goNext}>
                  Continue
                </Button>
              </div>
            </div>
          )}

          {step === 3 && role && (
            <div className="space-y-4">
              <h2 className="text-white text-lg font-semibold">Step 3 · Review</h2>
              <dl className="space-y-2 text-sm">
                <ReviewRow label="Account type" value={ROLE_OPTIONS.find((r) => r.role === role)?.label ?? role} />
                <ReviewRow label="Full name" value={fullName} />
                <ReviewRow label="Phone number" value={phoneNumber} />
                <ReviewRow
                  label="Preferred language"
                  value={LANGUAGE_OPTIONS.find((l) => l.value === preferredLanguage)?.label ?? preferredLanguage}
                />
              </dl>
              <div className="flex gap-3 pt-1">
                <Button type="button" variant="secondary" onClick={goBack} disabled={isSubmitting}>
                  Back
                </Button>
                <Button type="button" onClick={handleSubmit} isLoading={isSubmitting}>
                  {isSubmitting ? 'Creating account…' : 'Complete registration'}
                </Button>
              </div>
            </div>
          )}

          <p className="text-center text-sm text-white/60 pt-5">
            Already have an account?{' '}
            <Link href="/login" className="text-agrilink-gold font-medium">
              Log in
            </Link>
          </p>
        </Card>
      </div>
    </main>
  );
}

function ReviewRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between border-b border-white/10 pb-2">
      <dt className="text-white/50">{label}</dt>
      <dd className="text-white font-medium">{value}</dd>
    </div>
  );
}
