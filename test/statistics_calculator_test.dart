import 'package:flutter_test/flutter_test.dart';
import 'package:glucotrack/core/constants/measurement_contexts.dart';
import 'package:glucotrack/core/utils/statistics_calculator.dart';
import 'package:glucotrack/data/models/glucose_reading.dart';

GlucoseReading _r(double v) {
  final t = DateTime.utc(2025, 1, 1);
  return GlucoseReading(
    id: v.toString(),
    userId: 'u',
    valueMgDl: v,
    measuredAt: t,
    context: MeasurementContexts.fasting,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  test('calcula estadísticas descriptivas', () {
    final stats = GlucoseStatistics.fromReadings([_r(100), _r(120), _r(110)]);
    expect(stats!.count, 3);
    expect(stats.average, 110);
    expect(stats.minimum, 100);
    expect(stats.maximum, 120);
  });

  test('compara periodos solo con datos suficientes', () {
    final current = GlucoseStatistics.fromReadings([_r(100), _r(120)]);
    final previous = GlucoseStatistics.fromReadings([_r(80), _r(100)]);
    final comparison = PeriodComparison.compare(current, previous);
    expect(comparison!.previousAverage, 90);
    expect(comparison.difference, 20);

    final sparse = GlucoseStatistics.fromReadings([_r(90)]);
    expect(PeriodComparison.compare(current, sparse), isNull);
  });
}
