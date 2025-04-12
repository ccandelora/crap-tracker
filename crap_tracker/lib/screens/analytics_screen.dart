import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/dice_roll_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/point_success_chart.dart';
import '../widgets/strategy_recommendations.dart';
import '../utils/analytics_util.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';

class AnalyticsScreen extends StatefulWidget {
  final String playerId;

  const AnalyticsScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
      final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

      // Load player data
      await playerProvider.loadPlayers();
      playerProvider.selectPlayer(widget.playerId);

      // Load rolls and sessions
      await diceRollProvider.loadRollsByPlayer(widget.playerId);
      await sessionProvider.loadSessionsByPlayer(widget.playerId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context).selectedPlayer;
    final rolls = Provider.of<DiceRollProvider>(context).playerRolls;
    final sessions = Provider.of<SessionProvider>(context).playerSessions;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('Player not found'),
        ),
      );
    }

    final pointSuccessRates = AnalyticsUtil.calculatePointSuccessRate(sessions, rolls);
    final isHot = AnalyticsUtil.isPlayerHot(player, sessions, rolls);

    return Scaffold(
      appBar: AppBar(
        title: Text('${player.name}\'s Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(player, rolls, isHot),
            const SizedBox(height: 24),
            if (rolls.isNotEmpty) ...[
              _buildStreaksCard(rolls),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PointSuccessChart(successRates: pointSuccessRates),
              ),
              const SizedBox(height: 24),
              StrategyRecommendations(player: player, rolls: rolls),
              const SizedBox(height: 24),
              _buildSevenTracker(),
            ] else
              _buildNoDataCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(player, List<DiceRoll> rolls, bool isHot) {
    final winCount = rolls.where((roll) => roll.isWin).length;
    final lossCount = rolls.where((roll) => roll.isLoss).length;
    final winPercentage = rolls.isEmpty || (winCount + lossCount) == 0 
      ? 0.0 
      : (winCount / (winCount + lossCount) * 100);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Player Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.whatshot, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'HOT',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Rolls', '${player.totalRolls}'),
                _buildStatColumn('Sessions', '${player.totalSessions}'),
                _buildStatColumn('Win Rate', '${winPercentage.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: winPercentage / 100,
              backgroundColor: Colors.red.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wins: $winCount',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Losses: $lossCount',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCard(List<DiceRoll> rolls) {
    final longestWinStreak = AnalyticsUtil.calculateLongestWinningStreak(rolls);
    final longestLossStreak = AnalyticsUtil.calculateLongestLosingStreak(rolls);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streaks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakItem(
                  'Longest Win Streak',
                  longestWinStreak.toString(),
                  Colors.green,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
                _buildStreakItem(
                  'Longest Loss Streak',
                  longestLossStreak.toString(),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataCard() {
    return Center(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.casino,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No roll data yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start rolling dice to see analytics',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.casino),
                label: const Text('Start Rolling'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSevenTracker() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seven Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSevenStatus(
                  'Come Out Phase',
                  '7 IS GOOD',
                  Colors.green,
                  'Win with Pass Line bet',
                ),
                _buildSevenStatus(
                  'Point Phase',
                  '7 IS BAD',
                  Colors.red,
                  'Lose with Pass Line bet',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSevenStatus(String phase, String status, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            phase,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 