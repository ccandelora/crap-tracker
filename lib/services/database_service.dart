import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DatabaseService {
  static const String _playerBoxName = 'players';
  static const String _diceRollBoxName = 'diceRolls';
  static const String _sessionBoxName = 'sessions';
  
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlayerAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DiceRollAdapter());
    }
    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Player>(_playerBoxName);
    await Hive.openBox<DiceRoll>(_diceRollBoxName);
    await Hive.openBox<Session>(_sessionBoxName);
    
    _initialized = true;
  }
  
  // Player operations
  Future<String> addPlayer(Player player) async {
    final box = Hive.box<Player>(_playerBoxName);
    await box.put(player.id, player);
    return player.id;
  }
  
  Future<List<Player>> getAllPlayers() async {
    final box = Hive.box<Player>(_playerBoxName);
    return box.values.toList();
  }
  
  Future<Player?> getPlayer(String id) async {
    final box = Hive.box<Player>(_playerBoxName);
    return box.get(id);
  }
  
  Future<void> updatePlayer(Player player) async {
    final box = Hive.box<Player>(_playerBoxName);
    await box.put(player.id, player);
  }
  
  Future<void> deletePlayer(String id) async {
    final box = Hive.box<Player>(_playerBoxName);
    await box.delete(id);
  }
  
  // DiceRoll operations
  Future<String> addDiceRoll(DiceRoll diceRoll) async {
    final box = Hive.box<DiceRoll>(_diceRollBoxName);
    await box.put(diceRoll.id, diceRoll);
    return diceRoll.id;
  }
  
  Future<List<DiceRoll>> getAllDiceRolls() async {
    final box = Hive.box<DiceRoll>(_diceRollBoxName);
    return box.values.toList();
  }
  
  Future<List<DiceRoll>> getDiceRollsByPlayer(String playerId) async {
    final box = Hive.box<DiceRoll>(_diceRollBoxName);
    return box.values.where((roll) => roll.playerId == playerId).toList();
  }
  
  Future<List<DiceRoll>> getDiceRollsBySession(String sessionId) async {
    final box = Hive.box<DiceRoll>(_diceRollBoxName);
    return box.values.where((roll) => roll.sessionId == sessionId).toList();
  }
  
  // Session operations
  Future<String> addSession(Session session) async {
    final box = Hive.box<Session>(_sessionBoxName);
    await box.put(session.id, session);
    return session.id;
  }
  
  Future<List<Session>> getAllSessions() async {
    final box = Hive.box<Session>(_sessionBoxName);
    return box.values.toList();
  }
  
  Future<List<Session>> getSessionsByPlayer(String playerId) async {
    final box = Hive.box<Session>(_sessionBoxName);
    return box.values.where((session) => session.playerId == playerId).toList();
  }
  
  Future<Session?> getActiveSessionByPlayer(String playerId) async {
    final box = Hive.box<Session>(_sessionBoxName);
    final sessions = box.values.where((session) => 
      session.playerId == playerId && session.isActive).toList();
    return sessions.isNotEmpty ? sessions.first : null;
  }
  
  Future<void> updateSession(Session session) async {
    final box = Hive.box<Session>(_sessionBoxName);
    await box.put(session.id, session);
  }
}

// Hive Adapters
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