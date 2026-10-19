// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 2;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      produceId: fields[1] as String,
      produceName: fields[2] as String,
      buyerId: fields[3] as String,
      buyerName: fields[4] as String,
      farmerId: fields[5] as String,
      farmerName: fields[6] as String,
      quantityOrdered: fields[7] as double,
      unit: fields[8] as String,
      pricePerUnit: fields[9] as double,
      totalPrice: fields[10] as double,
      status: fields[11] as String,
      pickupLocation: fields[12] as String,
      deliveryLocation: fields[13] as String,
      deliveryInstructions: fields[14] as String?,
      transportRequestId: fields[15] as String?,
      estimatedDeliveryDate: fields[16] as DateTime?,
      actualDeliveryDate: fields[17] as DateTime?,
      paymentMethod: fields[18] as String,
      paymentStatus: fields[19] as String,
      cancellationReason: fields[20] as String?,
      createdAt: fields[21] as DateTime,
      updatedAt: fields[22] as DateTime?,
      confirmedAt: fields[23] as DateTime?,
      completedAt: fields[24] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.produceId)
      ..writeByte(2)
      ..write(obj.produceName)
      ..writeByte(3)
      ..write(obj.buyerId)
      ..writeByte(4)
      ..write(obj.buyerName)
      ..writeByte(5)
      ..write(obj.farmerId)
      ..writeByte(6)
      ..write(obj.farmerName)
      ..writeByte(7)
      ..write(obj.quantityOrdered)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.pricePerUnit)
      ..writeByte(10)
      ..write(obj.totalPrice)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.pickupLocation)
      ..writeByte(13)
      ..write(obj.deliveryLocation)
      ..writeByte(14)
      ..write(obj.deliveryInstructions)
      ..writeByte(15)
      ..write(obj.transportRequestId)
      ..writeByte(16)
      ..write(obj.estimatedDeliveryDate)
      ..writeByte(17)
      ..write(obj.actualDeliveryDate)
      ..writeByte(18)
      ..write(obj.paymentMethod)
      ..writeByte(19)
      ..write(obj.paymentStatus)
      ..writeByte(20)
      ..write(obj.cancellationReason)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt)
      ..writeByte(23)
      ..write(obj.confirmedAt)
      ..writeByte(24)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
