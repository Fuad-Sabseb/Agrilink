'use client';

import { InputHTMLAttributes, forwardRef } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  hint?: string;
  prefix?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, hint, prefix, className = '', id, ...rest }, ref) => {
    const inputId = id ?? rest.name;
    return (
      <div className="w-full">
        <label
          htmlFor={inputId}
          className="block text-xs font-medium uppercase tracking-wide text-white/60 mb-1.5"
        >
          {label}
        </label>
        <div
          className={`flex items-center rounded-full bg-white/[0.07] border ${
            error ? 'border-agrilink-error' : 'border-white/15'
          } focus-within:border-agrilink-gold px-4 py-3`}
        >
          {prefix && (
            <span className="text-white/50 text-sm mr-2 select-none">
              {prefix}
            </span>
          )}
          <input
            ref={ref}
            id={inputId}
            className={`bg-transparent outline-none text-white placeholder-white/30 text-sm w-full ${className}`}
            aria-invalid={!!error}
            aria-describedby={error ? `${inputId}-error` : undefined}
            {...rest}
          />
        </div>
        {error ? (
          <p id={`${inputId}-error`} className="mt-1.5 text-xs text-agrilink-error">
            {error}
          </p>
        ) : hint ? (
          <p className="mt-1.5 text-xs text-white/40">{hint}</p>
        ) : null}
      </div>
    );
  },
);
Input.displayName = 'Input';
