// Ejecute `dart pub global activate flutterfire_cli` y luego
// `flutterfire configure` para reemplazar estos valores de marcador de posición.
//
// Las claves de API web de Firebase son identificadores públicos del proyecto;
// la seguridad real depende de Authentication y Firestore Security Rules.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// `true` si flutterfire reemplazó los marcadores o si se fuerza con --dart-define.
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
    apiKey: 'AIzaSyDDYaO3nqYCd7WVwmZpcTtO7vrYFhmDJmQ',
    appId: '1:475542608918:android:72442d56a663af1beb6937',
    messagingSenderId: '475542608918',
    projectId: 'glucocheck-46e15',
    storageBucket: 'glucocheck-46e15.firebasestorage.app',
  );
}
