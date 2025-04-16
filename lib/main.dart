import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/player.dart';
import 'models/dice_roll.dart';
import 'models/session.dart';
import 'models/adapters.dart';
import 'services/database_service.dart';
import 'providers/player_provider.dart';
import 'providers/dice_roll_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('===== Starting app initialization =====');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Initialize Hive
    final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);
    
    // Register all adapters from our adapters file
    registerAdapters();
    
    // Open boxes
    await Hive.openBox<Player>('players');
    await Hive.openBox<DiceRoll>('diceRolls');
    await Hive.openBox<Session>('sessions');
    await Hive.openBox('theme_preferences');
    
    // Initialize the database service
    await DatabaseService.init();
    
    // Run the app
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Show error if initialization failed
    debugPrint('===== CRITICAL ERROR: App initialization failed =====');
    debugPrint('Error: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DiceRollProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = ThemeProvider();
          // Initialize theme settings asynchronously
          Future.microtask(() => provider.initialize());
          return provider;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Dice Analytics Tool',
          themeMode: themeProvider.themeMode,
          theme: themeProvider.getLightTheme(),
          darkTheme: themeProvider.getDarkTheme(),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

// Widget to show initialization errors
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Analytics - Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Initialization Error'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Try to restart the app - this is a simple restart
                  // in a real app you might want to add more sophisticated recovery
                  main();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 