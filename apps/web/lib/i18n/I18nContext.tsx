'use client';

import React, { createContext, useContext, useEffect, useState, useMemo } from 'react';

// Import translation bundles directly for synchronous, flicker-free rendering
import omCommon from '../../locales/om/common.json';
import omRecs from '../../locales/om/recommendations.json';
import amCommon from '../../locales/am/common.json';
import amRecs from '../../locales/am/recommendations.json';
import enCommon from '../../locales/en/common.json';
import enRecs from '../../locales/en/recommendations.json';

export type SupportedLocale = 'om' | 'am' | 'en';

export interface LocaleInfo {
  code: SupportedLocale;
  name: string;
  nativeName: string;
  flag: string;
}

export const SUPPORTED_LOCALES: LocaleInfo[] = [
  { code: 'om', name: 'Oromo', nativeName: 'Afaan Oromoo', flag: '🌳' },
  { code: 'am', name: 'Amharic', nativeName: 'አማርኛ', flag: '🇪🇹' },
  { code: 'en', name: 'English', nativeName: 'English', flag: '🌍' },
];

type TranslationTree = Record<string, unknown>;

const TRANSLATIONS: Record<SupportedLocale, { common: TranslationTree; recommendations: TranslationTree }> = {
  om: { common: omCommon as TranslationTree, recommendations: omRecs as TranslationTree },
  am: { common: amCommon as TranslationTree, recommendations: amRecs as TranslationTree },
  en: { common: enCommon as TranslationTree, recommendations: enRecs as TranslationTree },
};

interface I18nContextValue {
  locale: SupportedLocale;
  setLocale: (locale: SupportedLocale) => void;
  t: (key: string, params?: Record<string, string | number>) => string;
  isLoaded: boolean;
}

const I18nContext = createContext<I18nContextValue | null>(null);

const STORAGE_KEY = 'agrilink_locale';

export function I18nProvider({ children }: { children: React.ReactNode }) {
  // Afaan Oromoo is the first-class default language for Jimma Zone
  const [locale, setLocaleState] = useState<SupportedLocale>('om');
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY) as SupportedLocale | null;
      if (saved && (saved === 'om' || saved === 'am' || saved === 'en')) {
        setLocaleState(saved);
      } else {
        // Default to Afaan Oromoo
        localStorage.setItem(STORAGE_KEY, 'om');
      }
    } catch {
      // Ignore storage errors (private mode)
    } finally {
      setIsLoaded(true);
    }
  }, []);

  const setLocale = (newLocale: SupportedLocale) => {
    setLocaleState(newLocale);
    try {
      localStorage.setItem(STORAGE_KEY, newLocale);
      document.documentElement.lang = newLocale;
    } catch {
      // Ignore
    }
  };

  const t = useMemo(() => {
    return (path: string, params?: Record<string, string | number>): string => {
      const parts = path.split('.');
      const namespace = (parts[0] || 'common') as 'common' | 'recommendations';
      const keys = parts.slice(1);

      const bundle = TRANSLATIONS[locale]?.[namespace] || TRANSLATIONS.en[namespace];
      let value: unknown = bundle;

      for (const k of keys) {
        if (value && typeof value === 'object' && k in (value as Record<string, unknown>)) {
          value = (value as Record<string, unknown>)[k];
        } else {
          // Fallback to English
          const fallbackBundle = TRANSLATIONS.en[namespace];
          let fbVal: unknown = fallbackBundle;
          for (const fbk of keys) {
            fbVal =
              fbVal && typeof fbVal === 'object' && fbk in (fbVal as Record<string, unknown>)
                ? (fbVal as Record<string, unknown>)[fbk]
                : undefined;
          }
          value = fbVal ?? path;
          break;
        }
      }

      if (typeof value !== 'string') {
        return path;
      }

      if (params) {
        return value.replace(/\{(\w+)\}/g, (_, token) => {
          return params[token] !== undefined ? String(params[token]) : `{${token}}`;
        });
      }

      return value;
    };
  }, [locale]);

  return (
    <I18nContext.Provider value={{ locale, setLocale, t, isLoaded }}>
      {children}
    </I18nContext.Provider>
  );
}

export function useTranslation() {
  const context = useContext(I18nContext);
  if (!context) {
    throw new Error('useTranslation must be used within an I18nProvider');
  }
  return context;
}
