// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aggregate_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AggregateReportAdapter extends TypeAdapter<AggregateReport> {
  @override
  final int typeId = 31;

  @override
  AggregateReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AggregateReport(
      id: fields[0] as String,
      woredaId: fields[1] as String,
      woredaName: fields[2] as String,
      zoneId: fields[3] as String?,
      zoneName: fields[4] as String?,
      reportDate: fields[5] as DateTime,
      period: fields[6] as ReportPeriod,
      cropVolumes: (fields[7] as List).cast<CropVolumeData>(),
      totalFarms: fields[8] as int,
      activeCooperatives: fields[9] as int,
      totalHectares: fields[10] as double,
      totalFarmers: fields[11] as int,
      generatedBy: fields[12] as String,
      generatedByName: fields[13] as String,
      notes: fields[14] as String?,
      metadata: (fields[15] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AggregateReport obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.woredaId)
      ..writeByte(2)
      ..write(obj.woredaName)
      ..writeByte(3)
      ..write(obj.zoneId)
      ..writeByte(4)
      ..write(obj.zoneName)
      ..writeByte(5)
      ..write(obj.reportDate)
      ..writeByte(6)
      ..write(obj.period)
      ..writeByte(7)
      ..write(obj.cropVolumes)
      ..writeByte(8)
      ..write(obj.totalFarms)
      ..writeByte(9)
      ..write(obj.activeCooperatives)
      ..writeByte(10)
      ..write(obj.totalHectares)
      ..writeByte(11)
      ..write(obj.totalFarmers)
      ..writeByte(12)
      ..write(obj.generatedBy)
      ..writeByte(13)
      ..write(obj.generatedByName)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregateReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CropVolumeDataAdapter extends TypeAdapter<CropVolumeData> {
  @override
  final int typeId = 32;

  @override
  CropVolumeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CropVolumeData(
      cropType: fields[0] as CropType,
      hectares: fields[1] as double,
      expectedVolume: fields[2] as double,
      actualVolume: fields[3] as double?,
      farmCount: fields[4] as int,
      averageGrade: fields[5] as QualityGrade?,
      averagePrice: fields[6] as double?,
      harvestStatus: fields[7] as HarvestStatus,
      estimatedHarvestDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CropVolumeData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.cropType)
      ..writeByte(1)
      ..write(obj.hectares)
      ..writeByte(2)
      ..write(obj.expectedVolume)
      ..writeByte(3)
      ..write(obj.actualVolume)
      ..writeByte(4)
      ..write(obj.farmCount)
      ..writeByte(5)
      ..write(obj.averageGrade)
      ..writeByte(6)
      ..write(obj.averagePrice)
      ..writeByte(7)
      ..write(obj.harvestStatus)
      ..writeByte(8)
      ..write(obj.estimatedHarvestDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropVolumeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportPeriodAdapter extends TypeAdapter<ReportPeriod> {
  @override
  final int typeId = 33;

  @override
  ReportPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportPeriod.weekly;
      case 1:
        return ReportPeriod.monthly;
      case 2:
        return ReportPeriod.quarterly;
      case 3:
        return ReportPeriod.seasonal;
      case 4:
        return ReportPeriod.annual;
      default:
        return ReportPeriod.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, ReportPeriod obj) {
    switch (obj) {
      case ReportPeriod.weekly:
        writer.writeByte(0);
        break;
      case ReportPeriod.monthly:
        writer.writeByte(1);
        break;
      case ReportPeriod.quarterly:
        writer.writeByte(2);
        break;
      case ReportPeriod.seasonal:
        writer.writeByte(3);
        break;
      case ReportPeriod.annual:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HarvestStatusAdapter extends TypeAdapter<HarvestStatus> {
  @override
  final int typeId = 34;

  @override
  HarvestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HarvestStatus.preHarvest;
      case 1:
        return HarvestStatus.inProgress;
      case 2:
        return HarvestStatus.completed;
      case 3:
        return HarvestStatus.delayed;
      default:
        return HarvestStatus.preHarvest;
    }
  }

  @override
  void write(BinaryWriter writer, HarvestStatus obj) {
    switch (obj) {
      case HarvestStatus.preHarvest:
        writer.writeByte(0);
        break;
      case HarvestStatus.inProgress:
        writer.writeByte(1);
        break;
      case HarvestStatus.completed:
        writer.writeByte(2);
        break;
      case HarvestStatus.delayed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HarvestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
