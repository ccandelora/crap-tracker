import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/roll.dart';

class RollProvider with ChangeNotifier {
  List<Roll> _rolls = [];
  
  List<Roll> get rolls => _rolls;
  
  Future<void> loadRolls(String sessionId) async {
    final box = await Hive.openBox<Roll>('rolls');
    _rolls = box.values.where((roll) => roll.sessionId == sessionId).toList();
    _rolls.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by timestamp ascending
    notifyListeners();
  }
  
  Future<Roll> addRoll(String sessionId, int dice1, int dice2) async {
    final roll = Roll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      timestamp: DateTime.now(),
      dice1: dice1,
      dice2: dice2,
      total: dice1 + dice2,
    );

    final box = await Hive.openBox<Roll>('rolls');
    await box.put(roll.id, roll);
    
    _rolls.add(roll);
    notifyListeners();
    
    return roll;
  }
  
  Future<void> deleteRoll(String rollId) async {
    final box = await Hive.openBox<Roll>('rolls');
    await box.delete(rollId);
    
    _rolls.removeWhere((roll) => roll.id == rollId);
    notifyListeners();
  }
  
  Future<void> deleteRollsBySessionId(String sessionId) async {
    final box = await Hive.openBox<Roll>('rolls');
    
    // Get all roll IDs for this session
    final rollIds = _rolls
        .where((roll) => roll.sessionId == sessionId)
        .map((roll) => roll.id)
        .toList();
    
    // Delete from Hive
    for (final id in rollIds) {
      await box.delete(id);
    }
    
    // Remove from memory
    _rolls.removeWhere((roll) => roll.sessionId == sessionId);
    notifyListeners();
  }
  
  List<Roll> getRollsBySessionId(String sessionId) {
    return _rolls.where((roll) => roll.sessionId == sessionId).toList();
  }
  
  Map<int, int> getDistributionForSession(String sessionId) {
    final sessionRolls = getRollsBySessionId(sessionId);
    final distribution = <int, int>{};
    
    // Initialize all possible totals (2-12)
    for (int i = 2; i <= 12; i++) {
      distribution[i] = 0;
    }
    
    // Count occurrences of each total
    for (final roll in sessionRolls) {
      distribution[roll.total] = (distribution[roll.total] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  Map<int, int> getRollDistribution() {
    final Map<int, int> distribution = {
      2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0
    };
    
    for (var roll in _rolls) {
      distribution[roll.total] = (distribution[roll.total] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  int getWarmestNumber() {
    if (_rolls.isEmpty) return 0;
    
    final distribution = getRollDistribution();
    int maxCount = 0;
    int warmestNumber = 0;
    
    distribution.forEach((number, count) {
      if (count > maxCount) {
        maxCount = count;
        warmestNumber = number;
      }
    });
    
    return warmestNumber;
  }
  
  int getColdestNumber() {
    if (_rolls.isEmpty) return 0;
    
    final distribution = getRollDistribution();
    int minCount = _rolls.length;
    int coldestNumber = 0;
    
    distribution.forEach((number, count) {
      if (count < minCount && count > 0) {
        minCount = count;
        coldestNumber = number;
      }
    });
    
    // If all numbers have the same count or no rolls yet
    if (coldestNumber == 0) {
      return 0;
    }
    
    return coldestNumber;
  }
  
  Map<String, dynamic> getRollStatistics() {
    if (_rolls.isEmpty) {
      return {
        'totalRolls': 0,
        'warmestNumber': 0,
        'coldestNumber': 0,
        'mostRecentRolls': <Roll>[],
        'distribution': getRollDistribution(),
      };
    }
    
    // Make a copy and sort by timestamp
    final sortedRolls = List<Roll>.from(_rolls)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return {
      'totalRolls': _rolls.length,
      'warmestNumber': getWarmestNumber(),
      'coldestNumber': getColdestNumber(),
      'mostRecentRolls': sortedRolls.take(10).toList(),
      'distribution': getRollDistribution(),
    };
  }
  
  double getNumberFrequency(int number) {
    if (_rolls.isEmpty) return 0.0;
    
    final distribution = getRollDistribution();
    return distribution[number]! / _rolls.length;
  }
  
  // Calculate expected probability for each dice sum
  Map<int, double> getExpectedProbabilities() {
    return {
      2: 1/36,
      3: 2/36,
      4: 3/36,
      5: 4/36,
      6: 5/36,
      7: 6/36,
      8: 5/36,
      9: 4/36,
      10: 3/36,
      11: 2/36,
      12: 1/36,
    };
  }
} 