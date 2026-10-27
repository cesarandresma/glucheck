import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsController get controller => Get.find<SettingsController>();
  late final TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    final uid = controller.userId ?? '';
    _urlCtrl = TextEditingController(text: controller.assistantUrl(uid));
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final password = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta acción elimina su cuenta y los datos asociados. '
                'No se puede deshacer.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    final value = password.text;
    password.dispose();
    if (confirmed == true) {
      await controller.deleteAccount(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = controller.userId ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GetBuilder<SettingsController>(
            builder: (settings) => SwitchListTile(
              title: const Text('Gráficos compactos'),
              value: settings.compactCharts(uid),
              onChanged: settings.setCompactCharts,
            ),
          ),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'URL base del servidor del asistente',
              hintText: 'http://10.0.2.2:8000',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => controller.saveAssistantUrl(_urlCtrl.text),
            child: const Text('Guardar URL'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Cargar datos de demostración'),
            subtitle: const Text('20 registros ficticios marcados como demo'),
            onTap: controller.importDemoData,
          ),
          Obx(() {
            if (controller.message.value != null) {
              return Text(controller.message.value!);
            }
            return const SizedBox.shrink();
          }),
          const Divider(),
          ListTile(
            title: const Text('Eliminar cuenta y datos'),
            subtitle: const Text(
              'Borra sus mediciones, el perfil y el usuario de Authentication. '
              'Debe confirmar con su contraseña. Si la sesión es antigua, '
              'Firebase puede pedir volver a autenticarse.',
            ),
            onTap: () => _confirmDelete(context),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: controller.logout,
            child: const Text('Cerrar sesión'),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.privacy),
            child: const Text('Información de privacidad'),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.assistantDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
