// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      phone: fields[2] as String,
      password: fields[3] as String,
      role: fields[4] as String,
      location: fields[5] as String,
      createdAt: fields[6] as DateTime,
      email: fields[7] as String?,
      woreda: fields[8] as String?,
      kebele: fields[9] as String?,
      cooperativeName: fields[10] as String?,
      isVerified: fields[11] as bool,
      lastLoginAt: fields[12] as DateTime?,
      roleData: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.woreda)
      ..writeByte(9)
      ..write(obj.kebele)
      ..writeByte(10)
      ..write(obj.cooperativeName)
      ..writeByte(11)
      ..write(obj.isVerified)
      ..writeByte(12)
      ..write(obj.lastLoginAt)
      ..writeByte(13)
      ..write(obj.roleData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
