import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'session.dart';

part 'dice_roll.g.dart';

@HiveType(typeId: 3)
enum RollOutcome {
  @HiveField(0)
  natural,    // 7 or 11 on come-out roll (win)
  
  @HiveField(1)
  craps,      // 2, 3, or 12 on come-out roll (loss)
  
  @HiveField(2)
  point,      // Establishing a point on come-out roll
  
  @HiveField(3)
  hitPoint,   // Rolling the point number again
  
  @HiveField(4)
  sevenOut,   // Rolling a 7 after point established (loss)
  
  @HiveField(5)
  other       // Any other roll during point phase
}

@HiveType(typeId: 1)
class DiceRoll extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String playerId;

  @HiveField(2)
  final String? sessionId;

  @HiveField(3)
  final int diceOne;

  @HiveField(4)
  final int diceTwo;

  @HiveField(5)
  final int rollTotal;

  @HiveField(6)
  final DateTime timestamp;
  
  @HiveField(7)
  final RollOutcome? outcome;

  @HiveField(8)
  final GamePhase gamePhase;
  
  @HiveField(9)
  final int? point;

  DiceRoll({
    String? id,
    required this.playerId,
    this.sessionId,
    required this.diceOne,
    required this.diceTwo,
    DateTime? timestamp,
    GamePhase? gamePhase,
    this.point,
    RollOutcome? outcome,
  })  : id = id ?? const Uuid().v4(),
        rollTotal = diceOne + diceTwo,
        timestamp = timestamp ?? DateTime.now(),
        gamePhase = gamePhase ?? GamePhase.comeOut,
        outcome = outcome ?? _evaluateOutcome(diceOne + diceTwo, gamePhase ?? GamePhase.comeOut, point);

  static bool isValidDiceValue(int value) {
    return value >= 1 && value <= 6;
  }
  
  // Evaluate the outcome based on craps rules
  static RollOutcome _evaluateOutcome(int total, GamePhase phase, int? point) {
    if (phase == GamePhase.comeOut) {
      // Come-out roll rules
      if (total == 7 || total == 11) {
        return RollOutcome.natural; // Win
      } else if (total == 2 || total == 3 || total == 12) {
        return RollOutcome.craps; // Loss
      } else {
        return RollOutcome.point; // Establish point
      }
    } else {
      // Point phase rules
      if (total == point) {
        return RollOutcome.hitPoint; // Win by hitting point
      } else if (total == 7) {
        return RollOutcome.sevenOut; // Loss by rolling 7
      } else {
        return RollOutcome.other; // Neither win nor loss
      }
    }
  }
  
  String get outcomeDescription {
    switch (outcome) {
      case RollOutcome.natural:
        return 'Natural - Win!';
      case RollOutcome.craps:
        return 'Craps - Loss';
      case RollOutcome.point:
        return 'Point $rollTotal established';
      case RollOutcome.hitPoint:
        return 'Hit Point $rollTotal - Win!';
      case RollOutcome.sevenOut:
        return 'Seven Out - Loss';
      case RollOutcome.other:
        return 'No outcome yet';
      default:
        return 'Unknown';
    }
  }
  
  bool get isWin => 
    outcome == RollOutcome.natural || 
    outcome == RollOutcome.hitPoint;
    
  bool get isLoss => 
    outcome == RollOutcome.craps || 
    outcome == RollOutcome.sevenOut;

  /// Returns true if this roll established a point
  bool get isPointEstablished => outcome == RollOutcome.point;
  
  /// Returns true if this roll is a seven
  bool get isSeven => rollTotal == 7;
  
  /// Returns true if this roll is a box number (4, 5, 6, 8, 9, 10)
  bool get isBoxNumber => [4, 5, 6, 8, 9, 10].contains(rollTotal);
  
  /// Returns true if this is a come out roll
  bool get isComeOut => gamePhase == GamePhase.comeOut;
  
  /// Returns true if this roll is during the point phase
  bool get isPointPhase => gamePhase == GamePhase.point;
  
  /// Check if this roll is a specific box number
  bool isSpecificBoxNumber(int boxNumber) {
    return isBoxNumber && rollTotal == boxNumber;
  }
  
  /// Static method to calculate Seven to Rolls Ratio (SRR)
  static double calculateSRR(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return 0;
    
    int sevenCount = rolls.where((roll) => roll.isSeven).length;
    return sevenCount > 0 ? rolls.length / sevenCount : 0;
  }
  
  /// Static method to count hits for each box number
  static Map<int, int> countBoxNumberHits(List<DiceRoll> rolls) {
    Map<int, int> boxHits = {4: 0, 5: 0, 6: 0, 8: 0, 9: 0, 10: 0};
    
    for (var roll in rolls) {
      if (roll.isBoxNumber) {
        boxHits[roll.rollTotal] = (boxHits[roll.rollTotal] ?? 0) + 1;
      }
    }
    
    return boxHits;
  }
  
  /// Static method to track come out roll statistics
  static Map<String, int> comeOutStats(List<DiceRoll> rolls) {
    int wins = 0;
    int losses = 0;
    int points = 0;
    
    for (var roll in rolls) {
      if (roll.isComeOut) {
        if (roll.outcome == RollOutcome.natural) {
          wins++;
        } else if (roll.outcome == RollOutcome.craps) {
          losses++;
        } else if (roll.outcome == RollOutcome.point) {
          points++;
        }
      }
    }
    
    return {
      'wins': wins,
      'losses': losses,
      'points': points,
      'total': wins + losses + points,
    };
  }
  
  /// Static method to calculate statistical metrics for roll outcomes
  static Map<String, dynamic> calculateStatistics(List<DiceRoll> rolls) {
    if (rolls.isEmpty) {
      return {
        'mean': 0.0,
        'stdDev': 0.0,
        'variance': 0.0,
        'min': 0,
        'max': 0,
      };
    }
    
    List<int> totals = rolls.map((roll) => roll.rollTotal).toList();
    double mean = totals.reduce((a, b) => a + b) / totals.length;
    
    double variance = 0;
    for (int total in totals) {
      variance += (total - mean) * (total - mean);
    }
    variance /= totals.length;
    
    return {
      'mean': mean,
      'stdDev': variance > 0 ? sqrt(variance) : 0.0,
      'variance': variance,
      'min': totals.reduce((a, b) => a < b ? a : b),
      'max': totals.reduce((a, b) => a > b ? a : b),
    };
  }
  
  /// Static method to identify hot and cold numbers
  static Map<String, List<int>> identifyHotColdNumbers(List<DiceRoll> rolls) {
    Map<int, int> numberCounts = {};
    for (var i = 2; i <= 12; i++) {
      numberCounts[i] = 0;
    }
    
    for (var roll in rolls) {
      numberCounts[roll.rollTotal] = (numberCounts[roll.rollTotal] ?? 0) + 1;
    }
    
    // Sort by frequency
    var sortedEntries = numberCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Top 3 most frequent are "hot"
    List<int> hotNumbers = sortedEntries.take(3).map((e) => e.key).toList();
    
    // Bottom 3 least frequent (excluding 2 and 12 which are naturally rare) are "cold"
    List<int> coldNumbers = sortedEntries
        .where((e) => ![2, 12].contains(e.key) && e.value > 0)
        .toList()
        .reversed
        .take(3)
        .map((e) => e.key)
        .toList();
    
    return {
      'hot': hotNumbers,
      'cold': coldNumbers,
    };
  }
  
  /// Calculate streak information (consecutive wins/losses)
  static Map<String, dynamic> calculateStreaks(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {
      'longestWinStreak': 0,
      'longestLossStreak': 0,
      'currentWinStreak': 0,
      'currentLossStreak': 0,
    };
    
    int currentWinStreak = 0;
    int currentLossStreak = 0;
    int longestWinStreak = 0;
    int longestLossStreak = 0;
    
    for (var roll in rolls) {
      if (roll.isWin) {
        currentWinStreak++;
        currentLossStreak = 0;
        if (currentWinStreak > longestWinStreak) {
          longestWinStreak = currentWinStreak;
        }
      } else if (roll.isLoss) {
        currentLossStreak++;
        currentWinStreak = 0;
        if (currentLossStreak > longestLossStreak) {
          longestLossStreak = currentLossStreak;
        }
      } else {
        // Not a win or loss (e.g., establishing a point)
        // We don't reset streaks here since it's not a conclusive outcome
      }
    }
    
    return {
      'longestWinStreak': longestWinStreak,
      'longestLossStreak': longestLossStreak,
      'currentWinStreak': currentWinStreak,
      'currentLossStreak': currentLossStreak,
    };
  }
}
