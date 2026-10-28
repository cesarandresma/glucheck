// Copie este archivo a lib/firebase_options.dart en su máquina.
// No ponga claves reales en este ejemplo ni lo suba con valores del proyecto.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// `true` si se fuerza con --dart-define=FIREBASE_CONFIGURED=true.
const bool kFirebaseConfigured = bool.fromEnvironment(
  'FIREBASE_CONFIGURED',
  defaultValue: false,
);

bool get isFirebaseOptionsPlaceholder =>
    DefaultFirebaseOptions.android.apiKey.startsWith('REPLACE');

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('GlucoTrack Android es el objetivo principal.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('Configure iOS con flutterfire configure.');
      default:
        throw UnsupportedError('Plataforma no soportada para Firebase.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE',
    appId: 'REPLACE_WITH_FLUTTERFIRE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE.appspot.com',
  );
}
