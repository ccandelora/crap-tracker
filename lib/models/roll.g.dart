// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RollAdapter extends TypeAdapter<Roll> {
  @override
  final int typeId = 2;

  @override
  Roll read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Roll(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      dice1: fields[3] as int,
      dice2: fields[4] as int,
      total: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Roll obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.dice1)
      ..writeByte(4)
      ..write(obj.dice2)
      ..writeByte(5)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
