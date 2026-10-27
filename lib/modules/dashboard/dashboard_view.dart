import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/measurement_contexts.dart';
import '../../core/utils/date_utils_app.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading_view.dart';
import '../../core/widgets/glucose_chart.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: Obx(() {
        switch (controller.state.value) {
          case LoadState.loading:
            return ListView(
              children: const [SizedBox(height: 200, child: AppLoadingView())],
            );
          case LoadState.error:
            return ListView(
              children: [
                AppErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.load,
                ),
              ],
            );
          case LoadState.empty:
            return ListView(
              children: [
                AppEmptyView(
                  title: 'Aún no hay mediciones',
                  subtitle:
                      'Registre su primera medición para ver el resumen aquí.',
                  actionLabel: 'Registrar glucosa',
                  onAction: () => Get.toNamed(
                    AppRoutes.addGlucose,
                  )?.then((_) => controller.load()),
                ),
              ],
            );
          case LoadState.success:
            final latest = controller.latest!;
            final name = controller.profile.value?.displayName ?? 'Usuario';
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.fromCache.value)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.offline_bolt),
                      title: Text('Datos desde caché local'),
                    ),
                  ),
                Text(
                  'Hola, $name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última medición',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${latest.valueMgDl.toStringAsFixed(0)} mg/dL',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          DateUtilsApp.formatDateTime(
                            latest.measuredAt.toLocal(),
                          ),
                        ),
                        Text(MeasurementContexts.label(latest.context)),
                        if (latest.isDemo)
                          const Chip(label: Text('Demostración')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evolución reciente',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        GlucoseChart(readings: controller.readings),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.addGlucose,
                  )?.then((_) => controller.load()),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar glucosa'),
                ),
              ],
            );
        }
      }),
    );
  }
}
