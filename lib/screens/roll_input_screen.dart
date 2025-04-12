import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crap_tracker/models/player.dart';
import 'package:crap_tracker/models/dice_roll.dart';
import 'package:crap_tracker/providers/dice_roll_provider.dart';
import 'package:crap_tracker/providers/player_provider.dart';
import 'package:crap_tracker/providers/session_provider.dart';
import 'package:crap_tracker/utils/probability_calculator.dart';
import 'package:crap_tracker/widgets/dice_input_widget.dart';
import 'package:crap_tracker/widgets/dice_widget.dart';
import 'package:crap_tracker/widgets/probability_chart_widget.dart';
import 'package:intl/intl.dart';

class RollInputScreen extends StatefulWidget {
  final Player player;

  const RollInputScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<RollInputScreen> createState() => _RollInputScreenState();
}

class _RollInputScreenState extends State<RollInputScreen> {
  List<DiceRoll> _recentRolls = [];
  bool _isLoadingSession = true;
  bool _showProbability = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Load rolls for this player
    await diceRollProvider.loadRollsByPlayer(widget.player.id);
    
    // Initialize session (creates one if not exists)
    await sessionProvider.loadActiveSessionForPlayer(widget.player.id);
    if (!sessionProvider.hasActiveSession) {
      await sessionProvider.startSession(widget.player.id);
    }
    
    // Update recent rolls
    setState(() {
      _recentRolls = diceRollProvider.rolls.take(5).toList();
      _isLoadingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.player.name}\'s Rolls'),
        actions: [
          Consumer<SessionProvider>(
            builder: (context, sessionProvider, child) {
              if (!sessionProvider.hasActiveSession) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    await sessionProvider.startSession(widget.player.id);
                  },
                  tooltip: 'Start New Session',
                );
              }
              
              return IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () => _confirmEndSession(sessionProvider),
                tooltip: 'End Session',
              );
            },
          ),
          IconButton(
            icon: Icon(_showProbability ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showProbability = !_showProbability;
              });
            },
            tooltip: _showProbability ? 'Hide Probabilities' : 'Show Probabilities',
          ),
        ],
      ),
      body: _isLoadingSession
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildSessionInfo(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildRecentRolls(),
                          const SizedBox(height: 24),
                          if (_showProbability) _buildProbabilityChart(),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildDiceRollingSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionInfo() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        final activeSession = sessionProvider.activeSession;
        
        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeSession != null ? 'Active Session' : 'No Active Session',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (activeSession != null)
                      Text(
                        'Started ${DateFormat('MMM d, h:mm a').format(activeSession.startTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (activeSession != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.casino, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${activeSession.totalRolls} rolls',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentRolls() {
    if (_recentRolls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No rolls yet. Use the input below to add your first roll.',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recent Rolls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentRolls.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final roll = _recentRolls[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          DiceWidget(value: roll.diceOne, size: 40),
                          const SizedBox(width: 8),
                          DiceWidget(value: roll.diceTwo, size: 40),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${roll.rollTotal}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityChart() {
    return Consumer<DiceRollProvider>(
      builder: (context, diceRollProvider, child) {
        // Get historical roll totals
        final rollTotals = diceRollProvider.getRollTotals();
        
        // Calculate probabilities based on historical data
        final probabilities = ProbabilityCalculator.getAllProbabilities(rollTotals);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Next Roll Probabilities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProbabilityChartWidget(
              probabilities: probabilities,
              title: '',
              barColor: Theme.of(context).primaryColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiceRollingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Roll Values',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DiceInputWidget(
            onDiceRolled: _handleDiceRolled,
          ),
        ],
      ),
    );
  }

  Future<void> _handleDiceRolled(int diceOne, int diceTwo) async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    // Make sure we have an active session
    if (!sessionProvider.hasActiveSession) {
      await sessionProvider.startSession(widget.player.id);
    }
    
    // Add the roll
    final sessionId = sessionProvider.activeSession?.id;
    final roll = await diceRollProvider.addRoll(
      widget.player.id,
      diceOne,
      diceTwo,
      sessionId,
    );
    
    // Update the session roll count
    await sessionProvider.incrementSessionRollCount();
    
    // Update player stats
    final updatedPlayer = Player(
      id: widget.player.id,
      name: widget.player.name,
      totalRolls: widget.player.totalRolls + 1,
      totalSessions: widget.player.totalSessions,
      avgRollsPerSession: widget.player.avgRollsPerSession,
    );
    updatedPlayer.incrementRolls();
    await playerProvider.updatePlayer(updatedPlayer);
    
    // Update recent rolls UI
    setState(() {
      _recentRolls = [roll, ..._recentRolls];
      if (_recentRolls.length > 5) {
        _recentRolls = _recentRolls.sublist(0, 5);
      }
    });
    
    // Check for seven-out condition (roll = 7 ends the session)
    final sevenOut = await sessionProvider.checkSevenOut(roll.rollTotal);
    if (sevenOut) {
      // Show seven out notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seven Out! Session ended.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // Update player's session count
      final player = Player(
        id: widget.player.id,
        name: widget.player.name,
        totalRolls: updatedPlayer.totalRolls,
        totalSessions: widget.player.totalSessions + 1,
        avgRollsPerSession: widget.player.avgRollsPerSession,
      );
      player.incrementSessions();
      
      // Update average rolls per session
      final sessionRolls = sessionProvider.activeSession?.totalRolls ?? 0;
      player.updateAvgRollsPerSession(sessionRolls);
      
      await playerProvider.updatePlayer(player);
    }
  }

  void _confirmEndSession(SessionProvider sessionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end the current session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final sessionRolls = sessionProvider.activeSession?.totalRolls ?? 0;
              await sessionProvider.endActiveSession(sessionRolls);
              
              // Update player's session stats
              final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
              final player = Player(
                id: widget.player.id,
                name: widget.player.name,
                totalRolls: widget.player.totalRolls,
                totalSessions: widget.player.totalSessions + 1,
                avgRollsPerSession: widget.player.avgRollsPerSession,
              );
              player.incrementSessions();
              player.updateAvgRollsPerSession(sessionRolls);
              await playerProvider.updatePlayer(player);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session ended successfully'),
                  ),
                );
              }
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
} 