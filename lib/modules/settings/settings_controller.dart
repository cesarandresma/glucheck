import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../data/demo/demo_glucose_data.dart';
import '../../data/providers/local/local_storage_provider.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../history/history_controller.dart';
import '../statistics/statistics_controller.dart';

class SettingsController extends GetxController {
  SettingsController(this._prefs, this._auth, this._glucose, this._local);

  final PreferencesService _prefs;
  final AuthService _auth;
  final GlucoseRepository _glucose;
  final LocalStorageProvider _local;

  final isBusy = false.obs;
  final message = RxnString();

  String? get userId => _auth.currentUser?.uid;

  bool compactCharts(String uid) => _prefs.useCompactCharts(uid);

  Future<void> setCompactCharts(bool value) async {
    final uid = userId;
    if (uid == null) return;
    await _prefs.setUseCompactCharts(uid, value);
    update();
  }

  String assistantUrl(String uid) => _prefs.assistantBaseUrl(uid);

  Future<void> saveAssistantUrl(String url) async {
    final uid = userId;
    if (uid == null) return;
    await _prefs.setAssistantBaseUrl(uid, url);
    Get.snackbar('Ajustes', 'URL del asistente guardada.');
  }

  Future<void> importDemoData() async {
    final uid = userId;
    if (uid == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cargar datos de demostración'),
        content: const Text(
          'Se crearán 20 mediciones ficticias marcadas como demostración en su cuenta. '
          'No son datos clínicos reales. ¿Desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cargar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isBusy.value = true;
    try {
      final templates = DemoGlucoseData.templates(placeholderUserId: uid);
      final count = await _glucose.importDemoReadings(
        userId: uid,
        demoReadings: templates,
      );
      message.value = 'Se importaron $count registros de demostración.';
      _reloadDataControllers();
    } on AppException catch (e) {
      message.value = e.message;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> deleteAccount(String password) async {
    final uid = userId;
    if (uid == null) return;
    if (password.isEmpty) {
      message.value = 'Ingrese su contraseña para confirmar.';
      return;
    }
    isBusy.value = true;
    message.value = null;
    try {
      await _auth.deleteAccount(password);
      await _local.clearAllUserLocalData(uid);
      Get.offAllNamed(AppRoutes.welcome);
    } on AppException catch (e) {
      message.value = e.message;
    } catch (_) {
      message.value = 'No se pudo eliminar la cuenta.';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> logout() async {
    final uid = userId;
    if (uid != null) {
      await _glucose.clearLocalCache(uid);
      await _local.clearAllUserLocalData(uid);
    }
    await Get.find<AuthController>().logout();
  }

  void _reloadDataControllers() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().load();
    }
    if (Get.isRegistered<HistoryController>()) {
      Get.find<HistoryController>().load();
    }
    if (Get.isRegistered<StatisticsController>()) {
      Get.find<StatisticsController>().load();
    }
  }
}
