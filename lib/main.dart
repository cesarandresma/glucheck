import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/providers/local/local_storage_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await GlucoTrackApp.prepare();

  final local = LocalStorageProvider();
  await local.init();

  try {
    if (Firebase.apps.isEmpty) {
      if (!isFirebaseOptionsPlaceholder || kFirebaseConfigured) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        // Usa los valores que el plugin de Google Services genera desde
        // android/app/google-services.json, sin copiar la clave al código.
        await Firebase.initializeApp();
      }
    }
  } catch (_) {
    debugPrint('No se pudo iniciar Firebase.');
  }

  if (Firebase.apps.isNotEmpty && !kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
      );
    } catch (_) {
      debugPrint('App Check no se activó.');
    }
  }

  runApp(const GlucoTrackApp());
}
