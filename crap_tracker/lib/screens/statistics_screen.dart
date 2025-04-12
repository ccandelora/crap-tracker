import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dice_roll.dart';
import '../models/session.dart';
import '../models/player.dart';
import '../services/statistics_service.dart';
import '../services/database_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Craps Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Rolls'),
              Tab(text: 'Players'),
              Tab(text: 'Strategies'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(),
            RollsTab(),
            PlayersTab(),
            StrategiesTab(),
          ],
        ),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder<List<DiceRoll>>(
      future: databaseService.getAllDiceRolls(),
      builder: (context, rollsSnapshot) {
        if (!rollsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final rolls = rollsSnapshot.data!;
        if (rolls.isEmpty) {
          return const Center(child: Text('No roll data available yet'));
        }
        
        final Map<int, int> distribution = StatisticsService.getRollDistribution(rolls);
        final Map<String, double> winRateStats = StatisticsService.calculateWinRateStats(rolls);
        final srr = StatisticsService.calculateSRR(rolls);
        final avgRollsBetweenSevens = StatisticsService.calculateAverageRollsBetweenSevens(rolls);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overall Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Rolls: ${rolls.length}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Seven to Rolls Ratio (SRR): ${srr.toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Avg. Rolls Between Sevens: ${avgRollsBetweenSevens.toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Overall Win Rate: ${(winRateStats['winRate']! * 100).toStringAsFixed(2)}%', 
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Roll Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 250,
                child: RollDistributionChart(distribution: distribution),
              ),
              
              const SizedBox(height: 24),
              const Text('Win Rate Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Come-out Win Rate: ${(winRateStats['comeOutWinRate']! * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Point Numbers Win Rate: ${(winRateStats['pointsWinRate']! * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RollDistributionChart extends StatelessWidget {
  final Map<int, int> distribution;
  
  const RollDistributionChart({Key? key, required this.distribution}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: distribution.values.isEmpty ? 10 : distribution.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = group.x.toInt() + 2; // x starts at 0, dice start at 2
              return BarTooltipItem(
                '$value: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt() + 2}',
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: distribution.values.isEmpty ? 2 : 
                      distribution.values.reduce((a, b) => a > b ? a : b) / 5,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(11, (index) {
          final rollValue = index + 2; // Dice values start at 2
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: distribution[rollValue]?.toDouble() ?? 0,
                color: rollValue == 7 ? Colors.red : 
                      [4, 5, 6, 8, 9, 10].contains(rollValue) ? Colors.blue : Colors.grey,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class RollsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder<List<DiceRoll>>(
      future: databaseService.getAllDiceRolls(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final rolls = snapshot.data!;
        if (rolls.isEmpty) {
          return const Center(child: Text('No roll data available yet'));
        }
        
        final boxNumberHits = StatisticsService.getBoxNumberHits(rolls);
        final hotAndColdNumbers = StatisticsService.getHotAndColdNumbers(rolls);
        final rollStats = StatisticsService.calculateRollStatistics(rolls);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Box Numbers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 250,
                child: BoxNumbersChart(boxNumberHits: boxNumberHits),
              ),
              
              const SizedBox(height: 24),
              const Text('Hot & Cold Numbers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hot Numbers', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(hotAndColdNumbers['hot']!.isEmpty ? 
                                'None' : hotAndColdNumbers['hot']!.join(', ')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cold Numbers', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(hotAndColdNumbers['cold']!.isEmpty ? 
                                'None' : hotAndColdNumbers['cold']!.join(', ')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Statistical Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mean: ${rollStats['mean']!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Median: ${rollStats['median']!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Standard Deviation: ${rollStats['stdDev']!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Variance: ${rollStats['variance']!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BoxNumbersChart extends StatelessWidget {
  final Map<int, int> boxNumberHits;
  
  const BoxNumbersChart({Key? key, required this.boxNumberHits}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: boxNumberHits.values.isEmpty ? 10 : boxNumberHits.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final boxNumbers = [4, 5, 6, 8, 9, 10];
              final value = boxNumbers[group.x.toInt()];
              return BarTooltipItem(
                '$value: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final boxNumbers = [4, 5, 6, 8, 9, 10];
                return Text(
                  '${boxNumbers[value.toInt()]}',
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: boxNumberHits.values.isEmpty ? 2 : 
                      boxNumberHits.values.reduce((a, b) => a > b ? a : b) / 5,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [4, 5, 6, 8, 9, 10].asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: boxNumberHits[value]?.toDouble() ?? 0,
                color: Colors.blue,
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class PlayersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder<List<Player>>(
      future: databaseService.getAllPlayers(),
      builder: (context, playersSnapshot) {
        if (!playersSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final players = playersSnapshot.data!;
        if (players.isEmpty) {
          return const Center(child: Text('No player data available yet'));
        }
        
        return FutureBuilder<List<Session>>(
          future: databaseService.getAllSessions(),
          builder: (context, sessionsSnapshot) {
            if (!sessionsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final sessions = sessionsSnapshot.data!;
            
            return FutureBuilder<List<DiceRoll>>(
              future: databaseService.getAllDiceRolls(),
              builder: (context, rollsSnapshot) {
                if (!rollsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final rolls = rollsSnapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final metrics = StatisticsService.getPlayerPerformanceMetrics(
                      player, sessions, rolls
                    );
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Win Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('${(metrics['overallWinRate'] * 100).toStringAsFixed(2)}%'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Avg Streak Length', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('${metrics['avgStreakLength'].toStringAsFixed(2)} rolls'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Best Point Number', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(metrics['bestPoint'] != null ? 
                                '${metrics['bestPoint']} (${(metrics['bestPointSuccessRate'] * 100).toStringAsFixed(2)}% success)' : 
                                'No point data available'),
                            const SizedBox(height: 16),
                            ExpansionTile(
                              title: const Text('Point Numbers Performance'),
                              children: [
                                for (final entry in (metrics['pointsPerformance'] as Map<int, Map<String, int>>).entries)
                                  if ((entry.value['made'] ?? 0) + (entry.value['lost'] ?? 0) > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Made ${entry.value['made'] ?? 0} times, Lost ${entry.value['lost'] ?? 0} times ' +
                                              '(${((entry.value['made'] ?? 0) / ((entry.value['made'] ?? 0) + (entry.value['lost'] ?? 0)) * 100).toStringAsFixed(2)}% success)',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class StrategiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return FutureBuilder<List<DiceRoll>>(
      future: databaseService.getAllDiceRolls(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final rolls = snapshot.data!;
        if (rolls.isEmpty) {
          return const Center(child: Text('No roll data available yet'));
        }
        
        final Map<String, double> strategyResults = StatisticsService.evaluateBettingStrategies(rolls);
        final List<MapEntry<String, double>> sortedResults = strategyResults.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Betting Strategy Evaluation', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Simulated results based on \$100 starting bankroll and \$5 unit size',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      for (final entry in sortedResults)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  _formatStrategyName(entry.key),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: LinearProgressIndicator(
                                    value: _normalizeValue(entry.value, strategyResults.values.reduce((a, b) => a.abs() > b.abs() ? a : b).abs()),
                                    backgroundColor: Colors.grey[200],
                                    color: entry.value >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: entry.value >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Strategy Explanations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildStrategyCard(
                'Pass Line',
                'Place a bet before the come-out roll. Win on 7 or 11, lose on 2, 3, or 12. '
                'If any other number is rolled, it becomes the "point". '
                'Win if the point is rolled again before a 7.',
              ),
              
              _buildStrategyCard(
                'Don\'t Pass',
                'The opposite of Pass Line. Win on 2 or 3, lose on 7 or 11, push on 12. '
                'If a point is established, win if 7 is rolled before the point.',
              ),
              
              _buildStrategyCard(
                'Come',
                'Similar to Pass Line but placed after a point is established. '
                'Win on 7 or 11, lose on 2, 3, or 12. '
                'Any other number becomes your "Come point". Win if your Come point is rolled before a 7.',
              ),
              
              _buildStrategyCard(
                'Don\'t Come',
                'The opposite of Come. Win on 2 or 3, lose on 7 or 11, push on 12. '
                'If a Come point is established, win if 7 is rolled before your Come point.',
              ),
              
              _buildStrategyCard(
                'Place',
                'A bet that a specific number (4, 5, 6, 8, 9, or 10) will be rolled before a 7. '
                'This simulation places on 6 and 8, which offer the best odds.',
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatStrategyName(String strategy) {
    switch (strategy) {
      case 'passLine':
        return 'Pass Line';
      case 'dontPass':
        return 'Don\'t Pass';
      case 'come':
        return 'Come';
      case 'dontCome':
        return 'Don\'t Come';
      case 'place':
        return 'Place 6 & 8';
      default:
        return strategy;
    }
  }
  
  double _normalizeValue(double value, double maxAbsValue) {
    // Convert to a scale of 0 to 1, with 0.5 being neutral
    return (value / maxAbsValue * 0.5) + 0.5;
  }
  
  Widget _buildStrategyCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
} 