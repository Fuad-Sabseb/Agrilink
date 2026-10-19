'use client';

import { SelectHTMLAttributes, forwardRef } from 'react';

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  error?: string;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, className = '', id, children, ...rest }, ref) => {
    const selectId = id ?? rest.name;
    return (
      <div className="w-full">
        <label
          htmlFor={selectId}
          className="block text-xs font-medium uppercase tracking-wide text-white/60 mb-1.5"
        >
          {label}
        </label>
        <div
          className={`rounded-full bg-white/[0.07] border ${
            error ? 'border-agrilink-error' : 'border-white/15'
          } focus-within:border-agrilink-gold px-4 py-3`}
        >
          <select
            ref={ref}
            id={selectId}
            className={`bg-transparent outline-none text-white text-sm w-full [&>option]:bg-agrilink-green-dark ${className}`}
            aria-invalid={!!error}
            {...rest}
          >
            {children}
          </select>
        </div>
        {error && <p className="mt-1.5 text-xs text-agrilink-error">{error}</p>}
      </div>
    );
  },
);
Select.displayName = 'Select';
