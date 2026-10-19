// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bureau_officer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BureauOfficerAdapter extends TypeAdapter<BureauOfficer> {
  @override
  final int typeId = 24;

  @override
  BureauOfficer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BureauOfficer(
      id: fields[0] as String,
      fullName: fields[1] as String,
      employeeId: fields[2] as String,
      phoneNumber: fields[3] as String,
      email: fields[4] as String,
      rank: fields[5] as OfficerRank,
      bureauName: fields[6] as String,
      assignedWoredas: (fields[7] as List).cast<String>(),
      profileImageUrl: fields[8] as String?,
      joinDate: fields[9] as DateTime,
      isActive: fields[10] as bool,
      specialization: fields[11] as String?,
      completedInspections: fields[12] as int,
      lastInspectionDate: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BureauOfficer obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.employeeId)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.rank)
      ..writeByte(6)
      ..write(obj.bureauName)
      ..writeByte(7)
      ..write(obj.assignedWoredas)
      ..writeByte(8)
      ..write(obj.profileImageUrl)
      ..writeByte(9)
      ..write(obj.joinDate)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.specialization)
      ..writeByte(12)
      ..write(obj.completedInspections)
      ..writeByte(13)
      ..write(obj.lastInspectionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BureauOfficerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfficerRankAdapter extends TypeAdapter<OfficerRank> {
  @override
  final int typeId = 25;

  @override
  OfficerRank read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OfficerRank.fieldOfficer;
      case 1:
        return OfficerRank.seniorOfficer;
      case 2:
        return OfficerRank.supervisor;
      case 3:
        return OfficerRank.coordinator;
      case 4:
        return OfficerRank.director;
      default:
        return OfficerRank.fieldOfficer;
    }
  }

  @override
  void write(BinaryWriter writer, OfficerRank obj) {
    switch (obj) {
      case OfficerRank.fieldOfficer:
        writer.writeByte(0);
        break;
      case OfficerRank.seniorOfficer:
        writer.writeByte(1);
        break;
      case OfficerRank.supervisor:
        writer.writeByte(2);
        break;
      case OfficerRank.coordinator:
        writer.writeByte(3);
        break;
      case OfficerRank.director:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfficerRankAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
