// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 30;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      produceId: fields[0] as String,
      produceName: fields[1] as String,
      farmerId: fields[2] as String,
      farmerName: fields[3] as String,
      pricePerUnit: fields[4] as double,
      quantity: fields[5] as double,
      unit: fields[6] as String,
      imageUrl: fields[7] as String?,
      addedAt: fields[8] as DateTime,
      availableQuantity: fields[9] as double,
      cropType: fields[10] as CropType,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.produceId)
      ..writeByte(1)
      ..write(obj.produceName)
      ..writeByte(2)
      ..write(obj.farmerId)
      ..writeByte(3)
      ..write(obj.farmerName)
      ..writeByte(4)
      ..write(obj.pricePerUnit)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.addedAt)
      ..writeByte(9)
      ..write(obj.availableQuantity)
      ..writeByte(10)
      ..write(obj.cropType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
