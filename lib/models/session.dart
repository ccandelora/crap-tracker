import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class Session {
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
  int durationInSeconds;

  @HiveField(6)
  bool isActive;

  Session({
    String? id,
    required this.playerId,
    DateTime? startTime,
    this.endTime,
    this.totalRolls = 0,
    this.durationInSeconds = 0,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now();

  void incrementRolls() {
    totalRolls++;
  }

  void endSession() {
    if (isActive) {
      endTime = DateTime.now();
      durationInSeconds = endTime!.difference(startTime).inSeconds;
      isActive = false;
    }
  }

  bool get isEnded => endTime != null;
} 