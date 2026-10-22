'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useTranslation, SUPPORTED_LOCALES, SupportedLocale } from '../../lib/i18n/I18nContext';

interface LanguageSwitcherProps {
  className?: string;
  variant?: 'compact' | 'full';
}

export function LanguageSwitcher({ className = '', variant = 'compact' }: LanguageSwitcherProps) {
  const { locale, setLocale } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const activeLocale = SUPPORTED_LOCALES.find((l) => l.code === locale) || SUPPORTED_LOCALES[0];

  // Close on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className={`relative inline-block text-left ${className}`} ref={dropdownRef}>
      <button
        type="button"
        onClick={() => setIsOpen((prev) => !prev)}
        className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 hover:bg-white/15 border border-white/20 text-white text-xs font-medium transition-all shadow-sm focus:outline-none focus:ring-2 focus:ring-agrilink-gold"
        aria-expanded={isOpen}
        aria-haspopup="true"
        aria-label={`Current language: ${activeLocale.nativeName}. Click to change language.`}
      >
        <span aria-hidden="true" className="text-sm">
          {activeLocale.flag}
        </span>
        <span className="font-semibold text-agrilink-gold">
          {variant === 'compact' ? activeLocale.code.toUpperCase() : activeLocale.nativeName}
        </span>
        <svg
          className={`w-3.5 h-3.5 text-white/70 transition-transform ${isOpen ? 'rotate-180' : ''}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      {isOpen && (
        <div
          className="absolute right-0 mt-2 w-48 rounded-xl bg-agrilink-green-dark border border-agrilink-gold/30 shadow-2xl py-1 z-50 animate-in fade-in zoom-in-95 duration-100 backdrop-blur-md"
          role="menu"
          aria-orientation="vertical"
        >
          <div className="px-3 py-1.5 text-[10px] uppercase font-bold tracking-wider text-agrilink-gold/80 border-b border-white/10">
            Afaan / ቋንቋ / Language
          </div>
          {SUPPORTED_LOCALES.map((item) => {
            const isSelected = item.code === locale;
            return (
              <button
                key={item.code}
                type="button"
                onClick={() => {
                  setLocale(item.code as SupportedLocale);
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between px-3 py-2 text-xs text-left transition-colors ${
                  isSelected
                    ? 'bg-agrilink-gold/20 text-agrilink-gold font-semibold'
                    : 'text-white/80 hover:bg-white/10 hover:text-white'
                }`}
                role="menuitem"
              >
                <div className="flex items-center gap-2.5">
                  <span className="text-base" aria-hidden="true">
                    {item.flag}
                  </span>
                  <div>
                    <div className="font-medium">{item.nativeName}</div>
                    <div className="text-[10px] text-white/40">{item.name}</div>
                  </div>
                </div>
                {isSelected && (
                  <svg className="w-4 h-4 text-agrilink-gold" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                      clipRule="evenodd"
                    />
                  </svg>
                )}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
