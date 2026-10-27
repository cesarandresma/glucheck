import '../../core/constants/measurement_contexts.dart';
import '../models/glucose_reading.dart';

/// Conjunto de 20 mediciones ficticias para demostración (no son datos clínicos reales).
class DemoGlucoseData {
  DemoGlucoseData._();

  static List<GlucoseReading> templates({required String placeholderUserId}) {
    final base = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final contexts = MeasurementContexts.all;
    final values = [
      98,
      112,
      105,
      128,
      118,
      95,
      132,
      140,
      122,
      108,
      101,
      115,
      125,
      119,
      134,
      110,
      103,
      127,
      116,
      109,
    ];

    return List.generate(20, (i) {
      final measured = base.add(Duration(days: i, hours: i % 5 * 2));
      final created = measured;
      return GlucoseReading(
        id: 'demo-template-$i',
        userId: placeholderUserId,
        valueMgDl: values[i].toDouble(),
        measuredAt: measured,
        context: contexts[i % contexts.length],
        notes: 'Registro de demostración — no usar con fines clínicos.',
        createdAt: created,
        updatedAt: created,
        source: GlucoseSource.manual,
        isDemo: true,
      );
    });
  }
}
