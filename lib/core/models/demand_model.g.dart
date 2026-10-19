// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demand_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DemandAdapter extends TypeAdapter<Demand> {
  @override
  final int typeId = 6;

  @override
  Demand read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Demand(
      id: fields[0] as String,
      buyerId: fields[1] as String,
      cropType: fields[2] as CropType,
      preferredGrade: fields[3] as QualityGrade,
      minimumQuantityKg: fields[4] as double,
      maximumQuantityKg: fields[5] as double,
      priceOfferPerKg: fields[6] as double,
      status: fields[7] as BuyingStatus,
      pickupLocation: fields[8] as String,
      createdAt: fields[9] as DateTime,
      expiresAt: fields[10] as DateTime,
      additionalNotes: fields[11] as String?,
      transportProvided: fields[12] as bool,
      acceptedGrades: (fields[13] as List?)?.cast<QualityGrade>(),
      viewCount: fields[14] as int,
      responseCount: fields[15] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Demand obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.buyerId)
      ..writeByte(2)
      ..write(obj.cropType)
      ..writeByte(3)
      ..write(obj.preferredGrade)
      ..writeByte(4)
      ..write(obj.minimumQuantityKg)
      ..writeByte(5)
      ..write(obj.maximumQuantityKg)
      ..writeByte(6)
      ..write(obj.priceOfferPerKg)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.pickupLocation)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.expiresAt)
      ..writeByte(11)
      ..write(obj.additionalNotes)
      ..writeByte(12)
      ..write(obj.transportProvided)
      ..writeByte(13)
      ..write(obj.acceptedGrades)
      ..writeByte(14)
      ..write(obj.viewCount)
      ..writeByte(15)
      ..write(obj.responseCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuyingStatusAdapter extends TypeAdapter<BuyingStatus> {
  @override
  final int typeId = 13;

  @override
  BuyingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuyingStatus.buyingNow;
      case 1:
        return BuyingStatus.paused;
      case 2:
        return BuyingStatus.filled;
      case 3:
        return BuyingStatus.expired;
      default:
        return BuyingStatus.buyingNow;
    }
  }

  @override
  void write(BinaryWriter writer, BuyingStatus obj) {
    switch (obj) {
      case BuyingStatus.buyingNow:
        writer.writeByte(0);
        break;
      case BuyingStatus.paused:
        writer.writeByte(1);
        break;
      case BuyingStatus.filled:
        writer.writeByte(2);
        break;
      case BuyingStatus.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
