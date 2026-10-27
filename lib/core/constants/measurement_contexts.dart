/// Contextos de medición admitidos (etiquetas en español).
class MeasurementContexts {
  MeasurementContexts._();

  static const fasting = 'en_ayunas';
  static const beforeMeal = 'antes_comer';
  static const afterMeal = 'despues_comer';
  static const beforeSleep = 'antes_dormir';
  static const other = 'otro';

  static const all = [fasting, beforeMeal, afterMeal, beforeSleep, other];

  static String label(String key) {
    switch (key) {
      case fasting:
        return 'En ayunas';
      case beforeMeal:
        return 'Antes de comer';
      case afterMeal:
        return 'Después de comer';
      case beforeSleep:
        return 'Antes de dormir';
      case other:
        return 'Otro';
      default:
        return key;
    }
  }
}
