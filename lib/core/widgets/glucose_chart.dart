import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/glucose_reading.dart';

class GlucoseChart extends StatelessWidget {
  const GlucoseChart({super.key, required this.readings, this.compact = false});

  final List<GlucoseReading> readings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const SizedBox.shrink();
    }
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final spots = sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valueMgDl))
        .toList();
    final minY =
        (sorted.map((r) => r.valueMgDl).reduce((a, b) => a < b ? a : b) - 10)
            .clamp(0, double.infinity);
    final maxY =
        sorted.map((r) => r.valueMgDl).reduce((a, b) => a > b ? a : b) + 10;

    return SizedBox(
      height: compact ? 160 : 220,
      child: LineChart(
        LineChartData(
          minY: minY.toDouble(),
          maxY: maxY,
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !compact,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${sorted[i].measuredAt.day}/${sorted[i].measuredAt.month}',
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: spots.length <= 12),
            ),
          ],
        ),
      ),
    );
  }
}
