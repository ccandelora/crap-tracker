import 'package:hive/hive.dart';
import 'package:crap_tracker/models/player.dart';
import 'package:crap_tracker/models/dice_roll.dart';
import 'package:crap_tracker/models/session.dart';

class HiveAdapters {
  static void registerAdapters() {
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(DiceRollAdapter());
    Hive.registerAdapter(SessionAdapter());
  }
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
      totalRolls: fields[2] as int,
      totalSessions: fields[3] as int,
      avgRollsPerSession: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalRolls)
      ..writeByte(3)
      ..write(obj.totalSessions)
      ..writeByte(4)
      ..write(obj.avgRollsPerSession);
  }
}

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
      id: fields[0] as String,
      playerId: fields[1] as String,
      sessionId: fields[2] as String?,
      diceOne: fields[3] as int,
      diceTwo: fields[4] as int,
      timestamp: fields[6] as DateTime,
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
}

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
      id: fields[0] as String,
      playerId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      totalRolls: fields[4] as int,
      durationInSeconds: fields[5] as int,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(7)
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
      ..writeByte(5)
      ..write(obj.durationInSeconds)
      ..writeByte(6)
      ..write(obj.isActive);
  }
} 