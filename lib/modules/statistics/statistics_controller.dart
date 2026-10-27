import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils_app.dart';
import '../../core/utils/statistics_calculator.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_controller.dart';

class StatisticsController extends GetxController {
  StatisticsController(this._repo, this._auth);

  final GlucoseRepository _repo;
  final AuthService _auth;

  final state = LoadState.loading.obs;
  final errorMessage = ''.obs;
  final readings = <GlucoseReading>[].obs;
  final stats = Rxn<GlucoseStatistics>();
  final comparison = Rxn<PeriodComparison>();
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    fromDate = DateUtilsApp.startOfDay(now.subtract(const Duration(days: 30)));
    toDate = DateUtilsApp.endOfDay(now);
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
      final result = await _repo.getReadings(
        userId: user.uid,
        from: fromDate,
        to: toDate,
        limit: 200,
      );
      readings.assignAll(result.readings);
      stats.value = GlucoseStatistics.fromReadings(readings);
      comparison.value = await _loadComparison(stats.value);
      state.value = readings.isEmpty ? LoadState.empty : LoadState.success;
    } on AppException catch (e) {
      state.value = LoadState.error;
      errorMessage.value = e.message;
    }
  }

  void setRange(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    load();
  }

  void applyPresetDays(int days) {
    final now = DateTime.now();
    setRange(
      DateUtilsApp.startOfDay(now.subtract(Duration(days: days))),
      DateUtilsApp.endOfDay(now),
    );
  }

  Future<PeriodComparison?> _loadComparison(GlucoseStatistics? current) async {
    final from = fromDate;
    final to = toDate;
    final user = _auth.currentUser;
    if (from == null || to == null || user == null || current == null) {
      return null;
    }
    final duration = to.difference(from);
    if (duration.inSeconds <= 0) return null;
    final previousTo = from.subtract(const Duration(milliseconds: 1));
    final previousFrom = previousTo.subtract(duration);
    try {
      final previous = await _repo.getReadings(
        userId: user.uid,
        from: previousFrom,
        to: previousTo,
        limit: 200,
      );
      return PeriodComparison.compare(
        current,
        GlucoseStatistics.fromReadings(previous.readings),
      );
    } on AppException {
      return null;
    }
  }
}
