import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/price_model.dart';
import '../models/farm_model.dart';
import '../models/crop_plot_model.dart';
import '../network/api_client.dart';

/// Sync Service
/// Manages offline mode with Hive cache and automatic sync
class SyncService {
  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _connectivity = Connectivity();
  final _apiClient = ApiClient();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  final List<SyncOperation> _syncQueue = [];
  Timer? _syncTimer;

  // Hive boxes for offline cache
  Box<CropPrice>? _priceBox;
  Box<Farm>? _farmBox;
  Box? _cropPlotBox; // Generic box since CropPlot is embedded in Farm

  /// Initialize sync service
  Future<void> initialize() async {
    // Open Hive boxes for caching
    _priceBox = await Hive.openBox<CropPrice>('prices_cache');
    _farmBox = await Hive.openBox<Farm>('farms_cache');
    _cropPlotBox = await Hive.openBox('crop_plots_cache');

    // Monitor connectivity
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _onConnectivityChanged(results);
      },
    );

    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _onConnectivityChanged(results);

    // Start periodic sync timer (every 5 minutes when online)
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline) {
        syncAll();
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  // ==================== CONNECTIVITY ====================

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOffline = !_isOnline;
    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (_isOnline && wasOffline) {
      // Just came back online - sync pending operations
      _processSyncQueue();
    }
  }

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Check if device is offline
  bool get isOffline => !_isOnline;

  // ==================== PRICE DATA CACHING ====================

  /// Get prices (cache-first strategy)
  Future<List<CropPrice>> getPrices({
    String? cropType,
    String? marketId,
    bool forceRefresh = false,
  }) async {
    // Try cache first if offline or not forcing refresh
    if (isOffline || !forceRefresh) {
      final cachedPrices = _priceBox?.values.toList() ?? [];
      if (cachedPrices.isNotEmpty) {
        return _filterPrices(cachedPrices, cropType: cropType, marketId: marketId);
      }
    }

    // Fetch from API if online
    if (isOnline) {
      try {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/prices',
          queryParameters: {
            if (cropType != null) 'crop_type': cropType,
            if (marketId != null) 'market_id': marketId,
          },
        );

        if (response.isSuccess && response.data != null) {
          final prices = (response.data!['prices'] as List)
              .map((p) => CropPrice.fromJson(p as Map<String, dynamic>))
              .toList();

          // Cache prices
          await _cachePrices(prices);
          return prices;
        }
      } catch (e) {
        // Fall back to cache on error
      }
    }

    // Return cached data as fallback
    return _priceBox?.values.toList() ?? [];
  }

  Future<void> _cachePrices(List<CropPrice> prices) async {
    if (_priceBox == null) return;

    // Clear old cache
    await _priceBox!.clear();

    // Store new prices
    for (final price in prices) {
      await _priceBox!.put(price.id, price);
    }
  }

  List<CropPrice> _filterPrices(List<CropPrice> prices,
      {String? cropType, String? marketId}) {
    var filtered = prices;

    if (cropType != null) {
      filtered = filtered
          .where((p) => p.cropType.name == cropType.toLowerCase())
          .toList();
    }

    if (marketId != null) {
      filtered = filtered.where((p) => p.marketId == marketId).toList();
    }

    return filtered;
  }

  // ==================== FARM DATA CACHING ====================

  /// Get farms (cache-first strategy)
  Future<List<Farm>> getFarms(String userId, {bool forceRefresh = false}) async {
    // Try cache first if offline or not forcing refresh
    if (isOffline || !forceRefresh) {
      final cachedFarms = _farmBox?.values
          .where((f) => f.farmerId == userId)
          .toList() ?? [];
      if (cachedFarms.isNotEmpty) {
        return cachedFarms;
      }
    }

    // Fetch from API if online
    if (isOnline) {
      try {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/farms',
          queryParameters: {'user_id': userId},
        );

        if (response.isSuccess && response.data != null) {
          final farms = (response.data!['farms'] as List)
              .map((f) => Farm.fromJson(f as Map<String, dynamic>))
              .toList();

          // Cache farms
          await _cacheFarms(farms);
          return farms;
        }
      } catch (e) {
        // Fall back to cache on error
      }
    }

    // Return cached data as fallback
    return _farmBox?.values.where((f) => f.farmerId == userId).toList() ?? [];
  }

  Future<void> _cacheFarms(List<Farm> farms) async {
    if (_farmBox == null) return;

    for (final farm in farms) {
      await _farmBox!.put(farm.id, farm);
    }
  }

  // ==================== CROP PLOT DATA CACHING ====================

  /// Get crop plots for a farm (from cached farm data)
  Future<List<CropPlot>> getCropPlots(String farmId,
      {bool forceRefresh = false}) async {
    // Get farm which contains crop plots
    final farms = _farmBox?.values
        .where((f) => f.id == farmId)
        .toList() ?? [];
    
    if (farms.isNotEmpty) {
      return farms.first.cropPlots;
    }

    // If online, try to fetch
    if (isOnline) {
      try {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/farms/$farmId',
        );

        if (response.isSuccess && response.data != null) {
          final farm = Farm.fromJson(response.data!);
          await _farmBox?.put(farm.id, farm);
          return farm.cropPlots;
        }
      } catch (e) {
        // Fall back to empty list
      }
    }

    return [];
  }

  // ==================== SYNC QUEUE MANAGEMENT ====================

  /// Queue an operation for sync when online
  Future<void> queueOperation(SyncOperation operation) async {
    _syncQueue.add(operation);

    // Try to sync immediately if online
    if (_isOnline) {
      await _processSyncQueue();
    }
  }

  /// Process pending sync operations
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || !_isOnline) return;

    final operationsToProcess = List<SyncOperation>.from(_syncQueue);
    _syncQueue.clear();

    for (final operation in operationsToProcess) {
      try {
        await _executeOperation(operation);
      } catch (e) {
        // Re-queue failed operations
        _syncQueue.add(operation);
      }
    }
  }

  Future<void> _executeOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.create:
        await _apiClient.post(operation.endpoint, data: operation.data);
        break;
      case SyncOperationType.update:
        await _apiClient.put(operation.endpoint, data: operation.data);
        break;
      case SyncOperationType.delete:
        await _apiClient.delete(operation.endpoint);
        break;
    }
  }

  /// Get pending sync count
  int get pendingSyncCount => _syncQueue.length;

  /// Check if there are pending syncs
  bool get hasPendingSync => _syncQueue.isNotEmpty;

  // ==================== MANUAL SYNC ====================

  /// Manually sync all data
  Future<SyncResult> syncAll() async {
    if (!_isOnline) {
      return SyncResult(
        success: false,
        message: 'Cannot sync while offline',
        syncedCount: 0,
      );
    }

    int syncedCount = 0;

    try {
      // Process pending operations
      await _processSyncQueue();
      syncedCount = _syncQueue.length;

      // Refresh cached data
      // This would typically fetch latest prices, farms, etc.

      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        syncedCount: syncedCount,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
        syncedCount: syncedCount,
      );
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _priceBox?.clear();
    await _farmBox?.clear();
    await _cropPlotBox?.clear();
  }
}

// ==================== MODELS ====================

/// Sync operation for queue
class SyncOperation {
  final SyncOperationType type;
  final String endpoint;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  SyncOperation({
    required this.type,
    required this.endpoint,
    this.data,
  }) : timestamp = DateTime.now();
}

enum SyncOperationType {
  create,
  update,
  delete,
}

/// Sync result
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
  });
}
