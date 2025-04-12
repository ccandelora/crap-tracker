import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/dice_roll.dart';

class StatsDashboard extends StatelessWidget {
  final Player player;
  final List<DiceRoll> rolls;
  final int winCount;
  final int lossCount;
  final double winPercentage;
  
  const StatsDashboard({
    super.key,
    required this.player,
    required this.rolls,
    required this.winCount,
    required this.lossCount,
    required this.winPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A237E), // Darker blue
            const Color(0xFF283593), // Deep indigo
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildStatsGrid(context),
            const SizedBox(height: 16),
            _buildWinLossBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white.withOpacity(0.25),
          child: Text(
            player.name.isNotEmpty ? player.name[0] : '?',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Stats Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Level ${(player.totalRolls / 100).ceil()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatItem(
          context,
          label: 'Total Rolls',
          value: '${player.totalRolls}',
          icon: Icons.casino,
          color: Colors.orange.shade300,
          backgroundColor: Colors.white.withOpacity(0.15),
        ),
        _buildStatItem(
          context,
          label: 'Games Played',
          value: '${player.totalGames}',
          icon: Icons.sports_esports,
          color: Colors.purple.shade200,
          backgroundColor: Colors.white.withOpacity(0.15),
        ),
        _buildStatItem(
          context,
          label: 'Sessions',
          value: '${player.totalSessions}',
          icon: Icons.date_range,
          color: Colors.lightBlue.shade200,
          backgroundColor: Colors.white.withOpacity(0.15),
        ),
        _buildStatItem(
          context,
          label: 'Avg Rolls/Session',
          value: player.avgRollsPerSession.toStringAsFixed(1),
          icon: Icons.analytics,
          color: Colors.green.shade300,
          backgroundColor: Colors.white.withOpacity(0.15),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
    Color? backgroundColor,
  }) {
    final textColor = color ?? Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinLossBar(BuildContext context) {
    final winWidth = winCount + lossCount > 0 
        ? (winCount / (winCount + lossCount)) * 100 
        : 50.0;
    
    // Get the available container width minus the padding
    final padding = 32.0; // 16px padding on each side
    final availableWidth = MediaQuery.of(context).size.width - padding;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Win/Loss Ratio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '${winPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (winCount > 0)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  child: Container(
                    width: (availableWidth * (winWidth / 100)).clamp(0, availableWidth),
                    height: 24,
                    color: Colors.green.shade300,
                    child: Center(
                      child: Text(
                        winCount.toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              if (lossCount > 0)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                        topLeft: winCount > 0 ? Radius.zero : const Radius.circular(12),
                        bottomLeft: winCount > 0 ? Radius.zero : const Radius.circular(12),
                      ),
                      color: Colors.red.shade300,
                    ),
                    height: 24,
                    child: Center(
                      child: Text(
                        lossCount.toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Wins',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Losses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
} 