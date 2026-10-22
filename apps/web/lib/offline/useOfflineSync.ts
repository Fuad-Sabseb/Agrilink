'use client';

import { useState, useEffect, useCallback } from 'react';
import { offlineStorage, CachedPriceItem } from './offline-storage';

const LAST_SYNC_KEY = 'agrilink_last_sync_timestamp';

export interface UseOfflineSyncResult {
  isOnline: boolean;
  lastSyncTime: Date | null;
  isSyncing: boolean;
  pendingCount: number;
  syncNow: () => Promise<void>;
  cachedPriceCount: number;
}

export function useOfflineSync(apiBaseUrl: string = 'http://localhost:5001/api/v1'): UseOfflineSyncResult {
  const [isOnline, setIsOnline] = useState<boolean>(true);
  const [lastSyncTime, setLastSyncTime] = useState<Date | null>(null);
  const [isSyncing, setIsSyncing] = useState<boolean>(false);
  const [pendingCount, setPendingCount] = useState<number>(0);
  const [cachedPriceCount, setCachedPriceCount] = useState<number>(0);

  // 1. Initialize online state & read last sync time from localStorage
  useEffect(() => {
    if (typeof window === 'undefined') return;

    setIsOnline(navigator.onLine);

    const saved = localStorage.getItem(LAST_SYNC_KEY);
    if (saved) {
      setLastSyncTime(new Date(Number(saved)));
    }

    // Read initial queue status & cached price count
    offlineStorage.getPendingActions().then((actions) => setPendingCount(actions.length)).catch(() => {});
    offlineStorage.getAllCachedPrices().then((prices) => setCachedPriceCount(prices.length)).catch(() => {});
  }, []);

  // 2. Perform synchronization (reconciliation with backend)
  const syncNow = useCallback(async () => {
    if (typeof window === 'undefined' || !navigator.onLine || isSyncing) return;

    setIsSyncing(true);
    try {
      // A. Reconcile queued offline actions
      const pending = await offlineStorage.getPendingActions();
      for (const item of pending) {
        try {
          // If actions exist in syncQueue (e.g. offline orders/requests), post them to server
          await fetch(`${apiBaseUrl}/${item.action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item.payload),
          });
          await offlineStorage.markActionDone(item.id);
        } catch (err) {
          console.warn('[OfflineSync] Could not process item:', item.id, err);
        }
      }

      // B. Fetch fresh benchmark prices from Jimma Zone Decision Engine
      const res = await fetch(`${apiBaseUrl}/decision-engine/crops`);
      if (res.ok) {
        const data = await res.json();
        if (data.crops && Array.isArray(data.crops)) {
          const priceItems: CachedPriceItem[] = [];

          for (const crop of data.crops) {
            for (const mkt of crop.markets) {
              priceItems.push({
                id: `${mkt.marketCode}_${crop.cropName}`,
                marketCode: mkt.marketCode,
                marketName: mkt.marketName,
                cropName: crop.cropName,
                cropNameAfaanOromoo: crop.cropNameAfaanOromoo || crop.cropName,
                pricePerKg: mkt.pricePerKg,
                trend: mkt.trend,
                updatedAt: new Date().toISOString(),
                cachedAt: Date.now(),
              });
            }
          }

          if (priceItems.length > 0) {
            await offlineStorage.savePrices(priceItems);
            setCachedPriceCount(priceItems.length);
          }
        }
      }

      const now = new Date();
      setLastSyncTime(now);
      localStorage.setItem(LAST_SYNC_KEY, String(now.getTime()));

      const remaining = await offlineStorage.getPendingActions();
      setPendingCount(remaining.length);
    } catch (error) {
      console.warn('[OfflineSync] Background sync encountered network variance:', error);
    } finally {
      setIsSyncing(false);
    }
  }, [apiBaseUrl, isSyncing]);

  // 3. Online / Offline window listeners & auto-reconnection sync
  useEffect(() => {
    if (typeof window === 'undefined') return;

    const handleOnline = () => {
      setIsOnline(true);
      // Automatically trigger background reconciliation sync
      syncNow();
    };

    const handleOffline = () => {
      setIsOnline(false);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Initial background sync if online and last sync is older than 1 hour or null
    if (navigator.onLine) {
      const saved = localStorage.getItem(LAST_SYNC_KEY);
      const isStale = !saved || Date.now() - Number(saved) > 3600 * 1000;
      if (isStale) {
        syncNow();
      }
    }

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [syncNow]);

  return {
    isOnline,
    lastSyncTime,
    isSyncing,
    pendingCount,
    syncNow,
    cachedPriceCount,
  };
}
