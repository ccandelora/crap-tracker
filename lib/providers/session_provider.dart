import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/session.dart';
import '../models/dice_roll.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _sessions = [];
  Session? _currentSession;

  List<Session> get sessions => _sessions;
  Session? get currentSession => _currentSession;
  Session? get activeSession => _currentSession?.isActive == true ? _currentSession : null;

  Future<void> loadSessions() async {
    final box = await Hive.openBox<Session>('sessions');
    _sessions = box.values.toList();
    _sessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
    notifyListeners();
  }

  Future<void> createSession(String playerId) async {
    final session = Session(
      playerId: playerId,
      startTime: DateTime.now(),
      isActive: true,
    );

    final box = await Hive.openBox<Session>('sessions');
    await box.put(session.id, session);
    
    _sessions.insert(0, session);
    _currentSession = session;
    notifyListeners();
  }

  Future<void> endSession(String sessionId) async {
    final box = await Hive.openBox<Session>('sessions');
    final session = box.get(sessionId);
    
    if (session != null) {
      session.endSession();
      await box.put(sessionId, session);
      
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _sessions[index] = session;
      }
      
      if (_currentSession?.id == sessionId) {
        _currentSession = session;
      }
      
      notifyListeners();
    }
  }

  Future<void> addRollToSession(String sessionId, DiceRoll roll) async {
    final box = await Hive.openBox<Session>('sessions');
    final session = box.get(sessionId);
    
    if (session != null) {
      session.incrementRolls();
      await box.put(sessionId, session);
      
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _sessions[index] = session;
      }
      
      if (_currentSession?.id == sessionId) {
        _currentSession = session;
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final box = await Hive.openBox<Session>('sessions');
    await box.delete(sessionId);
    
    _sessions.removeWhere((session) => session.id == sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
    
    notifyListeners();
  }

  void setCurrentSession(Session? session) {
    _currentSession = session;
    notifyListeners();
  }

  List<Session> getSessionsByPlayerId(String playerId) {
    return _sessions.where((session) => session.playerId == playerId).toList();
  }

  Session? getSessionById(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  bool get hasActiveSession => _currentSession != null && _currentSession!.isActive;

  List<DiceRoll> getAllRollsForPlayer(String playerId) {
    // This needs to be implemented using the DiceRollProvider instead
    // since the rolls are no longer stored in the Session class
    return [];
  }

  Map<int, int> getRollDistribution(String playerId) {
    // This needs to be implemented using the DiceRollProvider instead
    return {
      2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0
    };
  }

  int getTotalRollsForPlayer(String playerId) {
    return _sessions
        .where((s) => s.playerId == playerId)
        .fold(0, (sum, session) => sum + session.totalRolls);
  }

  Duration getAverageSessionDuration(String playerId) {
    final completedSessions = _sessions.where(
      (s) => s.playerId == playerId && s.endTime != null
    ).toList();
    
    if (completedSessions.isEmpty) return Duration.zero;
    
    int totalSeconds = 0;
    for (var session in completedSessions) {
      totalSeconds += session.durationInSeconds;
    }
    
    return Duration(seconds: totalSeconds ~/ completedSessions.length);
  }

  Future<Session?> loadActiveSessionForPlayer(String playerId) async {
    final playerSessions = getSessionsByPlayerId(playerId);
    final activeSession = playerSessions.where((s) => s.isActive).toList();
    
    if (activeSession.isNotEmpty) {
      _currentSession = activeSession.first;
    } else {
      _currentSession = null;
    }
    
    notifyListeners();
    return _currentSession;
  }

  Future<Session> startSession(String playerId) async {
    // First check if there's already an active session
    final existingSession = await loadActiveSessionForPlayer(playerId);
    if (existingSession != null && existingSession.isActive) {
      return existingSession;
    }
    
    // If not, create a new session
    final session = Session(
      playerId: playerId,
      startTime: DateTime.now(),
      isActive: true,
    );

    final box = await Hive.openBox<Session>('sessions');
    await box.put(session.id, session);
    
    _sessions.insert(0, session);
    _currentSession = session;
    notifyListeners();
    
    return session;
  }

  Future<void> incrementSessionRollCount(String sessionId) async {
    final box = await Hive.openBox<Session>('sessions');
    final session = box.get(sessionId);
    
    if (session != null) {
      session.incrementRolls();
      await box.put(sessionId, session);
      
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _sessions[index] = session;
      }
      
      if (_currentSession?.id == sessionId) {
        _currentSession = session;
      }
      
      notifyListeners();
    }
  }

  Future<bool> checkSevenOut(int rollTotal) async {
    if (_currentSession == null || !_currentSession!.isActive) {
      return false;
    }
    
    // In craps, a 7 after the point is established means the shooter loses
    if (rollTotal == 7) {
      await endSession(_currentSession!.id);
      return true;
    }
    
    return false;
  }
  
  Future<void> endActiveSession(int sessionRolls) async {
    if (_currentSession != null && _currentSession!.isActive) {
      await endSession(_currentSession!.id);
    }
  }

  Future<void> loadSessionsByPlayer(String playerId) async {
    await loadSessions();
    _sessions = _sessions.where((s) => s.playerId == playerId).toList();
    notifyListeners();
  }
} 