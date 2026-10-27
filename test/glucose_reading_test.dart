import 'package:flutter_test/flutter_test.dart';
import 'package:glucotrack/core/constants/measurement_contexts.dart';
import 'package:glucotrack/data/models/glucose_reading.dart';

void main() {
  test('GlucoseReading serializa y deserializa', () {
    final now = DateTime.utc(2025, 1, 15, 10, 30);
    final reading = GlucoseReading(
      id: 'abc',
      userId: 'user1',
      valueMgDl: 110,
      measuredAt: now,
      context: MeasurementContexts.fasting,
      notes: 'nota',
      createdAt: now,
      updatedAt: now,
      isDemo: true,
    );
    final map = reading.toMap();
    final restored = GlucoseReading.fromMap('abc', map);
    expect(restored.valueMgDl, 110);
    expect(restored.isDemo, true);
    expect(restored.context, MeasurementContexts.fasting);

    final local = GlucoseReading.fromLocalJson(reading.toLocalJson());
    expect(local.id, 'abc');
  });
}
