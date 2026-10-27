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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseReady = kFirebaseConfigured || !isFirebaseOptionsPlaceholder;
  if (firebaseReady && !kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  }

  runApp(const GlucoTrackApp());
}
