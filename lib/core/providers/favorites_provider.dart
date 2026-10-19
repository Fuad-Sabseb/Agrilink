import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Favorites Provider - Manages user's favorite produce
class FavoritesProvider with ChangeNotifier {
  Box<List>? _favoritesBox;
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favoriteIds.length;
  bool get isEmpty => _favoriteIds.isEmpty;
  bool get isNotEmpty => _favoriteIds.isNotEmpty;

  /// Initialize favorites
  Future<void> initialize(String userId) async {
    try {
      _favoritesBox = await Hive.openBox<List>('favorites_$userId');
      _loadFavorites();
    } catch (e) {
      _error = 'Failed to initialize favorites: $e';
      notifyListeners();
    }
  }

  /// Load favorites from Hive
  void _loadFavorites() {
    if (_favoritesBox == null) return;
    final List<dynamic>? stored = _favoritesBox!.get('ids');
    if (stored != null) {
      _favoriteIds = stored.cast<String>().toSet();
    }
    notifyListeners();
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String produceId) async {
    try {
      _error = null;

      if (_favoriteIds.contains(produceId)) {
        _favoriteIds.remove(produceId);
      } else {
        _favoriteIds.add(produceId);
      }

      await _saveFavorites();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add to favorites
  Future<bool> addFavorite(String produceId) async {
    if (_favoriteIds.contains(produceId)) return true;

    try {
      _error = null;
      _favoriteIds.add(produceId);
      await _saveFavorites();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add favorite: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove from favorites
  Future<bool> removeFavorite(String produceId) async {
    if (!_favoriteIds.contains(produceId)) return true;

    try {
      _error = null;
      _favoriteIds.remove(produceId);
      await _saveFavorites();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove favorite: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if produce is favorite
  bool isFavorite(String produceId) {
    return _favoriteIds.contains(produceId);
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    try {
      _error = null;
      _favoriteIds.clear();
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear favorites: $e';
      notifyListeners();
    }
  }

  /// Save favorites to Hive
  Future<void> _saveFavorites() async {
    await _favoritesBox?.put('ids', _favoriteIds.toList());
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _favoritesBox?.close();
    super.dispose();
  }
}
