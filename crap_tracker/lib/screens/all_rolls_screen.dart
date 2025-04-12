import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dice_roll_provider.dart';
import '../providers/player_provider.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';

class AllRollsScreen extends StatefulWidget {
  const AllRollsScreen({super.key});

  @override
  State<AllRollsScreen> createState() => _AllRollsScreenState();
}

class _AllRollsScreenState extends State<AllRollsScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all rolls
      await Provider.of<DiceRollProvider>(context, listen: false).loadRolls();
      
      // Load all players for names
      await Provider.of<PlayerProvider>(context, listen: false).loadPlayers();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      debugPrint('Error loading rolls: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rolls'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading rolls...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
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
              'Failed to load rolls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final rolls = Provider.of<DiceRollProvider>(context).rolls;
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (rolls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSummary(rolls),
        Expanded(
          child: ListView.builder(
            itemCount: rolls.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final roll = rolls[index];
              return _buildRollItem(roll, playerProvider.getPlayerName(roll.playerId));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(List<DiceRoll> rolls) {
    final diceRollProvider = Provider.of<DiceRollProvider>(context);
    final winCount = diceRollProvider.getWinCount(rolls);
    final lossCount = diceRollProvider.getLossCount(rolls);
    final winPercentage = diceRollProvider.getWinPercentage(rolls);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Text(
            'Total Rolls: ${rolls.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Wins',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$winCount',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Losses',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$lossCount',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Win %',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${winPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.casino_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Rolls Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add players and rolls to track them',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRollItem(DiceRoll roll, String playerName) {
    final dateFormat = '${roll.timestamp.month}/${roll.timestamp.day}/${roll.timestamp.year}';
    final timeFormat = '${roll.timestamp.hour}:${roll.timestamp.minute.toString().padLeft(2, '0')}';
    
    // Get color based on outcome
    Color outcomeColor;
    if (roll.outcome == RollOutcome.natural || 
        roll.outcome == RollOutcome.hitPoint) {
      outcomeColor = Colors.green;
    } else if (roll.outcome == RollOutcome.craps || 
                roll.outcome == RollOutcome.sevenOut) {
      outcomeColor = Colors.red;
    } else {
      outcomeColor = Colors.blue;
    }
    
    String phaseText = roll.gamePhase == GamePhase.comeOut 
        ? 'Come Out' 
        : 'Point: ${roll.point}';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$dateFormat $timeFormat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${roll.diceOne}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Die 1'),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${roll.diceTwo}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Die 2'),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: outcomeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: outcomeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${roll.rollTotal}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: outcomeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Total'),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: outcomeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roll.outcomeDescription,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: outcomeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        phaseText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 