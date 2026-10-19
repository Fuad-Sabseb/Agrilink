// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 30;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      type: fields[4] as NotificationType,
      priority: fields[5] as NotificationPriority,
      isRead: fields[6] as bool,
      readAt: fields[7] as DateTime?,
      actionUrl: fields[8] as String?,
      data: (fields[9] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.readAt)
      ..writeByte(8)
      ..write(obj.actionUrl)
      ..writeByte(9)
      ..write(obj.data)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 31;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.order;
      case 1:
        return NotificationType.transport;
      case 2:
        return NotificationType.produce;
      case 3:
        return NotificationType.system;
      case 4:
        return NotificationType.marketing;
      default:
        return NotificationType.order;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.order:
        writer.writeByte(0);
        break;
      case NotificationType.transport:
        writer.writeByte(1);
        break;
      case NotificationType.produce:
        writer.writeByte(2);
        break;
      case NotificationType.system:
        writer.writeByte(3);
        break;
      case NotificationType.marketing:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 32;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.normal:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
