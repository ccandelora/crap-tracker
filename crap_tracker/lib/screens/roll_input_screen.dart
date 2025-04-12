import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/dice_roll_provider.dart';
import '../providers/session_provider.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../widgets/animated_dice.dart';
import '../screens/all_rolls_screen.dart';
import '../screens/player_stats_screen.dart';
import '../screens/session_players_screen.dart';
import 'dart:math';
import 'dart:async';
import '../services/database_service.dart';

// Helper extension for safe firstWhere
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class RollInputScreen extends StatefulWidget {
  final String playerId;
  
  const RollInputScreen({
    super.key,
    required this.playerId,
  });
  
  @override
  State<RollInputScreen> createState() => _RollInputScreenState();
}

class _RollInputScreenState extends State<RollInputScreen> {
  int? _diceOne;
  int? _diceTwo;
  bool _sessionActive = false;
  String? _sessionId;
  bool _showingAllRolls = false;
  bool _isSimulating = false;
  Timer? _simulationTimer;
  final Random _random = Random();
  int _simulationSpeed = 1000; // milliseconds between rolls
  int _simulationCount = 0; // total rolls in current simulation
  int _maxSimulationRolls = 100; // maximum number of rolls to simulate
  
  @override
  void initState() {
    super.initState();
    
    // Load active session if exists, or create a new one
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      await sessionProvider.loadActiveSessionForPlayer(widget.playerId);
      
      if (sessionProvider.activeSession != null) {
        setState(() {
          _sessionActive = true;
          _sessionId = sessionProvider.activeSession!.id;
        });
      } else {
        _startNewSession();
      }
      
      // Load existing rolls for this player
      await Provider.of<DiceRollProvider>(context, listen: false)
        .loadRollsByPlayer(widget.playerId);
    });
  }
  
  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context).selectedPlayer;
    final diceRollProvider = Provider.of<DiceRollProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    
    final rollCount = sessionProvider.activeSession?.totalRolls ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${player?.name ?? "Player"}\'s Rolls'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _showSessionPlayersScreen,
            tooltip: 'Manage Session Players',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _navigateToAllRolls,
            tooltip: 'View All Table Rolls',
          ),
          IconButton(
            icon: Icon(_sessionActive ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleSession,
            tooltip: _sessionActive ? 'End Session' : 'Start Session',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSessionInfo(rollCount),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Roll Values',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDiceSelection(),
                    const SizedBox(height: 32),
                    _buildDiceTotal(),
                    const SizedBox(height: 24),
                    _buildRollButton(),
                    const SizedBox(height: 24),
                    _buildSimulationControls(),
                    const SizedBox(height: 24),
                    _buildRecentRolls(diceRollProvider.playerRolls),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionInfo(int rollCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sessionActive 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _sessionActive ? Icons.timer : Icons.timer_off,
                color: _sessionActive 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sessionActive ? 'Session Active' : 'Session Inactive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _sessionActive 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade700,
                      ),
                    ),
                    if (_sessionActive)
                      Text(
                        'Total rolls: $rollCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _toggleSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sessionActive 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  foregroundColor: _sessionActive ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_sessionActive ? Icons.stop : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(_sessionActive ? 'End Session' : 'Start Session'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiceSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDiceSelector(1, (value) => setState(() => _diceOne = value)),
        _buildDiceSelector(2, (value) => setState(() => _diceTwo = value)),
      ],
    );
  }
  
  Widget _buildDiceSelector(int diceNumber, Function(int) onChanged) {
    final currentValue = diceNumber == 1 ? _diceOne : _diceTwo;
    
    return Column(
      children: [
        Text(
          'Dice $diceNumber',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: currentValue,
            hint: const Text('Select'),
            underline: const SizedBox(),
            items: [1, 2, 3, 4, 5, 6].map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDiceTotal() {
    final hasRoll = _diceOne != null && _diceTwo != null;
    final total = (_diceOne ?? 0) + (_diceTwo ?? 0);
    
    // Get the current session and its state
    final sessionProvider = Provider.of<SessionProvider>(context);
    final session = sessionProvider.activeSession;
    final isPointPhase = session?.gamePhase == GamePhase.point;
    final currentPoint = session?.point;
    
    // Determine outcome text based on current game state
    String outcomeText = '';
    Color outcomeColor = Colors.grey;
    
    if (hasRoll && session != null) {
      if (isPointPhase) {
        // Point phase
        if (total == currentPoint) {
          outcomeText = 'Hit Point - Win!';
          outcomeColor = Colors.green;
        } else if (total == 7) {
          outcomeText = 'Seven Out - Loss';
          outcomeColor = Colors.red;
        } else {
          // No outcome text for non-decisive rolls
          outcomeText = '';
        }
      } else {
        // Come-out phase
        if (total == 7 || total == 11) {
          outcomeText = 'Natural - Win!';
          outcomeColor = Colors.green;
        } else if (total == 2 || total == 3 || total == 12) {
          outcomeText = 'Craps - Loss';
          outcomeColor = Colors.red;
        } else {
          outcomeText = 'Point Established';
          outcomeColor = Colors.blue;
        }
      }
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasRoll)
              Row(
                children: [
                  AnimatedDice(value: _diceOne!),
                  const SizedBox(width: 16),
                  AnimatedDice(value: _diceTwo!),
                ],
              )
            else
              const Text(
                'Select dice values above',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasRoll) ...[
          Text(
            'Total: $total',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (outcomeText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: outcomeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: outcomeColor,
                  width: 1,
                ),
              ),
              child: Text(
                outcomeText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: outcomeColor,
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        if (session != null) ...[
          // Game phase indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPointPhase ? 'Point Phase' : 'Come-Out Roll',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isPointPhase ? Colors.orange : Colors.blue,
                ),
              ),
            ],
          ),
          // Current point indicator
          if (isPointPhase && currentPoint != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Text(
                'Point: $currentPoint',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ],
    );
  }
  
  Widget _buildRollButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _diceOne != null && _diceTwo != null ? _submitRoll : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.casino),
                SizedBox(width: 8),
                Text(
                  'SUBMIT ROLL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSimulationControls() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Auto-Roll Simulation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Automatically simulates multiple dice rolls to generate statistics quickly. Useful for analysis.',
                      preferBelow: false,
                      child: const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (_isSimulating)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.lightGreen,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Running: $_simulationCount/$_maxSimulationRolls',
                          style: const TextStyle(
                            color: Colors.lightGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_simulationCount > 0 && !_isSimulating)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last simulation: $_simulationCount rolls',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Speed: ${(_simulationSpeed / 1000).toStringAsFixed(1)}s between rolls',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerStatsScreen(playerId: widget.playerId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View Stats'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Speed:'),
                Expanded(
                  child: Slider(
                    value: _simulationSpeed.toDouble(),
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    label: '${(_simulationSpeed / 1000).toStringAsFixed(1)}s',
                    onChanged: _isSimulating 
                        ? null 
                        : (value) {
                            setState(() {
                              _simulationSpeed = value.toInt();
                            });
                          },
                  ),
                ),
                Text('${(_simulationSpeed / 1000).toStringAsFixed(1)}s'),
              ],
            ),
            Row(
              children: [
                const Text('Max Rolls:'),
                Expanded(
                  child: Slider(
                    value: _maxSimulationRolls.toDouble(),
                    min: 10,
                    max: 1000,
                    divisions: 99,
                    label: _maxSimulationRolls.toString(),
                    onChanged: _isSimulating 
                        ? null 
                        : (value) {
                            setState(() {
                              _maxSimulationRolls = value.toInt();
                            });
                          },
                  ),
                ),
                Text('$_maxSimulationRolls'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sessionActive 
                        ? (_isSimulating ? _stopSimulation : _startSimulation)
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _isSimulating ? Colors.red : Colors.green,
                      backgroundColor: _isSimulating 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.green.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledForegroundColor: Colors.grey.withOpacity(0.38),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isSimulating ? Icons.stop : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(
                          _isSimulating ? 'STOP SIMULATION' : 'START SIMULATION',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_sessionActive)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Start a session first to enable simulation',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _submitRoll() {
    if (_diceOne == null || _diceTwo == null) return;
    
    if (!_sessionActive || _sessionId == null) {
      _startNewSession().then((_) {
        if (_sessionActive && _sessionId != null) {
          _addRoll();
        }
      });
    } else {
      _addRoll();
    }
  }
  
  void _addRoll() {
    if (_diceOne == null || _diceTwo == null || _sessionId == null) return;
    
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    // Get current game state
    final session = sessionProvider.activeSession;
    if (session == null) return;
    
    // Add the roll and get the result
    diceRollProvider.addRoll(
      playerId: widget.playerId,
      sessionId: _sessionId!,
      diceOne: _diceOne!,
      diceTwo: _diceTwo!,
      gamePhase: session.gamePhase,
      point: session.point,
    ).then((roll) {
      // Process game state changes based on the roll outcome
      sessionProvider.processRoll(_sessionId!, roll.rollTotal).then((_) {
        // Increment session roll count
        sessionProvider.incrementSessionRolls(_sessionId!);
        
        // Update player's roll count
        final player = playerProvider.selectedPlayer;
        if (player != null) {
          player.incrementRolls();
          playerProvider.updatePlayer(player);
        }
        
        // If not simulating, reset dice values for next roll
        if (!_isSimulating) {
          setState(() {
            _diceOne = null;
            _diceTwo = null;
          });
        }
      });
    });
  }
  
  Widget _buildRecentRolls(List<DiceRoll> rolls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Rolls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (rolls.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'No rolls yet. Start rolling!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rolls.length.clamp(0, 10), // Show only the 10 most recent rolls
            itemBuilder: (context, index) {
              final roll = rolls[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      '${roll.rollTotal}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${roll.diceOne} + ${roll.diceTwo} = ${roll.rollTotal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(roll.outcomeDescription),
                  trailing: Text(
                    '${roll.timestamp.hour}:${roll.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  void _toggleSession() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    if (_sessionActive && _sessionId != null) {
      // End the current session
      sessionProvider.endSession(_sessionId!).then((_) {
        setState(() {
          _sessionActive = false;
          _sessionId = null;
        });
        
        // Synchronize player session count with the database
        DatabaseService.synchronizePlayerSessionCount(widget.playerId).then((_) {
          // Reload data to refresh UI
          _refreshData();
        });
      });
    } else {
      // Start a new session
      _startNewSession();
    }
  }
  
  Future<void> _startNewSession() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    try {
      final sessionId = await sessionProvider.startNewSession(widget.playerId);
      if (sessionId != null) {
        setState(() {
          _sessionActive = true;
          _sessionId = sessionId;
        });
      }
    } catch (e) {
      debugPrint('Error starting new session: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start a new session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _navigateToAllRolls() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllRollsScreen(),
      ),
    );
  }
  
  void _startSimulation() {
    if (_isSimulating) return;
    
    // Create a new session if needed
    if (!_sessionActive || _sessionId == null) {
      _startNewSession().then((_) {
        if (_sessionActive && _sessionId != null) {
          _startSimulationTimer();
        }
      });
    } else {
      _startSimulationTimer();
    }
  }
  
  void _startSimulationTimer() {
    setState(() {
      _isSimulating = true;
      _simulationCount = 0;
    });
    
    // Create a periodic timer for simulation
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: _simulationSpeed),
      (timer) {
        if (_simulationCount >= _maxSimulationRolls) {
          _stopSimulation();
          return;
        }
        
        // Generate random dice values
        final dice1 = _random.nextInt(6) + 1;
        final dice2 = _random.nextInt(6) + 1;
        
        setState(() {
          _diceOne = dice1;
          _diceTwo = dice2;
        });
        
        // Submit the roll
        _addRoll();
        
        // Increment the counter
        setState(() {
          _simulationCount++;
        });
      },
    );
  }
  
  void _stopSimulation() {
    if (_simulationTimer != null) {
      _simulationTimer!.cancel();
      _simulationTimer = null;
    }
    
    setState(() {
      _isSimulating = false;
    });
    
    // Refresh data after simulation to ensure stats are updated throughout the app
    if (_simulationCount > 0) {
      // Do a full synchronization between simulated sessions and player stats
      _synchronizeAfterSimulation();
    }
  }
  
  Future<void> _synchronizeAfterSimulation() async {
    try {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      // Make sure the session is marked as a game in stats
      if (_sessionId != null) {
        final session = await sessionProvider.getSession(_sessionId!);
        if (session != null && session.isActive) {
          debugPrint('Simulation complete: $_simulationCount rolls, setting session as a game');
        }
      }
      
      // Run the full refresh to update stats
      await _refreshData();
      
    } catch (e) {
      debugPrint('Error synchronizing after simulation: $e');
    }
  }
  
  Future<void> _refreshData() async {
    // Refresh all data providers to ensure UI shows current values
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // First synchronize player session and roll counts with the database
    await DatabaseService.synchronizePlayerSessionCount(widget.playerId);
    await DatabaseService.synchronizePlayerRollCount(widget.playerId);
    
    // Reload all sessions
    await sessionProvider.loadSessions();
    
    // Reload session data for this player specifically
    await sessionProvider.loadSessionsByPlayer(widget.playerId);
    await sessionProvider.loadActiveSessionForPlayer(widget.playerId);
    
    // Reload roll data
    await diceRollProvider.loadRollsByPlayer(widget.playerId);
    
    // Reload player data - this needs to be loaded after sessions to get accurate counts
    await playerProvider.loadPlayers();
    if (widget.playerId.isNotEmpty) {
      playerProvider.selectPlayer(widget.playerId);
    }
    
    // Notify user of completed simulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulation completed with $_simulationCount rolls'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW STATS',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerStatsScreen(playerId: widget.playerId),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSessionPlayersScreen() {
    if (!_sessionActive || _sessionId == null) {
      // Show a dialog indicating they need to start a session first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Active Session'),
          content: const Text('You need to start a session before you can manage players.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewSession().then((_) {
                  if (_sessionActive && _sessionId != null) {
                    _navigateToSessionPlayers();
                  }
                });
              },
              child: const Text('Start Session'),
            ),
          ],
        ),
      );
      return;
    }
    
    _navigateToSessionPlayers();
  }
  
  void _navigateToSessionPlayers() {
    if (_sessionId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionPlayersScreen(sessionId: _sessionId!),
      ),
    ).then((_) {
      // Refresh data when returning from the session players screen
      _refreshData();
    });
  }
}
