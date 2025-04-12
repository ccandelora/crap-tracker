import 'package:flutter/material.dart';

class StrategyGuideScreen extends StatelessWidget {
  const StrategyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Craps Strategy Guide'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Basic Craps Strategy',
            content: _buildBasicStrategy(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Best Bets in Craps',
            content: _buildBestBets(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Betting Systems',
            content: _buildBettingSystems(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Tips for Longer Sessions',
            content: _buildSessionTips(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Interpretation of Your Stats',
            content: _buildStatsInterpretation(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicStrategy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTip(
          title: 'Pass Line Bet',
          content: 'The most basic bet in craps. Place this bet before the come-out roll. You win if the shooter rolls 7 or 11, and lose if they roll 2, 3, or 12. Any other number becomes the "point," and you win if the shooter hits that point before rolling a 7.',
          icon: Icons.check_circle_outline,
        ),
        _buildTip(
          title: 'Take Odds After Point is Established',
          content: 'Once a point is established, "take odds" on your Pass Line bet. This bet pays true odds and has zero house edge - one of the best bets in the casino!',
          icon: Icons.thumb_up_outlined,
        ),
        _buildTip(
          title: 'Manage Your Bankroll',
          content: 'Set a budget before you play and stick to it. Have a win goal and a loss limit.',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _buildTip(
          title: 'Understand the Probabilities',
          content: 'The most common roll is 7 (probability: 16.67%). The least common rolls are 2 and 12 (probability: 2.78% each). Use this knowledge to make smarter bets.',
          icon: Icons.analytics_outlined,
        ),
      ],
    );
  }

  Widget _buildBestBets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBetType(
          name: 'Pass Line with Odds',
          houseEdge: '1.41% (0% on odds portion)',
          recommendation: 'Excellent bet - a craps essential',
          isPrimaryRecommended: true,
        ),
        _buildBetType(
          name: 'Come Bet with Odds',
          houseEdge: '1.41% (0% on odds portion)',
          recommendation: 'Excellent bet - same as Pass Line but made after point established',
          isPrimaryRecommended: true,
        ),
        _buildBetType(
          name: "Don't Pass with Odds",
          houseEdge: '1.36% (0% on odds portion)',
          recommendation: 'Excellent bet - slightly better odds than Pass Line',
          isPrimaryRecommended: true,
        ),
        _buildBetType(
          name: 'Place 6 or 8',
          houseEdge: '1.52%',
          recommendation: 'Good bet - nearly as good as Pass/Come',
          isSecondaryRecommended: true,
        ),
        _buildBetType(
          name: 'Place 5 or 9',
          houseEdge: '4.0%',
          recommendation: 'Decent bet',
          isSecondaryRecommended: true,
        ),
        _buildBetType(
          name: 'Any Craps',
          houseEdge: '11.1%',
          recommendation: 'Poor odds - avoid',
          isNotRecommended: true,
        ),
        _buildBetType(
          name: 'Hardways',
          houseEdge: '9.1% to 11.1%',
          recommendation: 'High house edge - not recommended',
          isNotRecommended: true,
        ),
        _buildBetType(
          name: 'Big 6 or 8',
          houseEdge: '9.1%',
          recommendation: 'One of the worst bets - definitely avoid',
          isNotRecommended: true,
        ),
      ],
    );
  }

  Widget _buildBettingSystems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTip(
          title: 'The 3-Point Molly',
          content: 'A popular system where you make a Pass Line bet with odds, followed by two Come bets with odds. This gives you three points working for you at once.',
          icon: Icons.insights,
        ),
        _buildTip(
          title: 'Iron Cross',
          content: 'Place bets on 5, 6, and 8, plus a Field bet. You win on everything except 7. High risk but popular.',
          icon: Icons.warning_amber,
        ),
        _buildTip(
          title: 'Regression Strategy',
          content: 'After winning on a place bet, reduce your bet size ("regress") to lock in profit and reduce risk.',
          icon: Icons.trending_down,
        ),
        _buildTip(
          title: 'Conservative Approach',
          content: 'Stick to Pass Line with full odds and a couple of Come bets with odds. The mathematically best approach for longevity.',
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }

  Widget _buildSessionTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTip(
          title: '5-Count Method',
          content: "Wait for the shooter to make 5 rolls before placing any bets beyond the Pass Line. This helps you avoid cold shooters.",
          icon: Icons.filter_5,
        ),
        _buildTip(
          title: 'Take Breaks',
          content: "Step away from the table periodically to clear your head and reassess your bankroll.",
          icon: Icons.pause,
        ),
        _buildTip(
          title: 'Press Your Bets Strategically',
          content: "After multiple wins, consider \"pressing\" (increasing) your bet with house money while keeping your original stake safe.",
          icon: Icons.trending_up,
        ),
        _buildTip(
          title: 'Stick to Your Budget',
          content: "Predetermined limits help maintain discipline during both winning and losing streaks.",
          icon: Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildStatsInterpretation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTip(
          title: 'Win/Loss Ratio',
          content: "In craps, a mathematical win rate around 49.3% is expected when playing the Pass Line. If your tracked stats show significantly worse results over many sessions, consider reviewing your betting strategy.",
          icon: Icons.show_chart,
        ),
        _buildTip(
          title: 'Monitoring Point Numbers',
          content: "If your app shows you hit certain point numbers (4, 5, 6, 8, 9, 10) more frequently before sevening out, these might be worthwhile place bets for your style of play.",
          icon: Icons.stacked_line_chart,
        ),
        _buildTip(
          title: 'Session Length Analysis',
          content: "If your average session is shorter than expected (under 30 rolls), you may be experiencing unfavorable variance. Don't be discouraged—this is normal.",
          icon: Icons.timer,
        ),
        _buildTip(
          title: 'Roll Distribution',
          content: "Check if your roll distribution matches expected probabilities over time. Significant deviations over large sample sizes might indicate biased dice (rare in regulated environments).",
          icon: Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _buildTip({required String title, required String content, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetType({
    required String name,
    required String houseEdge,
    required String recommendation,
    bool isPrimaryRecommended = false,
    bool isSecondaryRecommended = false,
    bool isNotRecommended = false,
  }) {
    Color statusColor = Colors.grey;
    if (isPrimaryRecommended) {
      statusColor = Colors.green;
    } else if (isSecondaryRecommended) {
      statusColor = Colors.blue;
    } else if (isNotRecommended) {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrimaryRecommended
                    ? Icons.recommend
                    : isSecondaryRecommended
                        ? Icons.thumb_up
                        : Icons.thumb_down,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'House Edge: $houseEdge',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(recommendation),
        ],
      ),
    );
  }
} 