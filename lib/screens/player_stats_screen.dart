import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crap_tracker/models/player.dart';
import 'package:crap_tracker/models/session.dart';
import 'package:crap_tracker/providers/dice_roll_provider.dart';
import 'package:crap_tracker/providers/session_provider.dart';
import 'package:crap_tracker/utils/probability_calculator.dart';
import 'package:crap_tracker/widgets/probability_chart_widget.dart';
import 'package:crap_tracker/widgets/session_card_widget.dart';
import 'package:intl/intl.dart';

class PlayerStatsScreen extends StatefulWidget {
  final Player player;

  const PlayerStatsScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final diceRollProvider = Provider.of<DiceRollProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    await diceRollProvider.loadRollsByPlayer(widget.player.id);
    await sessionProvider.loadSessionsByPlayer(widget.player.id);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.player.name}\'s Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'DATASETS'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSessionsTab(),
              ],
            ),
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayerSummary(),
          const SizedBox(height: 24),
          _buildRollDistribution(),
          const SizedBox(height: 24),
          _buildProbabilityChart(),
        ],
      ),
    );
  }
  
  Widget _buildPlayerSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    widget.player.name.isNotEmpty
                        ? widget.player.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.player.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.player.totalRolls} total rolls',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatCard(
                  'Total Sessions',
                  widget.player.totalSessions.toString(),
                  Icons.calendar_today,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Avg. Rolls/Session',
                  widget.player.avgRollsPerSession > 0
                      ? NumberFormat('##.0').format(widget.player.avgRollsPerSession)
                      : '0',
                  Icons.casino,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRollDistribution() {
    return Consumer<DiceRollProvider>(
      builder: (context, diceRollProvider, child) {
        final distribution = diceRollProvider.getRollDistribution();
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProbabilityChartWidget(
                  probabilities: distribution,
                  title: '',
                  barColor: Colors.amber,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProbabilityChart() {
    return Consumer<DiceRollProvider>(
      builder: (context, diceRollProvider, child) {
        // Get historical roll totals
        final rollTotals = diceRollProvider.getRollTotals();
        
        // Calculate probabilities based on historical data
        final probabilities = ProbabilityCalculator.getAllProbabilities(rollTotals);
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistical Probability Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProbabilityChartWidget(
                  probabilities: probabilities,
                  title: '',
                  barColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSessionsTab() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        final sessions = sessionProvider.sessions;
        
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Sessions Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sessions will appear here once you start rolling',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        // Sort sessions by start time, most recent first
        final sortedSessions = [...sessions];
        sortedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        
        return ListView.builder(
          itemCount: sortedSessions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final session = sortedSessions[index];
            return SessionCardWidget(
              session: session,
              playerName: widget.player.name,
              onTap: () => _showSessionDetails(session),
            );
          },
        );
      },
    );
  }
  
  void _showSessionDetails(Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session Details',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildSessionDetailRow(
                  'Player',
                  widget.player.name,
                  Icons.person,
                ),
                const SizedBox(height: 16),
                _buildSessionDetailRow(
                  'Start Time',
                  DateFormat('MMM d, yyyy - h:mm a').format(session.startTime),
                  Icons.schedule,
                ),
                const SizedBox(height: 16),
                _buildSessionDetailRow(
                  'End Time',
                  session.endTime != null
                      ? DateFormat('MMM d, yyyy - h:mm a').format(session.endTime!)
                      : 'Active',
                  Icons.timer_off,
                ),
                const SizedBox(height: 16),
                _buildSessionDetailRow(
                  'Total Rolls',
                  session.totalRolls.toString(),
                  Icons.casino,
                ),
                const SizedBox(height: 16),
                _buildSessionDetailRow(
                  'Duration',
                  _formatDuration(session.durationInSeconds),
                  Icons.timelapse,
                ),
                const SizedBox(height: 16),
                _buildSessionDetailRow(
                  'Status',
                  session.isActive ? 'Active' : 'Completed',
                  session.isActive ? Icons.play_circle : Icons.check_circle,
                  color: session.isActive ? Colors.green : Colors.blue,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Sessions automatically end when a 7 is rolled ("Seven Out")',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSessionDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? Colors.grey.shade700,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      final result = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      if (remainingSeconds > 0) {
        return '$result, $remainingSeconds ${remainingSeconds == 1 ? 'second' : 'seconds'}';
      }
      return result;
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    final result = '$hours ${hours == 1 ? 'hour' : 'hours'}';
    if (remainingMinutes > 0) {
      return '$result, $remainingMinutes ${remainingMinutes == 1 ? 'minute' : 'minutes'}';
    }
    return result;
  }
} 