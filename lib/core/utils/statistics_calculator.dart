import '../../data/models/glucose_reading.dart';

class GlucoseStatistics {
  const GlucoseStatistics({
    required this.count,
    required this.average,
    required this.minimum,
    required this.maximum,
  });

  final int count;
  final double average;
  final double minimum;
  final double maximum;

  static GlucoseStatistics? fromReadings(List<GlucoseReading> readings) {
    if (readings.isEmpty) return null;
    final values = readings.map((r) => r.valueMgDl).toList();
    final sum = values.reduce((a, b) => a + b);
    return GlucoseStatistics(
      count: values.length,
      average: sum / values.length,
      minimum: values.reduce((a, b) => a < b ? a : b),
      maximum: values.reduce((a, b) => a > b ? a : b),
    );
  }
}

class PeriodComparison {
  const PeriodComparison({
    required this.currentAverage,
    required this.previousAverage,
    required this.difference,
  });

  final double currentAverage;
  final double previousAverage;
  final double difference;

  /// Solo si ambos periodos tienen al menos dos registros.
  static PeriodComparison? compare(
    GlucoseStatistics? current,
    GlucoseStatistics? previous,
  ) {
    if (current == null || previous == null) return null;
    if (current.count < 2 || previous.count < 2) return null;
    return PeriodComparison(
      currentAverage: current.average,
      previousAverage: previous.average,
      difference: current.average - previous.average,
    );
  }
}

class StatisticsCalculator {
  StatisticsCalculator._();

  static List<GlucoseReading> filterByDateRange(
    List<GlucoseReading> readings,
    DateTime? from,
    DateTime? to,
  ) {
    return readings.where((r) {
      final t = r.measuredAt.toLocal();
      if (from != null && t.isBefore(from)) return false;
      if (to != null && t.isAfter(to)) return false;
      return true;
    }).toList();
  }

  static List<GlucoseReading> filterByContext(
    List<GlucoseReading> readings,
    String? context,
  ) {
    if (context == null || context.isEmpty) return readings;
    return readings.where((r) => r.context == context).toList();
  }
}
