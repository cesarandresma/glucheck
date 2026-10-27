import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/measurement_contexts.dart';
import '../../core/utils/date_utils_app.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading_view.dart';
import '../../core/widgets/cache_banner.dart';
import '../../data/models/glucose_reading.dart';
import '../dashboard/dashboard_controller.dart';
import '../glucose/glucose_controller.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por valor, contexto o notas',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: controller.setSearch,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: controller.contextFilter.value,
                decoration: const InputDecoration(labelText: 'Contexto'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...MeasurementContexts.all.map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(MeasurementContexts.label(c)),
                    ),
                  ),
                ],
                onChanged: controller.setContextFilter,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('7 días'),
                    onPressed: () => controller.applyPresetDays(7),
                  ),
                  ActionChip(
                    label: const Text('30 días'),
                    onPressed: () => controller.applyPresetDays(30),
                  ),
                  ActionChip(
                    label: const Text('Elegir fechas'),
                    onPressed: () => _pickRange(context),
                  ),
                  ActionChip(
                    label: const Text('Quitar fechas'),
                    onPressed: controller.clearDates,
                  ),
                ],
              ),
              Obx(() {
                if (!controller.fromCache.value) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: CacheBanner(),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            switch (controller.state.value) {
              case LoadState.loading:
                return const AppLoadingView(message: 'Cargando historial...');
              case LoadState.error:
                return AppErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.load,
                );
              case LoadState.empty:
                return AppEmptyView(
                  title: 'Sin registros',
                  subtitle: 'Ajuste los filtros o registre una medición.',
                  actionLabel: 'Registrar',
                  onAction: () => Get.toNamed(
                    AppRoutes.addGlucose,
                  )?.then((_) => controller.load()),
                );
              case LoadState.success:
                final visible = controller.visibleReadings;
                if (visible.isEmpty) {
                  return const AppEmptyView(
                    title: 'Sin coincidencias',
                    subtitle: 'Pruebe con otro texto de búsqueda.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.builder(
                    itemCount: visible.length + 1,
                    itemBuilder: (context, index) {
                      if (index == visible.length) {
                        if (!controller.canLoadMore) {
                          return const SizedBox(height: 24);
                        }
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: OutlinedButton(
                            onPressed: controller.loadMore,
                            child: const Text('Cargar más'),
                          ),
                        );
                      }
                      final r = visible[index];
                      return _HistoryTile(
                        reading: r,
                        onChanged: controller.load,
                      );
                    },
                  ),
                );
            }
          }),
        ),
      ],
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final from = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: controller.fromDate ?? now,
      helpText: 'Fecha inicial',
    );
    if (from == null || !context.mounted) return;
    final to = await showDatePicker(
      context: context,
      firstDate: from,
      lastDate: now,
      initialDate: controller.toDate ?? now,
      helpText: 'Fecha final',
    );
    if (to == null) return;
    controller.setDateRange(
      DateUtilsApp.startOfDay(from),
      DateUtilsApp.endOfDay(to),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.reading, required this.onChanged});

  final GlucoseReading reading;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('${reading.valueMgDl.toStringAsFixed(0)} mg/dL'),
        subtitle: Text(Get.find<HistoryController>().subtitle(reading)),
        trailing: reading.isDemo ? const Chip(label: Text('Demo')) : null,
        onTap: () => _showDetail(context),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${reading.valueMgDl.toStringAsFixed(0)} mg/dL',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (reading.notes != null) Text(reading.notes!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.editGlucose,
                    arguments: reading,
                  )?.then((_) => onChanged());
                },
                child: const Text('Editar'),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Eliminar'),
                      content: const Text('¿Eliminar este registro?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('No'),
                        ),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Sí'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    final deleted = await Get.find<GlucoseController>()
                        .deleteReading(reading);
                    if (deleted) {
                      Get.back();
                      onChanged();
                    }
                  }
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
