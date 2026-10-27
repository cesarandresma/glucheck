import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../services/auth_service.dart';

enum LoadState { loading, success, empty, error }

class DashboardController extends GetxController {
  DashboardController(this._repo, this._auth);

  final GlucoseRepository _repo;
  final AuthService _auth;

  final state = LoadState.loading.obs;
  final errorMessage = ''.obs;
  final fromCache = false.obs;
  final readings = <GlucoseReading>[].obs;
  final profile = Rxn<UserProfile>();

  GlucoseReading? get latest => readings.isEmpty ? null : readings.first;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) {
      state.value = LoadState.error;
      errorMessage.value = 'Sesión expirada.';
      return;
    }
    state.value = LoadState.loading;
    try {
      profile.value = await _auth.getCurrentProfile();
      final result = await _repo.getReadings(userId: user.uid, limit: 14);
      readings.assignAll(result.readings);
      fromCache.value = result.fromCache;
      state.value = readings.isEmpty ? LoadState.empty : LoadState.success;
    } on AppException catch (e) {
      state.value = LoadState.error;
      errorMessage.value = e.message;
    } catch (_) {
      state.value = LoadState.error;
      errorMessage.value = 'Error al cargar el panel.';
    }
  }
}
