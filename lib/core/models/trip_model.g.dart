// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 21;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trip(
      id: fields[0] as String,
      transportRequestId: fields[1] as String,
      farmerId: fields[2] as String,
      transporterId: fields[3] as String,
      vehicleId: fields[4] as String,
      routeId: fields[5] as String,
      cropType: fields[6] as CropType,
      quantityKg: fields[7] as double,
      pickupLocation: fields[8] as String,
      deliveryLocation: fields[9] as String,
      totalCost: fields[10] as double,
      status: fields[11] as TripStatus,
      createdAt: fields[12] as DateTime,
      scheduledPickupTime: fields[13] as DateTime?,
      actualPickupTime: fields[14] as DateTime?,
      estimatedArrivalTime: fields[15] as DateTime?,
      actualDeliveryTime: fields[16] as DateTime?,
      currentLocation: fields[17] as String?,
      currentDistanceKm: fields[18] as double?,
      farmerNotes: fields[19] as String?,
      transporterNotes: fields[20] as String?,
      farmerRating: fields[21] as double?,
      transporterRating: fields[22] as double?,
      statusUpdates: (fields[23] as List?)?.cast<TripStatusUpdate>(),
    );
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transportRequestId)
      ..writeByte(2)
      ..write(obj.farmerId)
      ..writeByte(3)
      ..write(obj.transporterId)
      ..writeByte(4)
      ..write(obj.vehicleId)
      ..writeByte(5)
      ..write(obj.routeId)
      ..writeByte(6)
      ..write(obj.cropType)
      ..writeByte(7)
      ..write(obj.quantityKg)
      ..writeByte(8)
      ..write(obj.pickupLocation)
      ..writeByte(9)
      ..write(obj.deliveryLocation)
      ..writeByte(10)
      ..write(obj.totalCost)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.scheduledPickupTime)
      ..writeByte(14)
      ..write(obj.actualPickupTime)
      ..writeByte(15)
      ..write(obj.estimatedArrivalTime)
      ..writeByte(16)
      ..write(obj.actualDeliveryTime)
      ..writeByte(17)
      ..write(obj.currentLocation)
      ..writeByte(18)
      ..write(obj.currentDistanceKm)
      ..writeByte(19)
      ..write(obj.farmerNotes)
      ..writeByte(20)
      ..write(obj.transporterNotes)
      ..writeByte(21)
      ..write(obj.farmerRating)
      ..writeByte(22)
      ..write(obj.transporterRating)
      ..writeByte(23)
      ..write(obj.statusUpdates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripStatusUpdateAdapter extends TypeAdapter<TripStatusUpdate> {
  @override
  final int typeId = 23;

  @override
  TripStatusUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripStatusUpdate(
      status: fields[0] as TripStatus,
      timestamp: fields[1] as DateTime,
      note: fields[2] as String?,
      location: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TripStatusUpdate obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripStatusUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripStatusAdapter extends TypeAdapter<TripStatus> {
  @override
  final int typeId = 22;

  @override
  TripStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripStatus.matched;
      case 1:
        return TripStatus.pickedUp;
      case 2:
        return TripStatus.inTransit;
      case 3:
        return TripStatus.delivered;
      case 4:
        return TripStatus.cancelled;
      default:
        return TripStatus.matched;
    }
  }

  @override
  void write(BinaryWriter writer, TripStatus obj) {
    switch (obj) {
      case TripStatus.matched:
        writer.writeByte(0);
        break;
      case TripStatus.pickedUp:
        writer.writeByte(1);
        break;
      case TripStatus.inTransit:
        writer.writeByte(2);
        break;
      case TripStatus.delivered:
        writer.writeByte(3);
        break;
      case TripStatus.cancelled:
        writer.writeByte(4);
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
