// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmerAdapter extends TypeAdapter<Farmer> {
  @override
  final int typeId = 0;

  @override
  Farmer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Farmer(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      woreda: fields[3] as String,
      kebele: fields[4] as String,
      cooperativeName: fields[5] as String?,
      registeredAt: fields[6] as DateTime,
      farmIds: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Farmer obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.woreda)
      ..writeByte(4)
      ..write(obj.kebele)
      ..writeByte(5)
      ..write(obj.cooperativeName)
      ..writeByte(6)
      ..write(obj.registeredAt)
      ..writeByte(7)
      ..write(obj.farmIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
