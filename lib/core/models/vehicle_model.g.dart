// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 8;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      transporterId: fields[1] as String,
      vehicleType: fields[2] as VehicleType,
      plateNumber: fields[3] as String,
      capacityQuintals: fields[4] as double,
      model: fields[5] as String,
      yearManufactured: fields[6] as int?,
      isActive: fields[7] as bool,
      condition: fields[8] as VehicleCondition,
      registeredAt: fields[9] as DateTime,
      lastMaintenanceDate: fields[10] as DateTime?,
      imageUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transporterId)
      ..writeByte(2)
      ..write(obj.vehicleType)
      ..writeByte(3)
      ..write(obj.plateNumber)
      ..writeByte(4)
      ..write(obj.capacityQuintals)
      ..writeByte(5)
      ..write(obj.model)
      ..writeByte(6)
      ..write(obj.yearManufactured)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.condition)
      ..writeByte(9)
      ..write(obj.registeredAt)
      ..writeByte(10)
      ..write(obj.lastMaintenanceDate)
      ..writeByte(11)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleTypeAdapter extends TypeAdapter<VehicleType> {
  @override
  final int typeId = 14;

  @override
  VehicleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleType.truck;
      case 1:
        return VehicleType.pickup;
      case 2:
        return VehicleType.miniTruck;
      case 3:
        return VehicleType.lorry;
      default:
        return VehicleType.truck;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleType obj) {
    switch (obj) {
      case VehicleType.truck:
        writer.writeByte(0);
        break;
      case VehicleType.pickup:
        writer.writeByte(1);
        break;
      case VehicleType.miniTruck:
        writer.writeByte(2);
        break;
      case VehicleType.lorry:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleConditionAdapter extends TypeAdapter<VehicleCondition> {
  @override
  final int typeId = 15;

  @override
  VehicleCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleCondition.excellent;
      case 1:
        return VehicleCondition.good;
      case 2:
        return VehicleCondition.fair;
      case 3:
        return VehicleCondition.needsMaintenance;
      default:
        return VehicleCondition.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleCondition obj) {
    switch (obj) {
      case VehicleCondition.excellent:
        writer.writeByte(0);
        break;
      case VehicleCondition.good:
        writer.writeByte(1);
        break;
      case VehicleCondition.fair:
        writer.writeByte(2);
        break;
      case VehicleCondition.needsMaintenance:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
