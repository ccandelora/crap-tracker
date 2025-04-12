import 'package:flutter/foundation.dart';
import '../models/dice_roll.dart';
import '../services/database_service.dart';

class DiceRollProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<DiceRoll> _rolls = [];
  
  List<DiceRoll> get rolls => _rolls;

  Future<void> loadRolls() async {
    _rolls = await _databaseService.getAllDiceRolls();
    notifyListeners();
  }
  
  Future<void> loadRollsByPlayer(String playerId) async {
    _rolls = await _databaseService.getDiceRollsByPlayer(playerId);
    notifyListeners();
  }
  
  Future<void> loadRollsBySession(String sessionId) async {
    _rolls = await _databaseService.getDiceRollsBySession(sessionId);
    notifyListeners();
  }

  Future<DiceRoll> addRoll(String playerId, int diceOne, int diceTwo, String? sessionId) async {
    if (!DiceRoll.isValidDiceValue(diceOne) || !DiceRoll.isValidDiceValue(diceTwo)) {
      throw ArgumentError('Dice values must be between 1 and 6');
    }
    
    final roll = DiceRoll(
      playerId: playerId,
      diceOne: diceOne,
      diceTwo: diceTwo,
      sessionId: sessionId,
    );
    
    await _databaseService.addDiceRoll(roll);
    _rolls.add(roll);
    notifyListeners();
    
    return roll;
  }
  
  List<int> getRollTotals() {
    return _rolls.map((roll) => roll.rollTotal).toList();
  }
  
  Map<int, int> getRollTotalCounts() {
    final Map<int, int> counts = {};
    
    for (var roll in _rolls) {
      counts[roll.rollTotal] = (counts[roll.rollTotal] ?? 0) + 1;
    }
    
    return counts;
  }
  
  // Get distribution of dice values for visualization
  Map<int, double> getRollDistribution() {
    final totalCounts = getRollTotalCounts();
    final Map<int, double> distribution = {};
    
    if (_rolls.isEmpty) return {};
    
    for (int i = 2; i <= 12; i++) {
      distribution[i] = (totalCounts[i] ?? 0) / _rolls.length;
    }
    
    return distribution;
  }
} 