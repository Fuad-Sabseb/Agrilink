'use client';

import React from 'react';
import { useTranslation } from '../../lib/i18n/I18nContext';
import { useOfflineSync } from '../../lib/offline/useOfflineSync';

export function OfflineBanner() {
  const { t } = useTranslation();
  const { isOnline, lastSyncTime, isSyncing, syncNow, cachedPriceCount } = useOfflineSync();

  // If online and not syncing, no need to show persistent banner
  if (isOnline && !isSyncing) {
    return null;
  }

  const formatLastSync = (date: Date | null) => {
    if (!date) return '—';
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div
      className={`w-full px-4 py-2 text-xs transition-colors duration-200 border-b flex items-center justify-between gap-3 ${
        !isOnline
          ? 'bg-amber-950/90 border-amber-600/40 text-amber-200'
          : 'bg-emerald-950/90 border-emerald-600/40 text-emerald-200'
      }`}
      role="status"
      aria-live="polite"
    >
      <div className="flex items-center gap-2 flex-1 min-w-0">
        <span
          className={`w-2.5 h-2.5 rounded-full flex-shrink-0 ${
            !isOnline ? 'bg-amber-400 animate-pulse' : 'bg-emerald-400'
          }`}
          aria-hidden="true"
        />
        <div className="truncate">
          <span className="font-bold">
            {!isOnline
              ? t('offline.indicator', { defaultValue: 'Haala Toora Irraa Ala (Offline Mode)' })
              : t('offline.syncing', { defaultValue: 'Oodeeffannoo haaromsaa jira...' })}
          </span>
          <span className="opacity-80 ml-2 hidden sm:inline">
            · {t('offline.lastSync', { time: formatLastSync(lastSyncTime) })}
          </span>
          {cachedPriceCount > 0 && !isOnline && (
            <span className="opacity-70 ml-2 hidden md:inline">
              ({cachedPriceCount} gatiin gabaa kuufameera)
            </span>
          )}
        </div>
      </div>

      {isOnline ? (
        <span className="h-4 w-4 rounded-full border-2 border-white/20 border-t-white animate-spin flex-shrink-0" />
      ) : (
        <button
          type="button"
          onClick={() => syncNow()}
          disabled={isSyncing}
          className="px-2.5 py-1 rounded-md bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 font-semibold text-[11px] text-amber-200 flex-shrink-0 transition-colors"
        >
          {isSyncing ? '...' : t('offline.syncNow', { defaultValue: 'Amma Haaromsi' })}
        </button>
      )}
    </div>
  );
}
