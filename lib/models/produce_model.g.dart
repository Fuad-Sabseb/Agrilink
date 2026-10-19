// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produce_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProduceModelAdapter extends TypeAdapter<ProduceModel> {
  @override
  final int typeId = 1;

  @override
  ProduceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProduceModel(
      id: fields[0] as String,
      farmerId: fields[1] as String,
      farmerName: fields[2] as String,
      cropName: fields[3] as String,
      cropType: fields[4] as String,
      quantity: fields[5] as double,
      unit: fields[6] as String,
      pricePerUnit: fields[7] as double,
      description: fields[8] as String,
      status: fields[9] as String,
      qualityGrade: fields[10] as String?,
      harvestDate: fields[11] as DateTime?,
      location: fields[12] as String,
      imageUrl: fields[13] as String?,
      imageUrls: (fields[14] as List?)?.cast<String>(),
      isOrganic: fields[15] as bool,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProduceModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmerId)
      ..writeByte(2)
      ..write(obj.farmerName)
      ..writeByte(3)
      ..write(obj.cropName)
      ..writeByte(4)
      ..write(obj.cropType)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.pricePerUnit)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.qualityGrade)
      ..writeByte(11)
      ..write(obj.harvestDate)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.imageUrls)
      ..writeByte(15)
      ..write(obj.isOrganic)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProduceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
