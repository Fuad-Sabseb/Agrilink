// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_plot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CropPlotAdapter extends TypeAdapter<CropPlot> {
  @override
  final int typeId = 2;

  @override
  CropPlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CropPlot(
      id: fields[0] as String,
      cropType: fields[1] as CropType,
      hectares: fields[2] as double,
      expectedGrade: fields[3] as QualityGrade,
      expectedYieldPerHectare: fields[4] as double,
      plantingDate: fields[5] as DateTime,
      expectedHarvestDate: fields[6] as DateTime,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CropPlot obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cropType)
      ..writeByte(2)
      ..write(obj.hectares)
      ..writeByte(3)
      ..write(obj.expectedGrade)
      ..writeByte(4)
      ..write(obj.expectedYieldPerHectare)
      ..writeByte(5)
      ..write(obj.plantingDate)
      ..writeByte(6)
      ..write(obj.expectedHarvestDate)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropPlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CropTypeAdapter extends TypeAdapter<CropType> {
  @override
  final int typeId = 10;

  @override
  CropType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CropType.coffee;
      case 1:
        return CropType.maize;
      case 2:
        return CropType.teff;
      case 3:
        return CropType.wheat;
      case 4:
        return CropType.potato;
      case 5:
        return CropType.sorghum;
      case 6:
        return CropType.barley;
      case 7:
        return CropType.beans;
      case 8:
        return CropType.other;
      default:
        return CropType.coffee;
    }
  }

  @override
  void write(BinaryWriter writer, CropType obj) {
    switch (obj) {
      case CropType.coffee:
        writer.writeByte(0);
        break;
      case CropType.maize:
        writer.writeByte(1);
        break;
      case CropType.teff:
        writer.writeByte(2);
        break;
      case CropType.wheat:
        writer.writeByte(3);
        break;
      case CropType.potato:
        writer.writeByte(4);
        break;
      case CropType.sorghum:
        writer.writeByte(5);
        break;
      case CropType.barley:
        writer.writeByte(6);
        break;
      case CropType.beans:
        writer.writeByte(7);
        break;
      case CropType.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QualityGradeAdapter extends TypeAdapter<QualityGrade> {
  @override
  final int typeId = 11;

  @override
  QualityGrade read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QualityGrade.premium;
      case 1:
        return QualityGrade.grade1;
      case 2:
        return QualityGrade.grade2;
      case 3:
        return QualityGrade.grade3;
      case 4:
        return QualityGrade.standard;
      default:
        return QualityGrade.premium;
    }
  }

  @override
  void write(BinaryWriter writer, QualityGrade obj) {
    switch (obj) {
      case QualityGrade.premium:
        writer.writeByte(0);
        break;
      case QualityGrade.grade1:
        writer.writeByte(1);
        break;
      case QualityGrade.grade2:
        writer.writeByte(2);
        break;
      case QualityGrade.grade3:
        writer.writeByte(3);
        break;
      case QualityGrade.standard:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityGradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
