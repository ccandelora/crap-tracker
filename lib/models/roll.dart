import 'package:hive/hive.dart';
part 'roll.g.dart';

@HiveType(typeId: 2)
class Roll extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final int dice1;

  @HiveField(4)
  final int dice2;

  @HiveField(5)
  final int total;

  Roll({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.dice1,
    required this.dice2,
    required this.total,
  });

  bool get isWin {
    if (total == 7 || total == 11) {
      return true;
    }
    return false;
  }

  bool get isCraps {
    if (total == 2 || total == 3 || total == 12) {
      return true;
    }
    return false;
  }

  bool get isPoint {
    return !isWin && !isCraps;
  }
} 