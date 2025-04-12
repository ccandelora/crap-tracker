import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/player.dart';
import 'models/dice_roll.dart';
import 'models/session.dart';
import 'models/adapters.dart';
import 'screens/home_screen.dart';
import 'providers/player_provider.dart';
import 'providers/dice_roll_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';

// The app uses a custom logo in the top left of the home screen
// The logo features a white dice with black dots and "THE RAIL" text
// on a black background as shown in the assets/images/logo.png file

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('===== Starting app initialization =====');
    
    // Clear any previous Hive instances (helps with hot restart)
    await Hive.close();
    
    // Initialize Hive
    debugPrint('Getting application documents directory...');
    final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    debugPrint('Documents directory: ${appDocumentDirectory.path}');
    
    debugPrint('Initializing Hive...');
    await Hive.initFlutter(appDocumentDirectory.path);
    
    // Register all adapters from our adapters file
    debugPrint('Registering Hive adapters...');
    registerAdapters();
    
    // Initialize the database service
    debugPrint('Initializing database service...');
    await DatabaseService.init();
    
    // Run the app
    debugPrint('===== App initialization completed. Running app =====');
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
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating PlayerProvider');
          return PlayerProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating DiceRollProvider');
          return DiceRollProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating SessionProvider');
          return SessionProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating ThemeProvider');
          final provider = ThemeProvider();
          // Initialize theme settings asynchronously
          Future.microtask(() => provider.initialize());
          return provider;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'The Rail',
          themeMode: themeProvider.themeMode,
          theme: themeProvider.getLightTheme(),
          darkTheme: themeProvider.getDarkTheme(),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: true,
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
      title: 'The Rail - Error',
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
