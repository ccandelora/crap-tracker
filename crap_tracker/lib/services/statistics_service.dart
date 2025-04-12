import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../models/player.dart';

class StatisticsService {
  // Calculate Seven to Rolls Ratio (SRR)
  static double calculateSRR(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return 0.0;
    
    int sevenCount = rolls.where((roll) => roll.rollTotal == 7).length;
    return sevenCount > 0 ? rolls.length / sevenCount : 0.0;
  }
  
  // Calculate how many rolls occur between sevens on average
  static double calculateAverageRollsBetweenSevens(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return 0.0;
    
    List<int> rollsBetweenSevens = [];
    int currentCount = 0;
    
    for (var roll in rolls) {
      currentCount++;
      if (roll.rollTotal == 7) {
        if (currentCount > 1) { // Skip the first seven
          rollsBetweenSevens.add(currentCount - 1);
        }
        currentCount = 0;
      }
    }
    
    if (rollsBetweenSevens.isEmpty) return 0.0;
    return rollsBetweenSevens.reduce((a, b) => a + b) / rollsBetweenSevens.length;
  }
  
  // Get frequency distribution of all roll outcomes
  static Map<int, int> getRollDistribution(List<DiceRoll> rolls) {
    Map<int, int> distribution = {};
    for (int i = 2; i <= 12; i++) {
      distribution[i] = 0;
    }
    
    for (var roll in rolls) {
      distribution[roll.rollTotal] = (distribution[roll.rollTotal] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  // Get box number hits (4, 5, 6, 8, 9, 10)
  static Map<int, int> getBoxNumberHits(List<DiceRoll> rolls) {
    Map<int, int> boxHits = {4: 0, 5: 0, 6: 0, 8: 0, 9: 0, 10: 0};
    
    for (var roll in rolls) {
      if (boxHits.containsKey(roll.rollTotal)) {
        boxHits[roll.rollTotal] = boxHits[roll.rollTotal]! + 1;
      }
    }
    
    return boxHits;
  }
  
  // Calculate deviation from expected probability
  static Map<int, double> calculateProbabilityDeviation(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {};
    
    // Expected probabilities for each outcome (2-12)
    Map<int, double> expectedProbabilities = {
      2: 1/36, 3: 2/36, 4: 3/36, 5: 4/36, 6: 5/36, 7: 6/36,
      8: 5/36, 9: 4/36, 10: 3/36, 11: 2/36, 12: 1/36
    };
    
    Map<int, int> distribution = getRollDistribution(rolls);
    Map<int, double> deviations = {};
    
    for (int i = 2; i <= 12; i++) {
      double actualProbability = distribution[i]! / rolls.length;
      double expectedProbability = expectedProbabilities[i]!;
      deviations[i] = actualProbability - expectedProbability;
    }
    
    return deviations;
  }
  
  // Get hot and cold numbers based on deviation from expected probability
  static Map<String, List<int>> getHotAndColdNumbers(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {'hot': [], 'cold': []};
    
    Map<int, double> deviations = calculateProbabilityDeviation(rolls);
    List<int> hotNumbers = [];
    List<int> coldNumbers = [];
    
    // Consider a number hot if it's at least 20% more frequent than expected
    // and cold if it's at least 20% less frequent
    for (int i = 2; i <= 12; i++) {
      double expectedProbability = i == 7 ? 6/36 : 
                                  (i == 6 || i == 8) ? 5/36 :
                                  (i == 5 || i == 9) ? 4/36 :
                                  (i == 4 || i == 10) ? 3/36 :
                                  (i == 3 || i == 11) ? 2/36 : 1/36;
      
      if (deviations[i]! > expectedProbability * 0.2) {
        hotNumbers.add(i);
      } else if (deviations[i]! < expectedProbability * -0.2) {
        coldNumbers.add(i);
      }
    }
    
    return {'hot': hotNumbers, 'cold': coldNumbers};
  }
  
  // Calculate win rate statistics
  static Map<String, double> calculateWinRateStats(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {'winRate': 0.0, 'comeOutWinRate': 0.0, 'pointsWinRate': 0.0};
    
    int totalWins = rolls.where((roll) => roll.isWin).length;
    int totalLosses = rolls.where((roll) => roll.isLoss).length;
    
    List<DiceRoll> comeOutRolls = rolls.where((roll) => roll.gamePhase == 'comeOut').toList();
    int comeOutWins = comeOutRolls.where((roll) => roll.isWin).length;
    int comeOutLosses = comeOutRolls.where((roll) => roll.isLoss).length;
    
    List<DiceRoll> pointRolls = rolls.where((roll) => roll.gamePhase == 'point').toList();
    int pointWins = pointRolls.where((roll) => roll.isWin).length;
    int pointLosses = pointRolls.where((roll) => roll.isLoss).length;
    
    double overallWinRate = totalWins + totalLosses > 0 ? 
        totalWins / (totalWins + totalLosses) : 0.0;
    
    double comeOutWinRate = comeOutWins + comeOutLosses > 0 ? 
        comeOutWins / (comeOutWins + comeOutLosses) : 0.0;
    
    double pointWinRate = pointWins + pointLosses > 0 ? 
        pointWins / (pointWins + pointLosses) : 0.0;
    
    return {
      'winRate': overallWinRate,
      'comeOutWinRate': comeOutWinRate,
      'pointsWinRate': pointWinRate
    };
  }
  
  // Calculate standard deviation and variance for roll outcomes
  static Map<String, double> calculateRollStatistics(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {'mean': 0.0, 'median': 0.0, 'stdDev': 0.0, 'variance': 0.0};
    
    List<int> rollValues = rolls.map((roll) => roll.rollTotal).toList();
    rollValues.sort();
    
    double mean = rollValues.reduce((a, b) => a + b) / rollValues.length;
    
    double median = rollValues.length % 2 == 1 
        ? rollValues[rollValues.length ~/ 2].toDouble()
        : (rollValues[rollValues.length ~/ 2 - 1] + rollValues[rollValues.length ~/ 2]) / 2;
    
    double variance = rollValues.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / rollValues.length;
    double stdDev = sqrt(variance);
    
    return {
      'mean': mean,
      'median': median,
      'stdDev': stdDev,
      'variance': variance
    };
  }
  
  // Get the average shooter streak length
  static double getAverageStreakLength(List<Session> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    int totalStreaks = sessions.fold(0, (sum, session) => sum + session.sevensOut);
    if (totalStreaks == 0) return 0.0;
    
    int totalRolls = sessions.fold(0, (sum, session) => sum + session.totalRolls);
    return totalRolls / totalStreaks;
  }
  
  // Get player performance metrics
  static Map<String, dynamic> getPlayerPerformanceMetrics(Player player, List<Session> sessions, List<DiceRoll> rolls) {
    if (sessions.isEmpty || rolls.isEmpty) {
      return {'overallWinRate': 0.0, 'avgStreakLength': 0.0, 'bestPoint': null};
    }
    
    List<Session> playerSessions = sessions.where((s) => s.playerId == player.id).toList();
    List<DiceRoll> playerRolls = rolls.where((r) => r.playerId == player.id).toList();
    
    if (playerSessions.isEmpty || playerRolls.isEmpty) {
      return {'overallWinRate': 0.0, 'avgStreakLength': 0.0, 'bestPoint': null};
    }
    
    // Calculate win rate
    int wins = playerRolls.where((r) => r.isWin).length;
    int losses = playerRolls.where((r) => r.isLoss).length;
    double winRate = wins + losses > 0 ? wins / (wins + losses) : 0.0;
    
    // Calculate average streak
    double avgStreak = playerSessions.fold(0, (sum, session) => sum + session.longestRollStreak) / playerSessions.length;
    
    // Find most successful point number
    Map<int, Map<String, int>> pointsPerformance = {
      4: {'made': 0, 'lost': 0},
      5: {'made': 0, 'lost': 0},
      6: {'made': 0, 'lost': 0},
      8: {'made': 0, 'lost': 0},
      9: {'made': 0, 'lost': 0},
      10: {'made': 0, 'lost': 0},
    };
    
    for (var session in playerSessions) {
      session.pointsEstablished.forEach((point, stats) {
        if (pointsPerformance.containsKey(point)) {
          pointsPerformance[point]!['made'] = (pointsPerformance[point]!['made'] ?? 0) + stats['made']!;
          pointsPerformance[point]!['lost'] = (pointsPerformance[point]!['lost'] ?? 0) + stats['lost']!;
        }
      });
    }
    
    int? bestPoint;
    double bestSuccessRate = 0.0;
    
    pointsPerformance.forEach((point, stats) {
      int made = stats['made'] ?? 0;
      int total = (stats['made'] ?? 0) + (stats['lost'] ?? 0);
      if (total > 0) {
        double successRate = made / total;
        if (successRate > bestSuccessRate) {
          bestSuccessRate = successRate;
          bestPoint = point;
        }
      }
    });
    
    return {
      'overallWinRate': winRate,
      'avgStreakLength': avgStreak,
      'bestPoint': bestPoint,
      'bestPointSuccessRate': bestPoint != null ? bestSuccessRate : 0.0,
      'pointsPerformance': pointsPerformance
    };
  }
  
  // Get betting strategy evaluation
  static Map<String, double> evaluateBettingStrategies(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return {};
    
    // Simulate different betting strategies
    double passLineResult = simulatePassLineBetting(rolls);
    double dontPassResult = simulateDontPassBetting(rolls);
    double comeResult = simulateComeBetting(rolls);
    double dontComeResult = simulateDontComeBetting(rolls);
    double placeResult = simulatePlaceBetting(rolls);
    
    return {
      'passLine': passLineResult,
      'dontPass': dontPassResult,
      'come': comeResult,
      'dontCome': dontComeResult,
      'place': placeResult
    };
  }
  
  // Simulations for different betting strategies
  static double simulatePassLineBetting(List<DiceRoll> rolls) {
    double bankroll = 100.0;
    double betSize = 5.0;
    bool hasBet = false;
    int? point;
    
    for (var roll in rolls) {
      if (roll.gamePhase == 'comeOut' && !hasBet) {
        hasBet = true;
        if (roll.outcome == 'natural') {
          bankroll += betSize;
          hasBet = false;
        } else if (roll.outcome == 'craps') {
          bankroll -= betSize;
          hasBet = false;
        } else {
          point = roll.rollTotal;
        }
      } else if (hasBet && point != null) {
        if (roll.rollTotal == point) {
          bankroll += betSize;
          hasBet = false;
          point = null;
        } else if (roll.rollTotal == 7) {
          bankroll -= betSize;
          hasBet = false;
          point = null;
        }
      }
    }
    
    return bankroll - 100.0; // Return profit/loss
  }
  
  static double simulateDontPassBetting(List<DiceRoll> rolls) {
    double bankroll = 100.0;
    double betSize = 5.0;
    bool hasBet = false;
    int? point;
    
    for (var roll in rolls) {
      if (roll.gamePhase == 'comeOut' && !hasBet) {
        hasBet = true;
        if (roll.outcome == 'natural') {
          bankroll -= betSize;
          hasBet = false;
        } else if (roll.outcome == 'craps' && roll.rollTotal != 12) { // Don't Pass bars 12
          bankroll += betSize;
          hasBet = false;
        } else if (roll.rollTotal == 12) { // Push on 12
          hasBet = false;
        } else {
          point = roll.rollTotal;
        }
      } else if (hasBet && point != null) {
        if (roll.rollTotal == point) {
          bankroll -= betSize;
          hasBet = false;
          point = null;
        } else if (roll.rollTotal == 7) {
          bankroll += betSize;
          hasBet = false;
          point = null;
        }
      }
    }
    
    return bankroll - 100.0; // Return profit/loss
  }
  
  // Simplified simulation for Come betting
  static double simulateComeBetting(List<DiceRoll> rolls) {
    // Simplified implementation
    return simulatePassLineBetting(rolls) * 0.9; // Similar to pass line but typically slightly less profitable
  }
  
  // Simplified simulation for Don't Come betting
  static double simulateDontComeBetting(List<DiceRoll> rolls) {
    // Simplified implementation
    return simulateDontPassBetting(rolls) * 0.9; // Similar to don't pass but typically slightly less profitable
  }
  
  // Simplified simulation for Place betting on 6 and 8
  static double simulatePlaceBetting(List<DiceRoll> rolls) {
    double bankroll = 100.0;
    double betSize = 6.0; // $6 place bet on 6 and 8
    
    for (var roll in rolls) {
      if (roll.gamePhase == 'point') {
        if (roll.rollTotal == 6 || roll.rollTotal == 8) {
          bankroll += betSize * 7/6; // Place 6 or 8 pays 7:6
        } else if (roll.rollTotal == 7) {
          bankroll -= betSize * 2; // Lose both place bets
        }
      }
    }
    
    return bankroll - 100.0; // Return profit/loss
  }
} 