// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dice_roll.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiceRollAdapter extends TypeAdapter<DiceRoll> {
  @override
  final int typeId = 1;

  @override
  DiceRoll read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiceRoll(
      id: fields[0] as String?,
      playerId: fields[1] as String,
      sessionId: fields[2] as String?,
      diceOne: fields[3] as int,
      diceTwo: fields[4] as int,
      timestamp: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DiceRoll obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.diceOne)
      ..writeByte(4)
      ..write(obj.diceTwo)
      ..writeByte(5)
      ..write(obj.rollTotal)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceRollAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
