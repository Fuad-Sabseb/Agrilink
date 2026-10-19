// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_location.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmLocationAdapter extends TypeAdapter<FarmLocation> {
  @override
  final int typeId = 13;

  @override
  FarmLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmLocation(
      farmId: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      address: fields[3] as String?,
      woredaId: fields[4] as String,
      registeredAt: fields[5] as DateTime,
      sourceIndex: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FarmLocation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.farmId)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.woredaId)
      ..writeByte(5)
      ..write(obj.registeredAt)
      ..writeByte(6)
      ..write(obj.sourceIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationSourceAdapter extends TypeAdapter<LocationSource> {
  @override
  final int typeId = 17;

  @override
  LocationSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LocationSource.gps;
      case 1:
        return LocationSource.manual;
      case 2:
        return LocationSource.network;
      default:
        return LocationSource.gps;
    }
  }

  @override
  void write(BinaryWriter writer, LocationSource obj) {
    switch (obj) {
      case LocationSource.gps:
        writer.writeByte(0);
        break;
      case LocationSource.manual:
        writer.writeByte(1);
        break;
      case LocationSource.network:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
