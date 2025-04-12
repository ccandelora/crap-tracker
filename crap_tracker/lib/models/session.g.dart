// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 2;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      id: fields[0] as String?,
      playerId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      totalRolls: fields[4] as int,
      isActive: fields[6] as bool,
      gamePhase: fields[7] as GamePhase,
      point: fields[8] as int?,
      comeOutWins: fields[9] as int,
      comeOutLosses: fields[10] as int,
      pointsMade: fields[11] as int,
      sevensOut: fields[12] as int,
      longestRollStreak: fields[13] as int,
      currentRollStreak: fields[14] as int,
      pointsEstablished: (fields[15] as Map?)?.cast<int, int>(),
      playerOrder: (fields[16] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.totalRolls)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.gamePhase)
      ..writeByte(8)
      ..write(obj.point)
      ..writeByte(9)
      ..write(obj.comeOutWins)
      ..writeByte(10)
      ..write(obj.comeOutLosses)
      ..writeByte(11)
      ..write(obj.pointsMade)
      ..writeByte(12)
      ..write(obj.sevensOut)
      ..writeByte(13)
      ..write(obj.longestRollStreak)
      ..writeByte(14)
      ..write(obj.currentRollStreak)
      ..writeByte(15)
      ..write(obj.pointsEstablished)
      ..writeByte(16)
      ..write(obj.playerOrder)
      ..writeByte(5)
      ..write(obj.durationInSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GamePhaseAdapter extends TypeAdapter<GamePhase> {
  @override
  final int typeId = 4;

  @override
  GamePhase read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GamePhase.comeOut;
      case 1:
        return GamePhase.point;
      default:
        return GamePhase.comeOut;
    }
  }

  @override
  void write(BinaryWriter writer, GamePhase obj) {
    switch (obj) {
      case GamePhase.comeOut:
        writer.writeByte(0);
        break;
      case GamePhase.point:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
