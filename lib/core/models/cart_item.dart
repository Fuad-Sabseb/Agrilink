import 'package:hive/hive.dart';
import '../../models/produce_model.dart';
import 'crop_plot_model.dart';

part 'cart_item.g.dart';

/// Cart Item Model - Represents an item in the shopping cart
@HiveType(typeId: 30)
class CartItem {
  @HiveField(0)
  final String produceId;

  @HiveField(1)
  final String produceName;

  @HiveField(2)
  final String farmerId;

  @HiveField(3)
  final String farmerName;

  @HiveField(4)
  final double pricePerUnit;

  @HiveField(5)
  final double quantity;

  @HiveField(6)
  final String unit;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final DateTime addedAt;

  @HiveField(9)
  final double availableQuantity;

  @HiveField(10)
  final CropType cropType;

  CartItem({
    required this.produceId,
    required this.produceName,
    required this.farmerId,
    required this.farmerName,
    required this.pricePerUnit,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    required this.addedAt,
    required this.availableQuantity,
    required this.cropType,
  });

  // Calculate total price for this cart item
  double get totalPrice => pricePerUnit * quantity;

  // Check if quantity is valid
  bool get isValidQuantity => quantity > 0 && quantity <= availableQuantity;

  // Create from ProduceModel
  factory CartItem.fromProduce(ProduceModel produce, double quantity) {
    // Convert string cropType to CropType enum
    CropType parsedCropType = CropType.other;
    try {
      parsedCropType = CropType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == produce.cropType.toLowerCase(),
        orElse: () => CropType.other,
      );
    } catch (e) {
      parsedCropType = CropType.other;
    }

    return CartItem(
      produceId: produce.id,
      produceName: produce.cropName,
      farmerId: produce.farmerId,
      farmerName: produce.farmerName,
      pricePerUnit: produce.pricePerUnit,
      quantity: quantity,
      unit: produce.unit,
      imageUrl: (produce.imageUrls != null && produce.imageUrls!.isNotEmpty) 
          ? produce.imageUrls!.first 
          : produce.imageUrl,
      addedAt: DateTime.now(),
      availableQuantity: produce.quantity,
      cropType: parsedCropType,
    );
  }

  // Copy with new quantity
  CartItem copyWith({
    String? produceId,
    String? produceName,
    String? farmerId,
    String? farmerName,
    double? pricePerUnit,
    double? quantity,
    String? unit,
    String? imageUrl,
    DateTime? addedAt,
    double? availableQuantity,
    CropType? cropType,
  }) {
    return CartItem(
      produceId: produceId ?? this.produceId,
      produceName: produceName ?? this.produceName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      cropType: cropType ?? this.cropType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          produceId == other.produceId;

  @override
  int get hashCode => produceId.hashCode;
}
