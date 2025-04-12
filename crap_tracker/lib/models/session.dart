import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dice_roll.dart';

part 'session.g.dart';

// Game phases in craps
@HiveType(typeId: 4)
enum GamePhase {
  @HiveField(0)
  comeOut,  // Initial phase where 7/11 win, 2/3/12 lose
  
  @HiveField(1)
  point     // Phase after point established where point wins, 7 loses
}

@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String playerId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int totalRolls;

  @HiveField(5)
  int get durationInSeconds => 
    endTime != null 
      ? endTime!.difference(startTime).inSeconds 
      : DateTime.now().difference(startTime).inSeconds;

  @HiveField(6)
  bool isActive;
  
  @HiveField(7)
  GamePhase gamePhase;
  
  @HiveField(8)
  int? point; // The established point (4, 5, 6, 8, 9, or 10)

  // New fields to track session statistics
  @HiveField(9)
  int comeOutWins;
  
  @HiveField(10)
  int comeOutLosses;
  
  @HiveField(11)
  int pointsMade;
  
  @HiveField(12)
  int sevensOut;
  
  @HiveField(13)
  int longestRollStreak;
  
  @HiveField(14)
  int currentRollStreak;
  
  @HiveField(15)
  Map<int, int> pointsEstablished;

  @HiveField(16)
  List<String> playerOrder;

  Session({
    String? id,
    required this.playerId,
    required this.startTime,
    this.endTime,
    this.totalRolls = 0,
    this.isActive = true,
    this.gamePhase = GamePhase.comeOut,
    this.point,
    this.comeOutWins = 0,
    this.comeOutLosses = 0,
    this.pointsMade = 0,
    this.sevensOut = 0,
    this.longestRollStreak = 0,
    this.currentRollStreak = 0,
    Map<int, int>? pointsEstablished,
    List<String>? playerOrder,
  }) : 
    id = id ?? const Uuid().v4(),
    pointsEstablished = pointsEstablished ?? {4: 0, 5: 0, 6: 0, 8: 0, 9: 0, 10: 0},
    playerOrder = playerOrder ?? [];

  /// Increment roll count for the session
  void incrementRolls() {
    totalRolls++;
  }
  
  /// Update session stats based on a new roll
  void updateStats(DiceRoll roll) {
    incrementRolls();
    currentRollStreak++;
    
    if (currentRollStreak > longestRollStreak) {
      longestRollStreak = currentRollStreak;
    }
    
    // Update phase-specific statistics
    if (roll.gamePhase == GamePhase.comeOut) {
      if (roll.outcome == RollOutcome.natural) {
        comeOutWins++;
        currentRollStreak = 0; // Reset streak on win
      } else if (roll.outcome == RollOutcome.craps) {
        comeOutLosses++;
        currentRollStreak = 0; // Reset streak on loss
      } else if (roll.outcome == RollOutcome.point) {
        // Point established
        pointsEstablished[roll.rollTotal] = (pointsEstablished[roll.rollTotal] ?? 0) + 1;
      }
    } else {
      // Point phase
      if (roll.outcome == RollOutcome.hitPoint) {
        pointsMade++;
        currentRollStreak = 0; // Reset streak on win
      } else if (roll.outcome == RollOutcome.sevenOut) {
        sevensOut++;
        currentRollStreak = 0; // Reset streak on loss
      }
    }
  }
  
  /// End the session and record end time
  void endSession() {
    if (isActive) {
      endTime = DateTime.now();
      isActive = false;
    }
  }
  
  /// Set the point for this session
  void setPoint(int newPoint) {
    point = newPoint;
    gamePhase = GamePhase.point;
  }
  
  /// Clear the point (point made or seven out)
  void clearPoint() {
    point = null;
    gamePhase = GamePhase.comeOut;
  }
  
  /// Check if session has ended
  bool get hasEnded => !isActive && endTime != null;
  
  /// Calculate win-loss ratio for this session
  double get winLossRatio {
    int wins = comeOutWins + pointsMade;
    int losses = comeOutLosses + sevensOut;
    return losses > 0 ? wins / losses : (wins > 0 ? double.infinity : 0);
  }
  
  /// Calculate win rate percentage
  double get winRate {
    int totalDecisions = comeOutWins + comeOutLosses + pointsMade + sevensOut;
    int wins = comeOutWins + pointsMade;
    return totalDecisions > 0 ? (wins / totalDecisions) * 100 : 0;
  }
  
  /// Get the most frequently established point
  int? get mostFrequentPoint {
    if (pointsEstablished.isEmpty) return null;
    
    int? maxPoint;
    int maxCount = 0;
    
    pointsEstablished.forEach((point, count) {
      if (count > maxCount) {
        maxCount = count;
        maxPoint = point;
      }
    });
    
    return maxPoint;
  }
  
  /// Get a summary of session performance
  Map<String, dynamic> getPerformanceSummary() {
    return {
      'winRate': winRate,
      'totalRolls': totalRolls,
      'comeOutWins': comeOutWins,
      'comeOutLosses': comeOutLosses,
      'pointsMade': pointsMade,
      'sevensOut': sevensOut,
      'longestStreak': longestRollStreak,
      'duration': durationInSeconds,
      'mostFrequentPoint': mostFrequentPoint,
      'pointsEstablished': pointsEstablished,
    };
  }

  void addPlayerToOrder(String playerId) {
    if (!playerOrder.contains(playerId)) {
      playerOrder.add(playerId);
    }
  }
  
  void removePlayerFromOrder(String playerId) {
    playerOrder.remove(playerId);
  }
  
  void reorderPlayer(String playerId, int newIndex) {
    if (playerOrder.contains(playerId)) {
      playerOrder.remove(playerId);
      if (newIndex > playerOrder.length) {
        playerOrder.add(playerId);
      } else {
        playerOrder.insert(newIndex, playerId);
      }
    }
  }
}
