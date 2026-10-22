// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_rate_limit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationRateLimitAdapter extends TypeAdapter<NotificationRateLimit> {
  @override
  final int typeId = 15;

  @override
  NotificationRateLimit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationRateLimit(
      typeIndex: fields[0] as int,
      recentNotifications: (fields[1] as List).cast<DateTime>(),
      maxPerMinute: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationRateLimit obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.typeIndex)
      ..writeByte(1)
      ..write(obj.recentNotifications)
      ..writeByte(2)
      ..write(obj.maxPerMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationRateLimitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
