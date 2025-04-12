import 'package:flutter/material.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../models/player.dart';

class AnalyticsUtil {
  // Calculate winning streaks from dice rolls
  static int calculateLongestWinningStreak(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return 0;
    
    rolls.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by time
    
    int currentStreak = 0;
    int maxStreak = 0;
    
    for (var roll in rolls) {
      if (roll.isWin) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (roll.isLoss) {
        currentStreak = 0;
      }
    }
    
    return maxStreak;
  }
  
  // Calculate losing streaks from dice rolls
  static int calculateLongestLosingStreak(List<DiceRoll> rolls) {
    if (rolls.isEmpty) return 0;
    
    rolls.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by time
    
    int currentStreak = 0;
    int maxStreak = 0;
    
    for (var roll in rolls) {
      if (roll.isLoss) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (roll.isWin) {
        currentStreak = 0;
      }
    }
    
    return maxStreak;
  }
  
  // Calculate variance for dice rolls
  static double calculateVariance(List<DiceRoll> rolls) {
    if (rolls.length < 2) return 0.0;
    
    // Calculate mean
    double mean = rolls.map((roll) => roll.rollTotal).reduce((a, b) => a + b) / rolls.length;
    
    // Calculate sum of squared differences
    double sumSquaredDiff = rolls.map((roll) => Math.pow(roll.rollTotal - mean, 2)).reduce((a, b) => a + b);
    
    // Return variance
    return sumSquaredDiff / (rolls.length - 1);
  }
  
  // Calculate point making percentage
  static Map<int, double> calculatePointSuccessRate(List<Session> sessions, List<DiceRoll> rolls) {
    Map<int, int> pointsAttempted = {4: 0, 5: 0, 6: 0, 8: 0, 9: 0, 10: 0};
    Map<int, int> pointsMade = {4: 0, 5: 0, 6: 0, 8: 0, 9: 0, 10: 0};
    Map<int, double> successRates = {};
    
    // Group rolls by session
    Map<String, List<DiceRoll>> rollsBySession = {};
    for (var roll in rolls) {
      if (roll.sessionId != null) {
        if (!rollsBySession.containsKey(roll.sessionId)) {
          rollsBySession[roll.sessionId!] = [];
        }
        rollsBySession[roll.sessionId]!.add(roll);
      }
    }
    
    // Process each session
    for (var sessionId in rollsBySession.keys) {
      var sessionRolls = rollsBySession[sessionId]!;
      sessionRolls.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      int? currentPoint;
      bool inPointPhase = false;
      
      for (var roll in sessionRolls) {
        if (!inPointPhase && roll.outcome == RollOutcome.point) {
          // Point established
          inPointPhase = true;
          currentPoint = roll.rollTotal;
          if (pointsAttempted.containsKey(currentPoint)) {
            pointsAttempted[currentPoint!] = pointsAttempted[currentPoint]! + 1;
          }
        } else if (inPointPhase && roll.outcome == RollOutcome.hitPoint) {
          // Point hit
          if (pointsMade.containsKey(currentPoint)) {
            pointsMade[currentPoint!] = pointsMade[currentPoint]! + 1;
          }
          inPointPhase = false;
          currentPoint = null;
        } else if (inPointPhase && roll.outcome == RollOutcome.sevenOut) {
          // Seven out
          inPointPhase = false;
          currentPoint = null;
        }
      }
    }
    
    // Calculate success rates
    for (var point in pointsAttempted.keys) {
      if (pointsAttempted[point]! > 0) {
        successRates[point] = pointsMade[point]! / pointsAttempted[point]! * 100;
      } else {
        successRates[point] = 0.0;
      }
    }
    
    return successRates;
  }
  
  // Calculate theoretical probability of making a point
  static Map<int, double> getTheoreticalPointProbabilities() {
    return {
      4: 33.3, // 3/9 ways to roll 4 before 7
      5: 40.0, // 4/10 ways to roll 5 before 7
      6: 45.5, // 5/11 ways to roll 6 before 7
      8: 45.5, // 5/11 ways to roll 8 before 7
      9: 40.0, // 4/10 ways to roll 9 before 7
      10: 33.3, // 3/9 ways to roll 10 before 7
    };
  }
  
  // Generate strategy recommendations based on player history
  static List<String> generateStrategyRecommendations(Player player, List<DiceRoll> rolls) {
    List<String> recommendations = [];
    
    // Calculate metrics
    var pointSuccessRates = calculatePointSuccessRate([], rolls);
    var theoreticalRates = getTheoreticalPointProbabilities();
    
    // Find strengths and weaknesses
    List<int> strongPoints = [];
    List<int> weakPoints = [];
    
    pointSuccessRates.forEach((point, rate) {
      if (rate > theoreticalRates[point]! + 5) {
        strongPoints.add(point);
      } else if (rate < theoreticalRates[point]! - 5) {
        weakPoints.add(point);
      }
    });
    
    // Generate recommendations
    if (strongPoints.isNotEmpty) {
      recommendations.add('You have above-average success with these points: ${strongPoints.join(', ')}. '
          'Consider placing more Come bets when these numbers are still available.');
    }
    
    if (weakPoints.isNotEmpty) {
      recommendations.add('You have below-average success with these points: ${weakPoints.join(', ')}. '
          'Consider using Don\'t Come bets when these numbers come up.');
    }
    
    // Overall strategy
    var streak = calculateLongestWinningStreak(rolls);
    if (streak >= 3) {
      recommendations.add('You\'ve had winning streaks of $streak rolls. '
          'Consider progressive betting during hot streaks.');
    }
    
    // General recommendations
    recommendations.add('Remember that Pass Line with full odds has the lowest house edge in craps.');
    
    if (rolls.length < 50) {
      recommendations.add('Keep tracking more rolls to get more personalized strategy recommendations.');
    }
    
    return recommendations;
  }
  
  // Analyze sessions to determine if player is "hot"
  static bool isPlayerHot(Player player, List<Session> sessions, List<DiceRoll> rolls) {
    // A player is "hot" if they've made 3 or more points in recent sessions
    
    if (sessions.isEmpty || rolls.isEmpty) return false;
    
    // Sort sessions by recent first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Look at most recent 3 sessions or all if less than 3
    var recentSessions = sessions.take(3).toList();
    var recentSessionIds = recentSessions.map((s) => s.id).toSet();
    
    // Get rolls from these sessions
    var sessionRolls = rolls.where((r) => 
      r.sessionId != null && recentSessionIds.contains(r.sessionId)).toList();
    
    // Count points made
    var pointsMade = sessionRolls.where((r) => r.outcome == RollOutcome.hitPoint).length;
    
    return pointsMade >= 3;
  }
}

// Helper class for math operations
class Math {
  static double pow(double x, double exponent) {
    return x * x; // Simple square for variance calculation
  }
} 