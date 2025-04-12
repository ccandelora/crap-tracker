import 'package:flutter/foundation.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class DiceRollProvider with ChangeNotifier {
  List<DiceRoll> _rolls = [];
  List<DiceRoll> _playerRolls = [];
  List<DiceRoll> _allRolls = [];

  List<DiceRoll> get rolls => _rolls;
  List<DiceRoll> get playerRolls => _playerRolls;
  List<DiceRoll> get allRolls => _allRolls;

  Future<void> loadRolls() async {
    _rolls = await DatabaseService.getAllDiceRolls();
    _rolls.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
    notifyListeners();
  }

  Future<void> loadRollsByPlayer(String playerId) async {
    _playerRolls = await DatabaseService.getDiceRollsByPlayer(playerId);
    _playerRolls.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
    notifyListeners();
  }

  Future<void> loadRollsBySession(String sessionId) async {
    _playerRolls = await DatabaseService.getDiceRollsBySession(sessionId);
    _playerRolls.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
    notifyListeners();
  }

  Future<void> loadAllRolls() async {
    try {
      _allRolls = await DatabaseService.getAllDiceRolls();
      _allRolls.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading all rolls: $e');
      rethrow;
    }
  }

  Future<DiceRoll> addRoll({
    required String playerId,
    required String sessionId,
    required int diceOne,
    required int diceTwo,
    required GamePhase gamePhase,
    int? point,
  }) async {
    if (!DiceRoll.isValidDiceValue(diceOne) || !DiceRoll.isValidDiceValue(diceTwo)) {
      throw ArgumentError('Invalid dice values. Must be between 1 and 6.');
    }

    final total = diceOne + diceTwo;
    
    // Create roll with current game state
    final roll = DiceRoll(
      playerId: playerId,
      sessionId: sessionId,
      diceOne: diceOne,
      diceTwo: diceTwo,
      gamePhase: gamePhase,
      point: point,
    );

    await DatabaseService.addDiceRoll(roll);
    
    _rolls.insert(0, roll);
    if (_playerRolls.isNotEmpty && _playerRolls.first.playerId == playerId) {
      _playerRolls.insert(0, roll);
    }
    
    // Make sure the player's total roll count stays in sync
    try {
      await DatabaseService.synchronizePlayerRollCount(playerId);
    } catch (e) {
      debugPrint('Warning: Failed to synchronize player roll count: $e');
    }
    
    notifyListeners();
    return roll;
  }

  Map<int, int> getRollDistribution(List<DiceRoll> rolls) {
    final Map<int, int> distribution = {
      2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0
    };
    
    for (var roll in rolls) {
      distribution[roll.rollTotal] = (distribution[roll.rollTotal] ?? 0) + 1;
    }
    
    return distribution;
  }

  Map<String, int> getOutcomeDistribution(List<DiceRoll> rolls) {
    final Map<String, int> distribution = {
      'Natural (Win)': 0,
      'Craps (Loss)': 0,
      'Point Hit (Win)': 0,
      'Seven Out (Loss)': 0,
      'Other': 0,
    };
    
    for (var roll in rolls) {
      switch (roll.outcome) {
        case RollOutcome.natural:
          distribution['Natural (Win)'] = (distribution['Natural (Win)'] ?? 0) + 1;
          break;
        case RollOutcome.craps:
          distribution['Craps (Loss)'] = (distribution['Craps (Loss)'] ?? 0) + 1;
          break;
        case RollOutcome.hitPoint:
          distribution['Point Hit (Win)'] = (distribution['Point Hit (Win)'] ?? 0) + 1;
          break;
        case RollOutcome.sevenOut:
          distribution['Seven Out (Loss)'] = (distribution['Seven Out (Loss)'] ?? 0) + 1;
          break;
        default:
          distribution['Other'] = (distribution['Other'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }
  
  // Statistics for wins/losses
  int getWinCount(List<DiceRoll> rolls) {
    return rolls.where((roll) => roll.isWin).length;
  }
  
  int getLossCount(List<DiceRoll> rolls) {
    return rolls.where((roll) => roll.isLoss).length;
  }
  
  double getWinPercentage(List<DiceRoll> rolls) {
    final totalWinsAndLosses = rolls.where((roll) => 
      roll.isWin || roll.isLoss).length;
    
    if (totalWinsAndLosses == 0) return 0.0;
    
    return getWinCount(rolls) / totalWinsAndLosses * 100;
  }
}
