import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/dice_roll.dart';
import '../services/database_service.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _sessions = [];
  List<Session> _playerSessions = [];
  Session? _activeSession;

  List<Session> get sessions => _sessions;
  List<Session> get playerSessions => _playerSessions;
  Session? get activeSession => _activeSession;

  Future<void> loadSessions() async {
    _sessions = await DatabaseService.getAllSessions();
    _sessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
    notifyListeners();
  }

  Future<void> loadSessionsByPlayer(String playerId) async {
    _playerSessions = await DatabaseService.getSessionsByPlayer(playerId);
    _playerSessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
    notifyListeners();
  }

  Future<void> loadActiveSessionForPlayer(String playerId) async {
    _activeSession = await DatabaseService.getActiveSessionByPlayer(playerId);
    notifyListeners();
  }

  Future<Session?> getSession(String sessionId) async {
    // Check if the session is already loaded
    Session? session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _playerSessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => _activeSession != null && _activeSession!.id == sessionId
            ? _activeSession!
            : null as Session,
      ),
    );
    
    // If not found in memory, load from database
    if (session == null) {
      session = await DatabaseService.getSession(sessionId);
    }
    
    return session;
  }

  Future<String?> startNewSession(String playerId) async {
    // Check if player already has an active session
    final existingSession = await DatabaseService.getActiveSessionByPlayer(playerId);
    if (existingSession != null) {
      _activeSession = existingSession;
      return existingSession.id;
    }

    // Create a new session - starting in comeOut phase with no point
    final session = Session(
      playerId: playerId,
      startTime: DateTime.now(),
      gamePhase: GamePhase.comeOut,
      point: null,
    );
    
    final sessionId = await DatabaseService.addSession(session);
    
    _sessions.insert(0, session);
    if (_playerSessions.isNotEmpty && _playerSessions.first.playerId == playerId) {
      _playerSessions.insert(0, session);
    }
    
    _activeSession = session;
    notifyListeners();
    
    return sessionId;
  }

  Future<void> endSession(String sessionId) async {
    // Find session
    Session? session;
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex >= 0) {
      session = _sessions[sessionIndex];
    } else {
      session = await DatabaseService.getSession(sessionId);
    }
    
    if (session != null && session.isActive) {
      // End session
      session.endSession();
      await DatabaseService.updateSession(session);
      
      // Update provider state
      if (sessionIndex >= 0) {
        _sessions[sessionIndex] = session;
      }
      
      final playerSessionIndex = _playerSessions.indexWhere((s) => s.id == sessionId);
      if (playerSessionIndex >= 0) {
        _playerSessions[playerSessionIndex] = session;
      }
      
      if (_activeSession?.id == sessionId) {
        _activeSession = null;
      }
      
      notifyListeners();
    }
  }

  Future<void> incrementSessionRolls(String sessionId) async {
    // Find session
    Session? session;
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex >= 0) {
      session = _sessions[sessionIndex];
    } else {
      session = await DatabaseService.getSession(sessionId);
    }
    
    if (session != null && session.isActive) {
      // Increment roll count
      session.incrementRolls();
      await DatabaseService.updateSession(session);
      
      // Update provider state
      if (sessionIndex >= 0) {
        _sessions[sessionIndex] = session;
      }
      
      final playerSessionIndex = _playerSessions.indexWhere((s) => s.id == sessionId);
      if (playerSessionIndex >= 0) {
        _playerSessions[playerSessionIndex] = session;
      }
      
      if (_activeSession?.id == sessionId) {
        _activeSession = session;
      }
      
      notifyListeners();
    }
  }
  
  Future<void> updateSession(Session session) async {
    await DatabaseService.updateSession(session);
    
    // Update in memory collections
    final sessionIndex = _sessions.indexWhere((s) => s.id == session.id);
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = session;
    }
    
    final playerSessionIndex = _playerSessions.indexWhere((s) => s.id == session.id);
    if (playerSessionIndex >= 0) {
      _playerSessions[playerSessionIndex] = session;
    }
    
    if (_activeSession?.id == session.id) {
      _activeSession = session;
    }
    
    notifyListeners();
  }
  
  // Handle craps game state transitions based on dice roll
  Future<RollOutcome> processRoll(String sessionId, int diceTotal) async {
    Session? session;
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex >= 0) {
      session = _sessions[sessionIndex];
    } else {
      session = await DatabaseService.getSession(sessionId);
    }
    
    if (session == null || !session.isActive) {
      throw Exception('No active session found');
    }
    
    RollOutcome outcome;
    
    // Handle the roll based on current game phase
    if (session.gamePhase == GamePhase.comeOut) {
      // Come-out roll phase
      if (diceTotal == 7 || diceTotal == 11) {
        // Natural - win on come-out
        outcome = RollOutcome.natural;
        session.comeOutWins++;
      } else if (diceTotal == 2 || diceTotal == 3 || diceTotal == 12) {
        // Craps - loss on come-out
        outcome = RollOutcome.craps;
        session.comeOutLosses++;
      } else {
        // Point established
        session.setPoint(diceTotal);
        outcome = RollOutcome.point;
        // Update point establishment count
        session.pointsEstablished[diceTotal] = (session.pointsEstablished[diceTotal] ?? 0) + 1;
      }
    } else {
      // Point phase
      if (diceTotal == session.point) {
        // Hit the point - win
        outcome = RollOutcome.hitPoint;
        session.pointsMade++;
        session.clearPoint(); // Reset to come-out phase
      } else if (diceTotal == 7) {
        // Seven out - loss
        outcome = RollOutcome.sevenOut;
        session.sevensOut++;
        session.clearPoint(); // Reset to come-out phase
      } else {
        // Some other roll during point phase
        outcome = RollOutcome.other;
      }
    }
    
    // Update session with new statistics
    await DatabaseService.updateSession(session);
    
    // Update active session if needed
    if (_activeSession?.id == sessionId) {
      _activeSession = session;
    }
    
    // Update session lists if needed
    if (sessionIndex >= 0) {
      _sessions[sessionIndex] = session;
    }
    
    final playerSessionIndex = _playerSessions.indexWhere((s) => s.id == sessionId);
    if (playerSessionIndex >= 0) {
      _playerSessions[playerSessionIndex] = session;
    }
    
    notifyListeners();
    return outcome;
  }
}
