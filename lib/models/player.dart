import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int totalRolls;

  @HiveField(3)
  int totalSessions;

  @HiveField(4)
  double avgRollsPerSession;

  Player({
    String? id,
    required this.name,
    this.totalRolls = 0,
    this.totalSessions = 0,
    this.avgRollsPerSession = 0.0,
  }) : id = id ?? const Uuid().v4();

  void incrementRolls() {
    totalRolls++;
  }

  void incrementSessions() {
    totalSessions++;
  }

  void updateAvgRollsPerSession(int sessionRolls) {
    if (totalSessions == 0) {
      avgRollsPerSession = sessionRolls.toDouble();
    } else {
      avgRollsPerSession = ((avgRollsPerSession * (totalSessions - 1)) + sessionRolls) / totalSessions;
    }
  }
} 