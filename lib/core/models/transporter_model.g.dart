// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transporter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransporterAdapter extends TypeAdapter<Transporter> {
  @override
  final int typeId = 7;

  @override
  Transporter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transporter(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      businessName: fields[3] as String,
      baseLocation: fields[4] as String,
      isVerified: fields[5] as bool,
      rating: fields[6] as double,
      totalTrips: fields[7] as int,
      completedTrips: fields[8] as int,
      standardRoutes: (fields[9] as List).cast<String>(),
      registeredAt: fields[10] as DateTime,
      lastActiveAt: fields[11] as DateTime?,
      isAvailable: fields[12] as bool,
      licenseNumber: fields[13] as String?,
      profileImageUrl: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transporter obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.businessName)
      ..writeByte(4)
      ..write(obj.baseLocation)
      ..writeByte(5)
      ..write(obj.isVerified)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.totalTrips)
      ..writeByte(8)
      ..write(obj.completedTrips)
      ..writeByte(9)
      ..write(obj.standardRoutes)
      ..writeByte(10)
      ..write(obj.registeredAt)
      ..writeByte(11)
      ..write(obj.lastActiveAt)
      ..writeByte(12)
      ..write(obj.isAvailable)
      ..writeByte(13)
      ..write(obj.licenseNumber)
      ..writeByte(14)
      ..write(obj.profileImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransporterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
