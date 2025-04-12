import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/dice_roll.dart';
import '../utils/analytics_util.dart';

class StrategyRecommendations extends StatelessWidget {
  final Player player;
  final List<DiceRoll> rolls;
  
  const StrategyRecommendations({
    super.key,
    required this.player,
    required this.rolls,
  });
  
  @override
  Widget build(BuildContext context) {
    final recommendations = AnalyticsUtil.generateStrategyRecommendations(player, rolls);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Strategy Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recommendations.isEmpty
            ? _buildNoRecommendations()
            : _buildRecommendationsList(recommendations),
        const SizedBox(height: 16),
        _buildDisclaimerText(),
      ],
    );
  }
  
  Widget _buildNoRecommendations() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Keep playing to generate personalized recommendations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecommendationsList(List<String> recommendations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getRecommendationColor(index).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRecommendationColor(index),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendations[index],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDisclaimerText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Disclaimer: These recommendations are based on your historical data and statistical analysis. Dice rolls are random events and past results do not guarantee future outcomes.',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Color _getRecommendationColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    return colors[index % colors.length];
  }
} 