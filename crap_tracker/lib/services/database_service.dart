import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static const String _playerBoxName = 'players';
  static const String _diceRollBoxName = 'diceRolls';
  static const String _sessionBoxName = 'sessions';
  
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      debugPrint('Database already initialized, skipping initialization');
      return;
    }
    
    try {
      debugPrint('Starting database initialization...');
      
      // Make sure Hive is initialized
      await Hive.initFlutter();
      
      debugPrint('Opening player box...');
      await Hive.openBox<Player>(_playerBoxName);
      
      debugPrint('Opening dice roll box...');
      await Hive.openBox<DiceRoll>(_diceRollBoxName);
      
      debugPrint('Opening session box...');
      await Hive.openBox<Session>(_sessionBoxName);
      
      // Create a default player if none exist
      final playersBox = Hive.box<Player>(_playerBoxName);
      debugPrint('Players box opened. Contains ${playersBox.length} players');
      
      if (playersBox.isEmpty) {
        debugPrint('Creating default player...');
        final player = Player(name: 'Player 1');
        await playersBox.put(player.id, player);
        debugPrint('Added default player with ID: ${player.id}');
      }
      
      _initialized = true;
      debugPrint('Database initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      // Clear initialization flag so we can try again
      _initialized = false;
      // Rethrow to let caller handle the error
      rethrow;
    }
  }
  
  // Ensure database is initialized before operations
  static void _checkInitialization() {
    if (!_initialized) {
      throw Exception('Database not initialized. Call DatabaseService.init() first.');
    }
  }
  
  // Player operations
  static Future<String> addPlayer(Player player) async {
    _checkInitialization();
    try {
      final box = Hive.box<Player>(_playerBoxName);
      await box.put(player.id, player);
      return player.id;
    } catch (e) {
      debugPrint('Error adding player: $e');
      rethrow;
    }
  }
  
  static Future<List<Player>> getAllPlayers() async {
    _checkInitialization();
    try {
      final box = Hive.box<Player>(_playerBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting all players: $e');
      rethrow;
    }
  }
  
  static Future<Player?> getPlayer(String id) async {
    _checkInitialization();
    try {
      final box = Hive.box<Player>(_playerBoxName);
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting player: $e');
      rethrow;
    }
  }
  
  static Future<void> updatePlayer(Player player) async {
    _checkInitialization();
    try {
      final box = Hive.box<Player>(_playerBoxName);
      await box.put(player.id, player);
    } catch (e) {
      debugPrint('Error updating player: $e');
      rethrow;
    }
  }
  
  static Future<void> deletePlayer(String id) async {
    _checkInitialization();
    try {
      final box = Hive.box<Player>(_playerBoxName);
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting player: $e');
      rethrow;
    }
  }
  
  // DiceRoll operations
  static Future<String> addDiceRoll(DiceRoll diceRoll) async {
    _checkInitialization();
    try {
      final box = Hive.box<DiceRoll>(_diceRollBoxName);
      await box.put(diceRoll.id, diceRoll);
      return diceRoll.id;
    } catch (e) {
      debugPrint('Error adding dice roll: $e');
      rethrow;
    }
  }
  
  static Future<List<DiceRoll>> getAllDiceRolls() async {
    _checkInitialization();
    try {
      final box = Hive.box<DiceRoll>(_diceRollBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting all dice rolls: $e');
      rethrow;
    }
  }
  
  static Future<List<DiceRoll>> getDiceRollsByPlayer(String playerId) async {
    _checkInitialization();
    try {
      final box = Hive.box<DiceRoll>(_diceRollBoxName);
      return box.values.where((roll) => roll.playerId == playerId).toList();
    } catch (e) {
      debugPrint('Error getting dice rolls by player: $e');
      rethrow;
    }
  }
  
  static Future<List<DiceRoll>> getDiceRollsBySession(String sessionId) async {
    _checkInitialization();
    try {
      final box = Hive.box<DiceRoll>(_diceRollBoxName);
      return box.values.where((roll) => roll.sessionId == sessionId).toList();
    } catch (e) {
      debugPrint('Error getting dice rolls by session: $e');
      rethrow;
    }
  }
  
  // Session operations
  static Future<String> addSession(Session session) async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      await box.put(session.id, session);
      return session.id;
    } catch (e) {
      debugPrint('Error adding session: $e');
      rethrow;
    }
  }
  
  static Future<List<Session>> getAllSessions() async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting all sessions: $e');
      rethrow;
    }
  }
  
  static Future<Session?> getSession(String id) async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting session: $e');
      rethrow;
    }
  }
  
  static Future<List<Session>> getSessionsByPlayer(String playerId) async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      return box.values.where((session) => session.playerId == playerId).toList();
    } catch (e) {
      debugPrint('Error getting sessions by player: $e');
      rethrow;
    }
  }
  
  static Future<Session?> getActiveSessionByPlayer(String playerId) async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      final sessions = box.values.where((session) => 
        session.playerId == playerId && session.isActive).toList();
      return sessions.isNotEmpty ? sessions.first : null;
    } catch (e) {
      debugPrint('Error getting active session by player: $e');
      rethrow;
    }
  }
  
  static Future<void> updateSession(Session session) async {
    _checkInitialization();
    try {
      final box = Hive.box<Session>(_sessionBoxName);
      await box.put(session.id, session);
    } catch (e) {
      debugPrint('Error updating session: $e');
      rethrow;
    }
  }
  
  // New method to synchronize player session count
  static Future<void> synchronizePlayerSessionCount(String playerId) async {
    _checkInitialization();
    try {
      debugPrint('Synchronizing player session count for player: $playerId');
      
      // Get all sessions for this player
      final sessionsBox = Hive.box<Session>(_sessionBoxName);
      final playerSessions = sessionsBox.values
          .where((session) => session.playerId == playerId)
          .toList();
      
      // Count active and completed sessions 
      final activeSessions = playerSessions.where((s) => s.isActive).toList();
      final completedSessions = playerSessions.where((s) => !s.isActive).toList();
      
      // Get the player
      final playersBox = Hive.box<Player>(_playerBoxName);
      final player = playersBox.get(playerId);
      
      if (player != null) {
        // Update session count - use completed sessions
        debugPrint('Updating player session count from ${player.totalSessions} to ${completedSessions.length}');
        player.totalSessions = completedSessions.length;
        
        // Games should include both completed sessions and active sessions with rolls
        player.totalGames = playerSessions.length;
        
        // Update average rolls per session
        if (completedSessions.isNotEmpty) {
          final totalRolls = completedSessions.fold<int>(
            0, (sum, session) => sum + session.totalRolls);
          player.avgRollsPerSession = totalRolls / completedSessions.length;
        } else if (activeSessions.isNotEmpty) {
          // Only active sessions but they have rolls
          final activeRolls = activeSessions.fold<int>(
            0, (sum, session) => sum + session.totalRolls);
          if (activeRolls > 0) {
            player.avgRollsPerSession = activeRolls / activeSessions.length;
          }
        }
        
        // Save the updated player
        await playersBox.put(player.id, player);
        debugPrint('Player session stats synchronized successfully: games=${player.totalGames}, sessions=${player.totalSessions}, avg=${player.avgRollsPerSession.toStringAsFixed(1)}');
      } else {
        debugPrint('Player not found, cannot synchronize session count');
      }
    } catch (e) {
      debugPrint('Error synchronizing player session count: $e');
      rethrow;
    }
  }
  
  // New method to synchronize player roll count
  static Future<void> synchronizePlayerRollCount(String playerId) async {
    _checkInitialization();
    try {
      debugPrint('Synchronizing player roll count for player: $playerId');
      
      // Get all rolls for this player
      final rollsBox = Hive.box<DiceRoll>(_diceRollBoxName);
      final playerRolls = rollsBox.values
          .where((roll) => roll.playerId == playerId)
          .toList();
      
      // Get all sessions for this player
      final sessionsBox = Hive.box<Session>(_sessionBoxName);
      final playerSessions = sessionsBox.values
          .where((session) => session.playerId == playerId)
          .toList();
          
      // Count active sessions
      final activeSessions = playerSessions.where((s) => s.isActive).toList();
      // Count completed sessions
      final completedSessions = playerSessions.where((s) => !s.isActive).toList();
      
      // Get the player
      final playersBox = Hive.box<Player>(_playerBoxName);
      final player = playersBox.get(playerId);
      
      if (player != null) {
        // Update roll count
        final actualRollCount = playerRolls.length;
        debugPrint('Updating player roll count from ${player.totalRolls} to $actualRollCount');
        player.totalRolls = actualRollCount;
        
        // Update games count - for craps, each session can be considered a game
        // If there are no completed sessions but there are rolls, count active session as a game
        player.totalGames = completedSessions.length;
        if (activeSessions.isNotEmpty && actualRollCount > 0) {
          player.totalGames++; // Count current active session
        }
        
        // Update session count
        player.totalSessions = completedSessions.length;
        
        // Calculate average rolls per session
        if (completedSessions.isNotEmpty) {
          // Normal case - completed sessions
          final totalRollsInCompletedSessions = completedSessions.fold<int>(
            0, (sum, session) => sum + session.totalRolls);
          player.avgRollsPerSession = totalRollsInCompletedSessions / completedSessions.length;
        } else if (activeSessions.isNotEmpty && actualRollCount > 0) {
          // Special case - only active sessions with rolls
          player.avgRollsPerSession = actualRollCount.toDouble();
        } else {
          // No sessions or rolls
          player.avgRollsPerSession = 0.0;
        }
        
        // Save the updated player
        await playersBox.put(player.id, player);
        debugPrint('Player stats synchronized successfully: rolls=${player.totalRolls}, games=${player.totalGames}, sessions=${player.totalSessions}, avg=${player.avgRollsPerSession}');
      } else {
        debugPrint('Player not found, cannot synchronize stats');
      }
    } catch (e) {
      debugPrint('Error synchronizing player stats: $e');
      rethrow;
    }
  }
}
