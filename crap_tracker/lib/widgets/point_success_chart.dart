import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/analytics_util.dart';

class PointSuccessChart extends StatelessWidget {
  final Map<int, double> successRates;
  final bool showTheoretical;
  
  const PointSuccessChart({
    super.key,
    required this.successRates,
    this.showTheoretical = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theoreticalRates = AnalyticsUtil.getTheoreticalPointProbabilities();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Point Success Rates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 230,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      int point = _getPointFromIndex(groupIndex);
                      return BarTooltipItem(
                        '$point: ${rod.toY.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                        int point = _getPointFromIndex(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '$point',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: value % 20 == 0 ? null : [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Colors.transparent,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.8),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.grey.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                ),
                barGroups: _buildBarGroups(context, successRates, theoreticalRates),
              ),
            ),
          ),
        ),
        if (showTheoretical) _buildLegend(context),
      ],
    );
  }
  
  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Your Success Rate'),
          const SizedBox(width: 16),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Theoretical Probability'),
        ],
      ),
    );
  }
  
  List<BarChartGroupData> _buildBarGroups(
    BuildContext context,
    Map<int, double> successRates,
    Map<int, double> theoreticalRates,
  ) {
    final points = [4, 5, 6, 8, 9, 10];
    
    return List.generate(points.length, (index) {
      final point = points[index];
      final successRate = successRates[point] ?? 0.0;
      final theoreticalRate = theoreticalRates[point] ?? 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: successRate,
            color: Theme.of(context).colorScheme.primary,
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          if (showTheoretical)
            BarChartRodData(
              toY: theoreticalRate,
              color: Colors.orange.withOpacity(0.7),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
        ],
      );
    });
  }
  
  int _getPointFromIndex(int index) {
    final points = [4, 5, 6, 8, 9, 10];
    if (index >= 0 && index < points.length) {
      return points[index];
    }
    return 0;
  }
} 