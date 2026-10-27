import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/providers/local/local_storage_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _StartupGate());
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    try {
      await GlucoTrackApp.prepare();
      await LocalStorageProvider().init();
      await _initFirebase().timeout(const Duration(seconds: 15));
      _activateAppCheckLater();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo abrir GlucoTrack. Cierre la app por completo y vuelva a ejecutarla.';
      });
    }
  }

  Future<void> _initFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // La clave queda en android/app/google-services.json (ignorado por Git).
      // El plugin de Google Services la incluye en la compilación local.
      await Firebase.initializeApp();
      return;
    }
    if (isFirebaseOptionsPlaceholder && !kFirebaseConfigured) {
      throw StateError('Firebase sin configurar');
    }
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  void _activateAppCheckLater() {
    if (kIsWeb || Firebase.apps.isEmpty) return;
    unawaited(() async {
      try {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
        );
      } catch (_) {
        debugPrint('App Check no se activó.');
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const GlucoTrackApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F9FC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _error == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GlucoTrack',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(),
                    ],
                  )
                : Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
