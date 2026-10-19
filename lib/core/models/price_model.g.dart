// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CropPriceAdapter extends TypeAdapter<CropPrice> {
  @override
  final int typeId = 4;

  @override
  CropPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CropPrice(
      id: fields[0] as String,
      marketId: fields[1] as String,
      cropType: fields[2] as CropType,
      grade: fields[3] as QualityGrade,
      pricePerKg: fields[4] as double,
      recordedAt: fields[5] as DateTime,
      source: fields[6] as String,
      priceChangePercent: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CropPrice obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.marketId)
      ..writeByte(2)
      ..write(obj.cropType)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.pricePerKg)
      ..writeByte(5)
      ..write(obj.recordedAt)
      ..writeByte(6)
      ..write(obj.source)
      ..writeByte(7)
      ..write(obj.priceChangePercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
