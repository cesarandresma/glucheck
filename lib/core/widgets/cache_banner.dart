import 'package:flutter/material.dart';

class CacheBanner extends StatelessWidget {
  const CacheBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text(
        'Mostrando datos guardados en este dispositivo (sin conexión reciente).',
      ),
      leading: const Icon(Icons.offline_bolt),
      actions: [
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}
