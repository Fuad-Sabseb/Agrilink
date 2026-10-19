// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionOperationAdapter extends TypeAdapter<InspectionOperation> {
  @override
  final int typeId = 31;

  @override
  InspectionOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionOperation(
      id: fields[0] as String,
      type: fields[1] as InspectionOperationType,
      data: (fields[2] as Map).cast<String, dynamic>(),
      timestamp: fields[3] as DateTime,
      retryCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionOperation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionOperationTypeAdapter
    extends TypeAdapter<InspectionOperationType> {
  @override
  final int typeId = 32;

  @override
  InspectionOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionOperationType.createInspection;
      case 1:
        return InspectionOperationType.checkIn;
      case 2:
        return InspectionOperationType.addFinding;
      case 3:
        return InspectionOperationType.updateFinding;
      case 4:
        return InspectionOperationType.deleteFinding;
      case 5:
        return InspectionOperationType.uploadPhoto;
      case 6:
        return InspectionOperationType.completeInspection;
      default:
        return InspectionOperationType.createInspection;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionOperationType obj) {
    switch (obj) {
      case InspectionOperationType.createInspection:
        writer.writeByte(0);
        break;
      case InspectionOperationType.checkIn:
        writer.writeByte(1);
        break;
      case InspectionOperationType.addFinding:
        writer.writeByte(2);
        break;
      case InspectionOperationType.updateFinding:
        writer.writeByte(3);
        break;
      case InspectionOperationType.deleteFinding:
        writer.writeByte(4);
        break;
      case InspectionOperationType.uploadPhoto:
        writer.writeByte(5);
        break;
      case InspectionOperationType.completeInspection:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
