import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(AppConstants.privacySummary),
            const SizedBox(height: 16),
            const Text(
              'Los datos de salud se tratan con prudencia. La aplicación no comparte '
              'su historial con otros usuarios. El asistente envía solo la pregunta '
              'y un token de sesión al servidor propio; el servidor consulta sus '
              'registros autorizados en Firestore.',
            ),
            const SizedBox(height: 16),
            Text(AppConstants.assistantDisclaimer),
          ],
        ),
      ),
    );
  }
}
