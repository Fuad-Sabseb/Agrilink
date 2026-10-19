// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportTransactionAdapter extends TypeAdapter<TransportTransaction> {
  @override
  final int typeId = 24;

  @override
  TransportTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportTransaction(
      id: fields[0] as String,
      jobId: fields[1] as String,
      transporterId: fields[2] as String,
      route: fields[3] as String,
      distanceKm: fields[4] as double,
      earnings: fields[5] as double,
      status: fields[6] as TransactionStatus,
      paymentMethod: fields[7] as PaymentMethod,
      completedAt: fields[8] as DateTime,
      paidAt: fields[9] as DateTime?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransportTransaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jobId)
      ..writeByte(2)
      ..write(obj.transporterId)
      ..writeByte(3)
      ..write(obj.route)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.earnings)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.paidAt)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionStatusAdapter extends TypeAdapter<TransactionStatus> {
  @override
  final int typeId = 25;

  @override
  TransactionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionStatus.completed;
      case 1:
        return TransactionStatus.pendingPayment;
      case 2:
        return TransactionStatus.paid;
      case 3:
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionStatus obj) {
    switch (obj) {
      case TransactionStatus.completed:
        writer.writeByte(0);
        break;
      case TransactionStatus.pendingPayment:
        writer.writeByte(1);
        break;
      case TransactionStatus.paid:
        writer.writeByte(2);
        break;
      case TransactionStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 26;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.mobileMoney;
      case 2:
        return PaymentMethod.bankTransfer;
      case 3:
        return PaymentMethod.onDelivery;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.mobileMoney:
        writer.writeByte(1);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(2);
        break;
      case PaymentMethod.onDelivery:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
