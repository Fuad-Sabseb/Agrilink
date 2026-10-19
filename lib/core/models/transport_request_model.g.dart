// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportRequestAdapter extends TypeAdapter<TransportRequest> {
  @override
  final int typeId = 19;

  @override
  TransportRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportRequest(
      id: fields[0] as String,
      farmerId: fields[1] as String,
      cropType: fields[2] as CropType,
      quantityKg: fields[3] as double,
      pickupLocation: fields[4] as String,
      deliveryLocation: fields[5] as String,
      requestedPickupDate: fields[6] as DateTime,
      status: fields[7] as RequestStatus,
      createdAt: fields[8] as DateTime,
      matchedAt: fields[9] as DateTime?,
      matchedTransporterId: fields[10] as String?,
      matchedVehicleId: fields[11] as String?,
      agreedPrice: fields[12] as double?,
      specialInstructions: fields[13] as String?,
      requiresRefrigeration: fields[14] as bool,
      responseTransporterIds: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TransportRequest obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmerId)
      ..writeByte(2)
      ..write(obj.cropType)
      ..writeByte(3)
      ..write(obj.quantityKg)
      ..writeByte(4)
      ..write(obj.pickupLocation)
      ..writeByte(5)
      ..write(obj.deliveryLocation)
      ..writeByte(6)
      ..write(obj.requestedPickupDate)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.matchedAt)
      ..writeByte(10)
      ..write(obj.matchedTransporterId)
      ..writeByte(11)
      ..write(obj.matchedVehicleId)
      ..writeByte(12)
      ..write(obj.agreedPrice)
      ..writeByte(13)
      ..write(obj.specialInstructions)
      ..writeByte(14)
      ..write(obj.requiresRefrigeration)
      ..writeByte(15)
      ..write(obj.responseTransporterIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 20;

  @override
  RequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RequestStatus.pending;
      case 1:
        return RequestStatus.matched;
      case 2:
        return RequestStatus.accepted;
      case 3:
        return RequestStatus.cancelled;
      case 4:
        return RequestStatus.expired;
      default:
        return RequestStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RequestStatus obj) {
    switch (obj) {
      case RequestStatus.pending:
        writer.writeByte(0);
        break;
      case RequestStatus.matched:
        writer.writeByte(1);
        break;
      case RequestStatus.accepted:
        writer.writeByte(2);
        break;
      case RequestStatus.cancelled:
        writer.writeByte(3);
        break;
      case RequestStatus.expired:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
