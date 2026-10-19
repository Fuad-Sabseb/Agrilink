// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmAdapter extends TypeAdapter<Farm> {
  @override
  final int typeId = 1;

  @override
  Farm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Farm(
      id: fields[0] as String,
      farmerId: fields[1] as String,
      farmName: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      totalHectares: fields[5] as double,
      woreda: fields[6] as String,
      kebele: fields[7] as String,
      cropPlots: (fields[8] as List).cast<CropPlot>(),
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Farm obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmerId)
      ..writeByte(2)
      ..write(obj.farmName)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.totalHectares)
      ..writeByte(6)
      ..write(obj.woreda)
      ..writeByte(7)
      ..write(obj.kebele)
      ..writeByte(8)
      ..write(obj.cropPlots)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
