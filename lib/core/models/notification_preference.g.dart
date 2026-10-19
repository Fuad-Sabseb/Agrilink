// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationPreferenceAdapter
    extends TypeAdapter<NotificationPreference> {
  @override
  final int typeId = 12;

  @override
  NotificationPreference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationPreference(
      type: fields[0] as NotificationType,
      enabled: fields[1] as bool,
      soundEnabled: fields[2] as bool,
      customSound: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationPreference obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.enabled)
      ..writeByte(2)
      ..write(obj.soundEnabled)
      ..writeByte(3)
      ..write(obj.customSound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
