// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionAdapter extends TypeAdapter<Inspection> {
  @override
  final int typeId = 26;

  @override
  Inspection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inspection(
      id: fields[0] as String,
      officerId: fields[1] as String,
      officerName: fields[2] as String,
      type: fields[3] as InspectionType,
      cooperativeId: fields[4] as String?,
      cooperativeName: fields[5] as String?,
      farmId: fields[6] as String?,
      farmName: fields[7] as String?,
      woredaId: fields[8] as String,
      woredaName: fields[9] as String,
      checkInTime: fields[10] as DateTime,
      checkOutTime: fields[11] as DateTime?,
      status: fields[12] as InspectionStatus,
      notes: fields[13] as String?,
      findings: (fields[14] as List).cast<InspectionFinding>(),
      latitude: fields[15] as double?,
      longitude: fields[16] as double?,
      photoUrls: (fields[17] as List).cast<String>(),
      signature: fields[18] as String?,
      farmersInterviewed: fields[19] as int,
      estimatedCropVolume: fields[20] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Inspection obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.officerId)
      ..writeByte(2)
      ..write(obj.officerName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.cooperativeId)
      ..writeByte(5)
      ..write(obj.cooperativeName)
      ..writeByte(6)
      ..write(obj.farmId)
      ..writeByte(7)
      ..write(obj.farmName)
      ..writeByte(8)
      ..write(obj.woredaId)
      ..writeByte(9)
      ..write(obj.woredaName)
      ..writeByte(10)
      ..write(obj.checkInTime)
      ..writeByte(11)
      ..write(obj.checkOutTime)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.findings)
      ..writeByte(15)
      ..write(obj.latitude)
      ..writeByte(16)
      ..write(obj.longitude)
      ..writeByte(17)
      ..write(obj.photoUrls)
      ..writeByte(18)
      ..write(obj.signature)
      ..writeByte(19)
      ..write(obj.farmersInterviewed)
      ..writeByte(20)
      ..write(obj.estimatedCropVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionFindingAdapter extends TypeAdapter<InspectionFinding> {
  @override
  final int typeId = 27;

  @override
  InspectionFinding read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionFinding(
      id: fields[0] as String,
      category: fields[1] as String,
      description: fields[2] as String,
      severity: fields[3] as FindingSeverity,
      recommendation: fields[4] as String?,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionFinding obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.severity)
      ..writeByte(4)
      ..write(obj.recommendation)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionFindingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionTypeAdapter extends TypeAdapter<InspectionType> {
  @override
  final int typeId = 28;

  @override
  InspectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionType.routine;
      case 1:
        return InspectionType.followUp;
      case 2:
        return InspectionType.complaint;
      case 3:
        return InspectionType.preHarvest;
      case 4:
        return InspectionType.postHarvest;
      case 5:
        return InspectionType.emergency;
      default:
        return InspectionType.routine;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionType obj) {
    switch (obj) {
      case InspectionType.routine:
        writer.writeByte(0);
        break;
      case InspectionType.followUp:
        writer.writeByte(1);
        break;
      case InspectionType.complaint:
        writer.writeByte(2);
        break;
      case InspectionType.preHarvest:
        writer.writeByte(3);
        break;
      case InspectionType.postHarvest:
        writer.writeByte(4);
        break;
      case InspectionType.emergency:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionStatusAdapter extends TypeAdapter<InspectionStatus> {
  @override
  final int typeId = 29;

  @override
  InspectionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionStatus.scheduled;
      case 1:
        return InspectionStatus.inProgress;
      case 2:
        return InspectionStatus.completed;
      case 3:
        return InspectionStatus.cancelled;
      default:
        return InspectionStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionStatus obj) {
    switch (obj) {
      case InspectionStatus.scheduled:
        writer.writeByte(0);
        break;
      case InspectionStatus.inProgress:
        writer.writeByte(1);
        break;
      case InspectionStatus.completed:
        writer.writeByte(2);
        break;
      case InspectionStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FindingSeverityAdapter extends TypeAdapter<FindingSeverity> {
  @override
  final int typeId = 30;

  @override
  FindingSeverity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FindingSeverity.minor;
      case 1:
        return FindingSeverity.moderate;
      case 2:
        return FindingSeverity.major;
      case 3:
        return FindingSeverity.critical;
      default:
        return FindingSeverity.minor;
    }
  }

  @override
  void write(BinaryWriter writer, FindingSeverity obj) {
    switch (obj) {
      case FindingSeverity.minor:
        writer.writeByte(0);
        break;
      case FindingSeverity.moderate:
        writer.writeByte(1);
        break;
      case FindingSeverity.major:
        writer.writeByte(2);
        break;
      case FindingSeverity.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindingSeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
