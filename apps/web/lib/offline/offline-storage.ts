/**
 * Resilient Client-Side IndexedDB Storage Engine for AgriLink
 * Operates offline during rural network blackouts in Jimma Zone
 */

const DB_NAME = 'agrilink_offline_db';
const DB_VERSION = 1;

export interface CachedPriceItem {
  id: string; // e.g. "MKT_JIMMA_Potato"
  marketCode: string;
  marketName: string;
  cropName: string;
  cropNameAfaanOromoo: string;
  pricePerKg: number;
  trend: string;
  updatedAt: string;
  cachedAt: number;
}

export interface CachedRecommendationItem<T = unknown> {
  queryKey: string; // e.g. "farmId_cropId_qty" or "cropName_qty_woreda"
  result: T;
  cachedAt: number;
}

export interface QueuedSyncAction {
  id: string;
  action: string;
  payload: unknown;
  timestamp: number;
  status: 'pending' | 'syncing' | 'failed';
  retryCount: number;
}

class OfflineStorageEngine {
  private dbPromise: Promise<IDBDatabase> | null = null;

  private getDB(): Promise<IDBDatabase> {
    if (typeof window === 'undefined') {
      return Promise.reject(new Error('IndexedDB is not available on server'));
    }

    if (!this.dbPromise) {
      this.dbPromise = new Promise((resolve, reject) => {
        const request = window.indexedDB.open(DB_NAME, DB_VERSION);

        request.onupgradeneeded = (event) => {
          const db = (event.target as IDBOpenDBRequest).result;

          // 1. Cached Market Prices Store
          if (!db.objectStoreNames.contains('cachedPrices')) {
            const priceStore = db.createObjectStore('cachedPrices', { keyPath: 'id' });
            priceStore.createIndex('marketCode', 'marketCode', { unique: false });
            priceStore.createIndex('cropName', 'cropName', { unique: false });
          }

          // 2. Cached Recommendations Store
          if (!db.objectStoreNames.contains('cachedRecommendations')) {
            const recStore = db.createObjectStore('cachedRecommendations', { keyPath: 'queryKey' });
            recStore.createIndex('cachedAt', 'cachedAt', { unique: false });
          }

          // 3. Sync Queue Store
          if (!db.objectStoreNames.contains('syncQueue')) {
            const queueStore = db.createObjectStore('syncQueue', { keyPath: 'id' });
            queueStore.createIndex('status', 'status', { unique: false });
            queueStore.createIndex('timestamp', 'timestamp', { unique: false });
          }
        };

        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
      });
    }

    return this.dbPromise;
  }

  // ==================== Cached Prices ====================

  async savePrices(prices: CachedPriceItem[]): Promise<void> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('cachedPrices', 'readwrite');
      const store = tx.objectStore('cachedPrices');
      prices.forEach((item) => store.put(item));
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  async getAllCachedPrices(): Promise<CachedPriceItem[]> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('cachedPrices', 'readonly');
      const store = tx.objectStore('cachedPrices');
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result || []);
      request.onerror = () => reject(request.error);
    });
  }

  // ==================== Cached Recommendations ====================

  async saveRecommendation(queryKey: string, result: unknown): Promise<void> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('cachedRecommendations', 'readwrite');
      const store = tx.objectStore('cachedRecommendations');
      store.put({
        queryKey,
        result,
        cachedAt: Date.now(),
      });
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  async getCachedRecommendation<T = unknown>(queryKey: string): Promise<CachedRecommendationItem<T> | null> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('cachedRecommendations', 'readonly');
      const store = tx.objectStore('cachedRecommendations');
      const request = store.get(queryKey);
      request.onsuccess = () => resolve((request.result as CachedRecommendationItem<T>) || null);
      request.onerror = () => reject(request.error);
    });
  }

  // ==================== Sync Queue ====================

  async enqueueAction(action: string, payload: unknown): Promise<QueuedSyncAction> {
    const db = await this.getDB();
    const item: QueuedSyncAction = {
      id: `sync_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      action,
      payload,
      timestamp: Date.now(),
      status: 'pending',
      retryCount: 0,
    };

    return new Promise((resolve, reject) => {
      const tx = db.transaction('syncQueue', 'readwrite');
      const store = tx.objectStore('syncQueue');
      store.put(item);
      tx.oncomplete = () => resolve(item);
      tx.onerror = () => reject(tx.error);
    });
  }

  async getPendingActions(): Promise<QueuedSyncAction[]> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('syncQueue', 'readonly');
      const store = tx.objectStore('syncQueue');
      const request = store.getAll();
      request.onsuccess = () => {
        const items: QueuedSyncAction[] = request.result || [];
        resolve(items.filter((i) => i.status === 'pending' || i.status === 'failed'));
      };
      request.onerror = () => reject(request.error);
    });
  }

  async markActionDone(id: string): Promise<void> {
    const db = await this.getDB();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('syncQueue', 'readwrite');
      const store = tx.objectStore('syncQueue');
      store.delete(id);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }
}

export const offlineStorage = new OfflineStorageEngine();
