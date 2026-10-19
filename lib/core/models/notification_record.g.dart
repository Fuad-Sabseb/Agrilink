// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationRecordAdapter extends TypeAdapter<NotificationRecord> {
  @override
  final int typeId = 35;

  @override
  NotificationRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationRecord(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      timestamp: fields[3] as DateTime,
      type: fields[4] as NotificationRecordType,
      read: fields[5] as bool,
      deepLink: fields[6] as String?,
      payload: (fields[7] as Map?)?.cast<String, dynamic>(),
      iconUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.read)
      ..writeByte(6)
      ..write(obj.deepLink)
      ..writeByte(7)
      ..write(obj.payload)
      ..writeByte(8)
      ..write(obj.iconUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationRecordTypeAdapter
    extends TypeAdapter<NotificationRecordType> {
  @override
  final int typeId = 36;

  @override
  NotificationRecordType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationRecordType.order;
      case 1:
        return NotificationRecordType.transport;
      case 2:
        return NotificationRecordType.priceAlert;
      case 3:
        return NotificationRecordType.system;
      case 4:
        return NotificationRecordType.marketing;
      default:
        return NotificationRecordType.order;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationRecordType obj) {
    switch (obj) {
      case NotificationRecordType.order:
        writer.writeByte(0);
        break;
      case NotificationRecordType.transport:
        writer.writeByte(1);
        break;
      case NotificationRecordType.priceAlert:
        writer.writeByte(2);
        break;
      case NotificationRecordType.system:
        writer.writeByte(3);
        break;
      case NotificationRecordType.marketing:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationRecordTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
