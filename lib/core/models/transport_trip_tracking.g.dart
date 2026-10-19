// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_trip_tracking.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportTripTrackingAdapter extends TypeAdapter<TransportTripTracking> {
  @override
  final int typeId = 14;

  @override
  TransportTripTracking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportTripTracking(
      tripId: fields[0] as String,
      transporterId: fields[1] as String,
      startLatitude: fields[2] as double,
      startLongitude: fields[3] as double,
      destinationLatitude: fields[4] as double,
      destinationLongitude: fields[5] as double,
      startTime: fields[6] as DateTime,
      locationHistoryIds: (fields[7] as List).cast<String>(),
      trackingIntervalSeconds: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TransportTripTracking obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.tripId)
      ..writeByte(1)
      ..write(obj.transporterId)
      ..writeByte(2)
      ..write(obj.startLatitude)
      ..writeByte(3)
      ..write(obj.startLongitude)
      ..writeByte(4)
      ..write(obj.destinationLatitude)
      ..writeByte(5)
      ..write(obj.destinationLongitude)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.locationHistoryIds)
      ..writeByte(8)
      ..write(obj.statusIndex)
      ..writeByte(9)
      ..write(obj.trackingIntervalSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportTripTrackingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripStatusAdapter extends TypeAdapter<TripStatus> {
  @override
  final int typeId = 18;

  @override
  TripStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripStatus.active;
      case 1:
        return TripStatus.completed;
      case 2:
        return TripStatus.cancelled;
      default:
        return TripStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, TripStatus obj) {
    switch (obj) {
      case TripStatus.active:
        writer.writeByte(0);
        break;
      case TripStatus.completed:
        writer.writeByte(1);
        break;
      case TripStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
