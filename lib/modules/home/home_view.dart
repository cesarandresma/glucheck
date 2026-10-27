import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../assistant/assistant_view.dart';
import '../settings/settings_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../history/history_view.dart';
import '../profile/profile_view.dart';
import '../statistics/statistics_view.dart';

class HomeController extends GetxController {
  final index = 0.obs;
  void setTab(int i) => index.value = i;
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _tabs = [
    (icon: Icons.dashboard_outlined, label: 'Inicio'),
    (icon: Icons.history, label: 'Historial'),
    (icon: Icons.bar_chart, label: 'Estadísticas'),
    (icon: Icons.smart_toy_outlined, label: 'Asistente'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardView(),
      HistoryView(),
      StatisticsView(),
      AssistantView(),
      ProfileView(),
    ];

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('GlucoTrack'),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: IndexedStack(index: controller.index.value, children: pages),
        floatingActionButton: controller.index.value == 0
            ? FloatingActionButton(
                onPressed: () => Get.toNamed(AppRoutes.addGlucose),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.index.value,
          onDestinationSelected: controller.setTab,
          destinations: _tabs
              .map(
                (t) =>
                    NavigationDestination(icon: Icon(t.icon), label: t.label),
              )
              .toList(),
        ),
      );
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            'Se cerrará la sesión en este dispositivo para que otra persona pueda iniciar con su cuenta.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await Get.find<SettingsController>().logout();
  }
}
