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
      gamePhase: fields[8] as GamePhase?,
      point: fields[9] as int?,
      outcome: fields[7] as RollOutcome?,
    );
  }

  @override
  void write(BinaryWriter writer, DiceRoll obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.outcome)
      ..writeByte(8)
      ..write(obj.gamePhase)
      ..writeByte(9)
      ..write(obj.point);
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

class RollOutcomeAdapter extends TypeAdapter<RollOutcome> {
  @override
  final int typeId = 3;

  @override
  RollOutcome read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RollOutcome.natural;
      case 1:
        return RollOutcome.craps;
      case 2:
        return RollOutcome.point;
      case 3:
        return RollOutcome.hitPoint;
      case 4:
        return RollOutcome.sevenOut;
      case 5:
        return RollOutcome.other;
      default:
        return RollOutcome.natural;
    }
  }

  @override
  void write(BinaryWriter writer, RollOutcome obj) {
    switch (obj) {
      case RollOutcome.natural:
        writer.writeByte(0);
        break;
      case RollOutcome.craps:
        writer.writeByte(1);
        break;
      case RollOutcome.point:
        writer.writeByte(2);
        break;
      case RollOutcome.hitPoint:
        writer.writeByte(3);
        break;
      case RollOutcome.sevenOut:
        writer.writeByte(4);
        break;
      case RollOutcome.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollOutcomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
