import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_loading_view.dart';
import '../settings/settings_view.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.profile.value == null) {
        return const AppLoadingView();
      }
      final p = controller.profile.value;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p != null) ...[
            ListTile(
              title: const Text('Nombre'),
              subtitle: Text(p.displayName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editName(context, p.displayName),
              ),
            ),
            ListTile(title: const Text('Correo'), subtitle: Text(p.email)),
          ],
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferencias y datos'),
            onTap: () => Get.to(() => const SettingsView()),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacidad'),
            onTap: () => Get.toNamed(AppRoutes.privacy),
          ),
          const SizedBox(height: 16),
          Text(AppConstants.privacySummary),
        ],
      );
    });
  }

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    await Get.dialog(
      AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.updateName(ctrl.text);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
