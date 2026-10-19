// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationUpdateAdapter extends TypeAdapter<LocationUpdate> {
  @override
  final int typeId = 10;

  @override
  LocationUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationUpdate(
      id: fields[0] as String,
      transportTripId: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      timestamp: fields[4] as DateTime,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocationUpdate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transportTripId)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
