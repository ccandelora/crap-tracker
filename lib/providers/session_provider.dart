import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/session.dart';
import '../models/roll.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _sessions = [];
  Session? _currentSession;

  List<Session> get sessions => _sessions;
  Session? get currentSession => _currentSession;

  Future<void> loadSessions() async {
    final box = await Hive.openBox<Session>('sessions');
    _sessions = box.values.toList();
    _sessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
    notifyListeners();
  }

  Future<void> createSession(String playerId) async {
    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      startTime: DateTime.now(),
      endTime: null,
      rolls: [],
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
      session.endTime = DateTime.now();
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

  Future<void> addRollToSession(String sessionId, Roll roll) async {
    final box = await Hive.openBox<Session>('sessions');
    final session = box.get(sessionId);
    
    if (session != null) {
      session.rolls.add(roll);
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
    return _sessions.firstWhere((session) => session.id == id, orElse: () => null as Session);
  }

  bool get hasActiveSession => _currentSession != null;

  List<Roll> getAllRollsForPlayer(String playerId) {
    List<Roll> allRolls = [];
    for (var session in _sessions.where((s) => s.playerId == playerId)) {
      allRolls.addAll(session.rolls);
    }
    allRolls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allRolls;
  }

  Map<int, int> getRollDistribution(String playerId) {
    final Map<int, int> distribution = {
      2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0
    };
    
    final allRolls = getAllRollsForPlayer(playerId);
    for (var roll in allRolls) {
      distribution[roll.total] = (distribution[roll.total] ?? 0) + 1;
    }
    
    return distribution;
  }

  int getTotalRollsForPlayer(String playerId) {
    return getAllRollsForPlayer(playerId).length;
  }

  Duration getAverageSessionDuration(String playerId) {
    final completedSessions = _sessions.where(
      (s) => s.playerId == playerId && s.endTime != null
    ).toList();
    
    if (completedSessions.isEmpty) return Duration.zero;
    
    int totalSeconds = 0;
    for (var session in completedSessions) {
      totalSeconds += session.endTime!.difference(session.startTime).inSeconds;
    }
    
    return Duration(seconds: totalSeconds ~/ completedSessions.length);
  }
} 