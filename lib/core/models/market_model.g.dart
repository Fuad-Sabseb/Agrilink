// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketAdapter extends TypeAdapter<Market> {
  @override
  final int typeId = 3;

  @override
  Market read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Market(
      id: fields[0] as String,
      name: fields[1] as String,
      woreda: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      isPrimary: fields[5] as bool,
      distanceFromJimmaKm: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Market obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.woreda)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.isPrimary)
      ..writeByte(6)
      ..write(obj.distanceFromJimmaKm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
