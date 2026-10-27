class AppConstants {
  AppConstants._();

  static const appName = 'GlucoTrack';

  /// Rango amplio de entrada; valores atípicos muestran advertencia, no se descartan.
  static const glucoseMinMgDl = 20.0;
  static const glucoseMaxMgDl = 600.0;
  static const glucoseTypicalLowMgDl = 70.0;
  static const glucoseTypicalHighMgDl = 180.0;

  static const defaultPageSize = 50;
  static const notesMaxLength = 500;
  static const displayNameMaxLength = 80;

  static const assistantDisclaimer =
      'GlucoTrack es una herramienta educativa de registro. '
      'No sustituye el consejo médico. Ante síntomas urgentes, acuda a servicios de salud.';

  static const privacySummary =
      'Sus mediciones y perfil se almacenan en Cloud Firestore asociados a su cuenta. '
      'Una copia reciente del historial puede guardarse localmente en este dispositivo '
      'y se elimina al cerrar sesión. Las contraseñas las gestiona Firebase Authentication.';
}
