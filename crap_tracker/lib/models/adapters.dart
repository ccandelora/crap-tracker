import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'session.dart';
import 'dice_roll.dart';

// This file consolidates Hive adapter registrations
// Adapters must be registered before Hive boxes can be opened

// TypeIDs should be unique across the application
// 0 = PlayerAdapter
// 1 = DiceRollAdapter 
// 2 = SessionAdapter
// 3 = RollOutcomeAdapter
// 4 = GamePhaseAdapter

void registerAdapters() {
  debugPrint('Starting adapter registration...');
  
  try {
    if (!Hive.isAdapterRegistered(0)) {
      debugPrint('Registering PlayerAdapter (typeId: 0)');
      Hive.registerAdapter(PlayerAdapter());
    } else {
      debugPrint('PlayerAdapter already registered');
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      debugPrint('Registering DiceRollAdapter (typeId: 1)');
      Hive.registerAdapter(DiceRollAdapter());
    } else {
      debugPrint('DiceRollAdapter already registered');
    }
    
    if (!Hive.isAdapterRegistered(2)) {
      debugPrint('Registering SessionAdapter (typeId: 2)');
      Hive.registerAdapter(SessionAdapter());
    } else {
      debugPrint('SessionAdapter already registered');
    }
    
    if (!Hive.isAdapterRegistered(3)) {
      debugPrint('Registering RollOutcomeAdapter (typeId: 3)');
      Hive.registerAdapter(RollOutcomeAdapter());
    } else {
      debugPrint('RollOutcomeAdapter already registered');
    }
    
    if (!Hive.isAdapterRegistered(4)) {
      debugPrint('Registering GamePhaseAdapter (typeId: 4)');
      Hive.registerAdapter(GamePhaseAdapter());
    } else {
      debugPrint('GamePhaseAdapter already registered');
    }
    
    debugPrint('All adapters registered successfully');
  } catch (e, stacktrace) {
    debugPrint('Error registering Hive adapters: $e');
    debugPrint('Stack trace: $stacktrace');
    rethrow;
  }
}
