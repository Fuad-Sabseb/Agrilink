import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item.dart';
import '../models/crop_plot_model.dart';
import '../../models/produce_model.dart';

/// Cart Provider - Manages shopping cart state
class CartProvider with ChangeNotifier {
  Box<CartItem>? _cartBox;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Calculate total items quantity
  double get totalQuantity => _items.fold(0.0, (sum, item) => sum + item.quantity);

  // Calculate subtotal
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Calculate estimated delivery fee (mock - 10% of subtotal, min 50 ETB)
  double get deliveryFee => subtotal > 0 ? (subtotal * 0.1).clamp(50.0, 500.0) : 0.0;

  // Calculate tax (mock - 15% VAT)
  double get tax => subtotal * 0.15;

  // Calculate total
  double get total => subtotal + deliveryFee + tax;

  // Group items by farmer
  Map<String, List<CartItem>> get itemsByFarmer {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _items) {
      if (!grouped.containsKey(item.farmerId)) {
        grouped[item.farmerId] = [];
      }
      grouped[item.farmerId]!.add(item);
    }
    return grouped;
  }

  // Get farmer names
  Set<String> get farmerNames => _items.map((item) => item.farmerName).toSet();

  /// Initialize cart
  Future<void> initialize() async {
    try {
      _cartBox = await Hive.openBox<CartItem>('cart');
      _loadItems();
    } catch (e) {
      _error = 'Failed to initialize cart: $e';
      notifyListeners();
    }
  }

  /// Load items from Hive
  void _loadItems() {
    if (_cartBox == null || !_cartBox!.isOpen) {
      // Try to get the box if it's already open
      try {
        _cartBox = Hive.box<CartItem>('cart');
        _items = _cartBox!.values.toList();
      } catch (e) {
        _items = [];
      }
    } else {
      _items = _cartBox!.values.toList();
    }
    notifyListeners();
  }

  /// Add item to cart
  Future<bool> addItem(ProduceModel produce, double quantity) async {
    try {
      _error = null;

      // Check if item already exists
      final existingIndex = _items.indexWhere((item) => item.produceId == produce.id);

      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = _items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (newQuantity > produce.quantity) {
          _error = 'Cannot add more than available quantity';
          notifyListeners();
          return false;
        }

        final updatedItem = existingItem.copyWith(quantity: newQuantity);
        await _cartBox?.put(produce.id, updatedItem);
        _items[existingIndex] = updatedItem;
      } else {
        // Add new item
        if (quantity > produce.quantity) {
          _error = 'Cannot add more than available quantity';
          notifyListeners();
          return false;
        }

        final cartItem = CartItem.fromProduce(produce, quantity);
        await _cartBox?.put(produce.id, cartItem);
        _items.add(cartItem);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add item: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update item quantity
  Future<bool> updateQuantity(String produceId, double newQuantity) async {
    try {
      _error = null;

      final index = _items.indexWhere((item) => item.produceId == produceId);
      if (index < 0) return false;

      final item = _items[index];

      if (newQuantity <= 0) {
        // Remove item if quantity is 0
        return await removeItem(produceId);
      }

      if (newQuantity > item.availableQuantity) {
        _error = 'Quantity exceeds available stock';
        notifyListeners();
        return false;
      }

      final updatedItem = item.copyWith(quantity: newQuantity);
      await _cartBox?.put(produceId, updatedItem);
      _items[index] = updatedItem;

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeItem(String produceId) async {
    try {
      _error = null;

      await _cartBox?.delete(produceId);
      _items.removeWhere((item) => item.produceId == produceId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove item: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      _error = null;

      await _cartBox?.clear();
      _items.clear();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }

  /// Check if produce is in cart
  bool isInCart(String produceId) {
    return _items.any((item) => item.produceId == produceId);
  }

  /// Get item quantity in cart
  double getItemQuantity(String produceId) {
    final item = _items.firstWhere(
      (item) => item.produceId == produceId,
      orElse: () => CartItem(
        produceId: '',
        produceName: '',
        farmerId: '',
        farmerName: '',
        pricePerUnit: 0,
        quantity: 0,
        unit: '',
        addedAt: DateTime.now(),
        availableQuantity: 0,
        cropType: CropType.other,
      ),
    );
    return item.quantity;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cartBox?.close();
    super.dispose();
  }
}
