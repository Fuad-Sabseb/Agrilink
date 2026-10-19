// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteAdapter extends TypeAdapter<Route> {
  @override
  final int typeId = 9;

  @override
  Route read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Route(
      id: fields[0] as String,
      origin: fields[1] as String,
      destination: fields[2] as String,
      distanceKm: fields[3] as double,
      baseCostPerKm: fields[4] as double,
      costPerTonKm: fields[5] as double,
      checkpoints: (fields[6] as List).cast<Checkpoint>(),
      estimatedDurationHours: fields[7] as double,
      condition: fields[8] as RouteCondition,
      lastUpdated: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Route obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.origin)
      ..writeByte(2)
      ..write(obj.destination)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.baseCostPerKm)
      ..writeByte(5)
      ..write(obj.costPerTonKm)
      ..writeByte(6)
      ..write(obj.checkpoints)
      ..writeByte(7)
      ..write(obj.estimatedDurationHours)
      ..writeByte(8)
      ..write(obj.condition)
      ..writeByte(9)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CheckpointAdapter extends TypeAdapter<Checkpoint> {
  @override
  final int typeId = 16;

  @override
  Checkpoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Checkpoint(
      name: fields[0] as String,
      distanceFromOriginKm: fields[1] as double,
      fee: fields[2] as double,
      type: fields[3] as CheckpointType,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Checkpoint obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.distanceFromOriginKm)
      ..writeByte(2)
      ..write(obj.fee)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckpointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RouteConditionAdapter extends TypeAdapter<RouteCondition> {
  @override
  final int typeId = 17;

  @override
  RouteCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RouteCondition.excellent;
      case 1:
        return RouteCondition.good;
      case 2:
        return RouteCondition.fair;
      case 3:
        return RouteCondition.poor;
      case 4:
        return RouteCondition.seasonal;
      default:
        return RouteCondition.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, RouteCondition obj) {
    switch (obj) {
      case RouteCondition.excellent:
        writer.writeByte(0);
        break;
      case RouteCondition.good:
        writer.writeByte(1);
        break;
      case RouteCondition.fair:
        writer.writeByte(2);
        break;
      case RouteCondition.poor:
        writer.writeByte(3);
        break;
      case RouteCondition.seasonal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CheckpointTypeAdapter extends TypeAdapter<CheckpointType> {
  @override
  final int typeId = 18;

  @override
  CheckpointType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CheckpointType.inspection;
      case 1:
        return CheckpointType.toll;
      case 2:
        return CheckpointType.weighbridge;
      case 3:
        return CheckpointType.police;
      default:
        return CheckpointType.inspection;
    }
  }

  @override
  void write(BinaryWriter writer, CheckpointType obj) {
    switch (obj) {
      case CheckpointType.inspection:
        writer.writeByte(0);
        break;
      case CheckpointType.toll:
        writer.writeByte(1);
        break;
      case CheckpointType.weighbridge:
        writer.writeByte(2);
        break;
      case CheckpointType.police:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckpointTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
