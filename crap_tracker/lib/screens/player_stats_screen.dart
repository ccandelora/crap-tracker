import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/dice_roll_provider.dart';
import '../providers/session_provider.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../models/player.dart';
import '../widgets/stats_dashboard.dart';
import 'analytics_screen.dart';
import '../services/database_service.dart';

class PlayerStatsScreen extends StatefulWidget {
  final String playerId;
  
  const PlayerStatsScreen({
    super.key,
    required this.playerId,
  });
  
  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDataLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load player data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAndSynchronizeData();
    });
  }
  
  Future<void> _loadAndSynchronizeData() async {
    // Skip if data is already loaded to prevent infinite loops
    if (_isDataLoaded) return;
    
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    try {
      // First perform full database synchronization to make sure all stats are correct
      await DatabaseService.synchronizePlayerRollCount(widget.playerId);
      await DatabaseService.synchronizePlayerSessionCount(widget.playerId);
      
      // Load all data
      await diceRollProvider.loadRollsByPlayer(widget.playerId);
      await playerProvider.loadPlayers();
      await sessionProvider.loadSessionsByPlayer(widget.playerId);
      
      // Get player and roll counts
      playerProvider.selectPlayer(widget.playerId);
      final player = playerProvider.selectedPlayer;
      final List<DiceRoll> rolls = diceRollProvider.playerRolls;
      
      // Log current stats
      if (player != null) {
        debugPrint('Loaded player stats: ${player.name}');
        debugPrint('- Total rolls: ${player.totalRolls}');
        debugPrint('- Total games: ${player.totalGames}');
        debugPrint('- Total sessions: ${player.totalSessions}');
        debugPrint('- Avg rolls/session: ${player.avgRollsPerSession.toStringAsFixed(1)}');
      }
      
      // Mark data as loaded to prevent future reload loops
      _isDataLoaded = true;
      
      // Trigger a rebuild after data is loaded and synchronized
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading and synchronizing player data: $e');
      // Still try to show UI even if sync fails
      _isDataLoaded = true; // Still mark as loaded to prevent loops
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Removed _loadAndSynchronizeData() call to prevent infinite loop
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context).selectedPlayer;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${player?.name ?? "Player"}\'s Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    final player = Provider.of<PlayerProvider>(context).selectedPlayer;
    final sessions = Provider.of<SessionProvider>(context).playerSessions;
    final diceRollProvider = Provider.of<DiceRollProvider>(context);
    final rolls = diceRollProvider.playerRolls;
    
    // Calculate win/loss statistics
    final winCount = diceRollProvider.getWinCount(rolls);
    final lossCount = diceRollProvider.getLossCount(rolls);
    final winPercentage = diceRollProvider.getWinPercentage(rolls);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (player != null)
            StatsDashboard(
              player: player,
              rolls: rolls,
              winCount: winCount,
              lossCount: lossCount,
              winPercentage: winPercentage,
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyticsScreen(playerId: player!.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Advanced Analytics'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRecentSessions(sessions),
        ],
      ),
    );
  }
  
  Widget _buildRecentSessions(List<Session> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sessions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        sessions.isEmpty
            ? _buildEmptySessionsState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length.clamp(0, 5), // Show up to 5 most recent
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionItem(session);
                },
              ),
      ],
    );
  }
  
  Widget _buildEmptySessionsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Sessions Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start rolling to create a session',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionItem(Session session) {
    final dateFormat = '${session.startTime.month}/${session.startTime.day}/${session.startTime.year}';
    final timeFormat = '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          child: Text(
            '${session.totalRolls}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Session on $dateFormat',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          session.isActive ? 'Active session' : 'Completed - $timeFormat',
        ),
        trailing: Icon(
          session.isActive ? Icons.access_time : Icons.check_circle_outline,
          color: session.isActive ? Colors.green : Colors.grey.shade400,
        ),
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    final rolls = Provider.of<DiceRollProvider>(context).playerRolls;
    
    return rolls.isEmpty
        ? _buildEmptyRollsState()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: rolls.length,
            itemBuilder: (context, index) {
              final roll = rolls[index];
              return _buildRollItem(roll, index);
            },
          );
  }
  
  Widget _buildEmptyRollsState() {
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
            'Roll the dice to start tracking',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRollItem(DiceRoll roll, int index) {
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roll: ${roll.diceOne} + ${roll.diceTwo} = ${roll.rollTotal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      const Spacer(),
                      Text(
                        timeFormat,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: outcomeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                '${roll.rollTotal}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: outcomeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsTab() {
    final diceRollProvider = Provider.of<DiceRollProvider>(context);
    final rolls = diceRollProvider.playerRolls;
    
    if (rolls.isEmpty) {
      return _buildEmptyRollsState();
    }
    
    // Get distributions
    final rollDistribution = diceRollProvider.getRollDistribution(rolls);
    final outcomeDistribution = diceRollProvider.getOutcomeDistribution(rolls);
    
    // Win/Loss stats
    final winCount = diceRollProvider.getWinCount(rolls);
    final lossCount = diceRollProvider.getLossCount(rolls);
    final winPercentage = diceRollProvider.getWinPercentage(rolls);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWinLossStats(winCount, lossCount, winPercentage),
          const SizedBox(height: 24),
          const Text(
            'Roll Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRollDistribution(rollDistribution, rolls.length),
          const SizedBox(height: 24),
          const Text(
            'Outcome Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildOutcomeDistribution(outcomeDistribution, rolls.length),
          const SizedBox(height: 24),
          _buildCrapsOddsExplanation(),
        ],
      ),
    );
  }
  
  Widget _buildWinLossStats(int winCount, int lossCount, double winPercentage) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Win/Loss Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Wins', '$winCount', Colors.green),
                _buildStatColumn('Losses', '$lossCount', Colors.red),
                _buildStatColumn(
                  'Win %', 
                  '${winPercentage.toStringAsFixed(1)}%', 
                  Colors.blue
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String label, String value, Color color) {
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
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRollDistribution(Map<int, int> distribution, int totalRolls) {
    return Column(
      children: List.generate(11, (index) {
        final total = index + 2; // Roll totals from 2 to 12
        final count = distribution[total] ?? 0;
        final percentage = totalRolls > 0 ? (count / totalRolls) * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: _getTotalColor(total),
                        minHeight: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      ' ${percentage.toStringAsFixed(1)}%',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 2),
                child: Text(
                  '$count rolls',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildOutcomeDistribution(Map<String, int> distribution, int totalRolls) {
    final outcomes = distribution.keys.toList();
    
    return Column(
      children: outcomes.map((outcome) {
        final count = distribution[outcome] ?? 0;
        final percentage = totalRolls > 0 ? (count / totalRolls) * 100 : 0;
        
        Color color;
        if (outcome.contains('Win')) {
          color = Colors.green;
        } else if (outcome.contains('Loss')) {
          color = Colors.red;
        } else {
          color = Colors.blue;
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      outcome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: color,
                        minHeight: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      ' ${percentage.toStringAsFixed(1)}%',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120, top: 2),
                child: Text(
                  '$count rolls',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCrapsOddsExplanation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Craps Odds Reference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Come Out Roll:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('• Win on 7 or 11 (Natural)'),
            const Text('• Lose on 2, 3, or 12 (Craps)'),
            const Text('• Any other number establishes the Point'),
            const SizedBox(height: 8),
            const Text(
              'Point Phase:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('• Win by rolling the Point again'),
            const Text('• Lose on 7 (Seven Out)'),
            const SizedBox(height: 16),
            const Text(
              'Probability of Rolling Each Number:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(
                  children: [
                    const TableCell(child: Text('Number')),
                    const TableCell(child: Text('Probability')),
                    TableCell(child: Text('Combinations', style: TextStyle(fontSize: 12))),
                  ],
                ),
                _buildOddsRow('2', '1/36 (2.78%)', '1,1'),
                _buildOddsRow('3', '2/36 (5.56%)', '1,2 2,1'),
                _buildOddsRow('4', '3/36 (8.33%)', '1,3 3,1 2,2'),
                _buildOddsRow('5', '4/36 (11.11%)', '1,4 4,1 2,3 3,2'),
                _buildOddsRow('6', '5/36 (13.89%)', '1,5 5,1 2,4 4,2 3,3'),
                _buildOddsRow('7', '6/36 (16.67%)', '1,6 6,1 2,5 5,2 3,4 4,3'),
                _buildOddsRow('8', '5/36 (13.89%)', '2,6 6,2 3,5 5,3 4,4'),
                _buildOddsRow('9', '4/36 (11.11%)', '3,6 6,3 4,5 5,4'),
                _buildOddsRow('10', '3/36 (8.33%)', '4,6 6,4 5,5'),
                _buildOddsRow('11', '2/36 (5.56%)', '5,6 6,5'),
                _buildOddsRow('12', '1/36 (2.78%)', '6,6'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  TableRow _buildOddsRow(String number, String odds, String combinations) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(odds),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(combinations, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ),
      ],
    );
  }
  
  Color _getTotalColor(int total) {
    switch (total) {
      case 7:
        return Colors.red;
      case 2:
      case 12:
        return Colors.purple;
      case 3:
      case 11:
        return Colors.blue;
      case 4:
      case 10:
        return Colors.green;
      case 5:
      case 9:
        return Colors.orange;
      case 6:
      case 8:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
