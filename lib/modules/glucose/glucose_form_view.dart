import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/measurement_contexts.dart';
import '../../core/utils/date_utils_app.dart';
import '../../data/models/glucose_reading.dart';
import '../dashboard/dashboard_controller.dart';
import '../history/history_controller.dart';
import '../statistics/statistics_controller.dart';
import 'glucose_controller.dart';

class GlucoseFormView extends StatefulWidget {
  const GlucoseFormView({super.key});

  @override
  State<GlucoseFormView> createState() => _GlucoseFormViewState();
}

class _GlucoseFormViewState extends State<GlucoseFormView> {
  GlucoseController get controller => Get.find<GlucoseController>();

  final _value = TextEditingController();
  final _notes = TextEditingController();
  late DateTime _measuredAt;
  late String _context;
  bool _initialized = false;

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _initFromArgs() {
    if (_initialized) return;
    _initialized = true;
    final args = Get.arguments;
    if (args is GlucoseReading) {
      controller.setEditing(args);
      _value.text = args.valueMgDl.toStringAsFixed(0);
      _notes.text = args.notes ?? '';
      _measuredAt = args.measuredAt.toLocal();
      _context = args.context;
    } else {
      controller.setEditing(null);
      _measuredAt = DateTime.now();
      _context = MeasurementContexts.fasting;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromArgs();
    final isEdit = controller.editing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar medición' : 'Registrar glucosa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _value,
                decoration: const InputDecoration(
                  labelText: 'Glucosa (mg/dL)',
                  suffixText: 'mg/dL',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.validateValueField,
              ),
              Obx(() {
                final w = controller.warningMessage.value;
                if (w == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    w,
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha y hora'),
                subtitle: Text(DateUtilsApp.formatDateTime(_measuredAt)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                      initialDate: _measuredAt,
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_measuredAt),
                    );
                    if (time == null || !mounted) return;
                    setState(() {
                      _measuredAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _context,
                decoration: const InputDecoration(labelText: 'Contexto'),
                items: MeasurementContexts.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(MeasurementContexts.label(c)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _context = v);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final err = controller.errorMessage.value;
                if (err != null) {
                  return Text(
                    err,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              Obx(() {
                return FilledButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () async {
                          final ok = await controller.save(
                            valueText: _value.text,
                            measuredAt: _measuredAt,
                            context: _context,
                            notes: _notes.text,
                          );
                          if (ok && mounted) {
                            if (Get.isRegistered<DashboardController>()) {
                              Get.find<DashboardController>().load();
                            }
                            if (Get.isRegistered<HistoryController>()) {
                              Get.find<HistoryController>().load();
                            }
                            if (Get.isRegistered<StatisticsController>()) {
                              Get.find<StatisticsController>().load();
                            }
                            Get.back(result: true);
                            Get.snackbar('Éxito', 'Medición guardada.');
                          }
                        },
                  child: controller.isSaving.value
                      ? const CircularProgressIndicator()
                      : Text(isEdit ? 'Actualizar' : 'Guardar'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
