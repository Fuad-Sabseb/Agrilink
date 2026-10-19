// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuyerAdapter extends TypeAdapter<Buyer> {
  @override
  final int typeId = 5;

  @override
  Buyer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Buyer(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      businessName: fields[3] as String,
      buyerType: fields[4] as BuyerType,
      location: fields[5] as String,
      isVerified: fields[6] as bool,
      reliabilityScore: fields[7] as double,
      totalTransactions: fields[8] as int,
      successfulTransactions: fields[9] as int,
      registeredAt: fields[10] as DateTime,
      lastActiveAt: fields[11] as DateTime?,
      profileImageUrl: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Buyer obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.businessName)
      ..writeByte(4)
      ..write(obj.buyerType)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.isVerified)
      ..writeByte(7)
      ..write(obj.reliabilityScore)
      ..writeByte(8)
      ..write(obj.totalTransactions)
      ..writeByte(9)
      ..write(obj.successfulTransactions)
      ..writeByte(10)
      ..write(obj.registeredAt)
      ..writeByte(11)
      ..write(obj.lastActiveAt)
      ..writeByte(12)
      ..write(obj.profileImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuyerTypeAdapter extends TypeAdapter<BuyerType> {
  @override
  final int typeId = 12;

  @override
  BuyerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuyerType.wholesaler;
      case 1:
        return BuyerType.processor;
      case 2:
        return BuyerType.exporter;
      case 3:
        return BuyerType.retailer;
      case 4:
        return BuyerType.cooperative;
      default:
        return BuyerType.wholesaler;
    }
  }

  @override
  void write(BinaryWriter writer, BuyerType obj) {
    switch (obj) {
      case BuyerType.wholesaler:
        writer.writeByte(0);
        break;
      case BuyerType.processor:
        writer.writeByte(1);
        break;
      case BuyerType.exporter:
        writer.writeByte(2);
        break;
      case BuyerType.retailer:
        writer.writeByte(3);
        break;
      case BuyerType.cooperative:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
