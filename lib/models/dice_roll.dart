import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'dice_roll.g.dart';

@HiveType(typeId: 1)
class DiceRoll {
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

  DiceRoll({
    String? id,
    required this.playerId,
    this.sessionId,
    required this.diceOne,
    required this.diceTwo,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        rollTotal = diceOne + diceTwo,
        timestamp = timestamp ?? DateTime.now();

  static bool isValidDiceValue(int value) {
    return value >= 1 && value <= 6;
  }
} 