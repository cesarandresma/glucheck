import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/date_utils_app.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading_view.dart';
import '../../core/widgets/glucose_chart.dart';
import '../dashboard/dashboard_controller.dart';
import 'statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
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
            ],
          ),
        ),
        Expanded(child: Obx(() => _body(context))),
      ],
    );
  }

  Widget _body(BuildContext context) {
    switch (controller.state.value) {
      case LoadState.loading:
        return const AppLoadingView(message: 'Calculando estadísticas...');
      case LoadState.error:
        return AppErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.load,
        );
      case LoadState.empty:
        return const AppEmptyView(
          title: 'Sin datos en el periodo',
          subtitle: 'Registre mediciones o amplíe el rango de fechas.',
        );
      case LoadState.success:
        final s = controller.stats.value!;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Estadísticas descriptivas (no diagnóstico)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Promedio',
                    value: '${s.average.toStringAsFixed(1)} mg/dL',
                  ),
                  _StatCard(
                    label: 'Mínimo',
                    value: '${s.minimum.toStringAsFixed(0)} mg/dL',
                  ),
                  _StatCard(
                    label: 'Máximo',
                    value: '${s.maximum.toStringAsFixed(0)} mg/dL',
                  ),
                  _StatCard(label: 'Registros', value: '${s.count}'),
                ],
              ),
              if (controller.comparison.value != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Comparación descriptiva con el periodo anterior '
                      '(misma duración): promedio '
                      '${controller.comparison.value!.previousAverage.toStringAsFixed(1)} mg/dL; '
                      'diferencia '
                      '${controller.comparison.value!.difference.toStringAsFixed(1)} mg/dL. '
                      'No es una evaluación clínica.',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlucoseChart(readings: controller.readings),
                ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final initialFrom =
        controller.fromDate ?? now.subtract(const Duration(days: 30));
    final from = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: initialFrom,
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
    controller.setRange(
      DateUtilsApp.startOfDay(from),
      DateUtilsApp.endOfDay(to),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
