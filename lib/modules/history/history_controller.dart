import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/measurement_contexts.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils_app.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_controller.dart';

class HistoryController extends GetxController {
  HistoryController(this._repo, this._auth);

  final GlucoseRepository _repo;
  final AuthService _auth;

  final state = LoadState.loading.obs;
  final errorMessage = ''.obs;
  final fromCache = false.obs;
  final readings = <GlucoseReading>[].obs;
  final contextFilter = RxnString();
  final searchQuery = ''.obs;
  DateTime? fromDate;
  DateTime? toDate;
  int _limit = AppConstants.defaultPageSize;

  bool get canLoadMore => readings.length >= _limit;

  List<GlucoseReading> get visibleReadings {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return readings;
    return readings.where((reading) {
      final notes = (reading.notes ?? '').toLowerCase();
      final value = reading.valueMgDl.toStringAsFixed(0);
      final label = MeasurementContexts.label(reading.context).toLowerCase();
      return notes.contains(query) ||
          value.contains(query) ||
          label.contains(query);
    }).toList();
  }

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
      final result = await _repo.getReadings(
        userId: user.uid,
        from: fromDate,
        to: toDate,
        context: contextFilter.value,
        limit: _limit,
      );
      readings.assignAll(result.readings);
      fromCache.value = result.fromCache;
      state.value = readings.isEmpty ? LoadState.empty : LoadState.success;
    } on AppException catch (e) {
      state.value = LoadState.error;
      errorMessage.value = e.message;
    }
  }

  void setContextFilter(String? value) {
    contextFilter.value = value;
    _limit = AppConstants.defaultPageSize;
    load();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate = from;
    toDate = to;
    _limit = AppConstants.defaultPageSize;
    load();
  }

  void applyPresetDays(int days) {
    final now = DateTime.now();
    setDateRange(
      DateUtilsApp.startOfDay(now.subtract(Duration(days: days))),
      DateUtilsApp.endOfDay(now),
    );
  }

  void clearDates() => setDateRange(null, null);

  void setSearch(String value) => searchQuery.value = value;

  Future<void> loadMore() async {
    _limit += AppConstants.defaultPageSize;
    await load();
  }

  String subtitle(GlucoseReading r) =>
      '${DateUtilsApp.formatDateTime(r.measuredAt.toLocal())} · '
      '${MeasurementContexts.label(r.context)}';
}
