import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/glucose_validators.dart';
import '../../core/errors/app_exception.dart';
import '../../services/connectivity_service.dart';
import '../models/glucose_reading.dart';
import '../providers/firebase/glucose_firestore_provider.dart';
import '../providers/local/local_storage_provider.dart';

class GlucoseListResult {
  const GlucoseListResult({required this.readings, required this.fromCache});

  final List<GlucoseReading> readings;
  final bool fromCache;
}

class GlucoseRepository {
  GlucoseRepository({
    required GlucoseFirestoreProvider remote,
    required LocalStorageProvider local,
    required ConnectivityService connectivity,
  }) : _remote = remote,
       _local = local,
       _connectivity = connectivity;

  final GlucoseFirestoreProvider _remote;
  final LocalStorageProvider _local;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  static const cacheKey = 'items';

  Future<GlucoseListResult> getReadings({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? context,
    int limit = AppConstants.defaultPageSize,
  }) async {
    final online = await _connectivity.isOnline;
    if (online) {
      try {
        final remote = await _remote.fetchReadings(
          userId: userId,
          from: from,
          to: to,
          context: context,
          limit: limit,
        );
        await _saveCache(userId, remote);
        return GlucoseListResult(readings: remote, fromCache: false);
      } on AppException {
        final cached = await _loadCache(userId);
        if (cached.isNotEmpty) {
          return GlucoseListResult(
            readings: _applyFilters(
              cached,
              from: from,
              to: to,
              context: context,
            ),
            fromCache: true,
          );
        }
        rethrow;
      }
    }
    final cached = await _loadCache(userId);
    if (cached.isEmpty) {
      throw const NetworkException(
        'Sin conexión y no hay datos en caché para mostrar.',
      );
    }
    return GlucoseListResult(
      readings: _applyFilters(cached, from: from, to: to, context: context),
      fromCache: true,
    );
  }

  Future<GlucoseReading> addReading({
    required String userId,
    required double valueMgDl,
    required DateTime measuredAt,
    required String context,
    String? notes,
    bool isDemo = false,
  }) async {
    _assertWritable(valueMgDl: valueMgDl, context: context, notes: notes);
    final now = DateTime.now().toUtc();
    final reading = GlucoseReading(
      id: _uuid.v4(),
      userId: userId,
      valueMgDl: valueMgDl,
      measuredAt: measuredAt.toUtc(),
      context: context,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: now,
      updatedAt: now,
      source: GlucoseSource.manual,
      isDemo: isDemo,
    );

    final online = await _connectivity.isOnline;
    if (!online) {
      throw const NetworkException(
        'Se requiere conexión para guardar una medición.',
      );
    }
    final saved = await _remote.create(reading);
    final cached = await _loadCache(userId);
    cached.insert(0, saved);
    await _saveCache(userId, cached);
    return saved;
  }

  Future<GlucoseReading> updateReading(GlucoseReading reading) async {
    final online = await _connectivity.isOnline;
    if (!online) {
      throw const NetworkException(
        'Se requiere conexión para actualizar una medición.',
      );
    }
    _assertWritable(
      valueMgDl: reading.valueMgDl,
      context: reading.context,
      notes: reading.notes,
    );
    final updated = reading.copyWith(updatedAt: DateTime.now().toUtc());
    final saved = await _remote.update(updated);
    final cached = await _loadCache(reading.userId);
    final index = cached.indexWhere((r) => r.id == reading.id);
    if (index >= 0) {
      cached[index] = saved;
      await _saveCache(reading.userId, cached);
    }
    return saved;
  }

  Future<void> deleteReading({
    required String userId,
    required String readingId,
  }) async {
    final online = await _connectivity.isOnline;
    if (!online) {
      throw const NetworkException(
        'Se requiere conexión para eliminar una medición.',
      );
    }
    await _remote.delete(userId: userId, readingId: readingId);
    final cached = await _loadCache(userId);
    cached.removeWhere((r) => r.id == readingId);
    await _saveCache(userId, cached);
  }

  Future<int> importDemoReadings({
    required String userId,
    required List<GlucoseReading> demoReadings,
  }) async {
    var count = 0;
    for (final template in demoReadings) {
      final reading = template.copyWith(
        id: _uuid.v4(),
        userId: userId,
        isDemo: true,
        source: GlucoseSource.imported,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      await _remote.create(reading);
      count++;
    }
    final all = await _remote.fetchReadings(userId: userId, limit: 100);
    await _saveCache(userId, all);
    return count;
  }

  Future<void> clearLocalCache(String userId) async {
    await _local.deleteUserReadingsBox(userId);
  }

  Future<void> deleteAllReadings(String userId) async {
    final online = await _connectivity.isOnline;
    if (!online) {
      throw const NetworkException(
        'Se requiere conexión para eliminar los datos de la cuenta.',
      );
    }
    await _remote.deleteAll(userId);
    await clearLocalCache(userId);
  }

  void _assertWritable({
    required double valueMgDl,
    required String context,
    String? notes,
  }) {
    if (!GlucoseReading.isValidContext(context)) {
      throw const ValidationException('Contexto de medición no válido.');
    }
    final valueError = GlucoseValidators.validateValue(
      valueMgDl.toString(),
    ).errorMessage;
    if (valueError != null) {
      throw ValidationException(valueError);
    }
    final notesError = GlucoseValidators.validateNotes(notes);
    if (notesError != null) {
      throw ValidationException(notesError);
    }
  }

  List<GlucoseReading> _applyFilters(
    List<GlucoseReading> list, {
    DateTime? from,
    DateTime? to,
    String? context,
  }) {
    return list.where((r) {
      final t = r.measuredAt.toLocal();
      if (from != null && t.isBefore(from)) return false;
      if (to != null && t.isAfter(to)) return false;
      if (context != null && context.isNotEmpty && r.context != context) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  Future<List<GlucoseReading>> _loadCache(String userId) async {
    final box = await _local.openUserReadingsBox(userId);
    final raw = box.get(cacheKey);
    if (raw is! List) return [];
    return raw
        .map(
          (e) => GlucoseReading.fromLocalJson(
            Map<dynamic, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> _saveCache(String userId, List<GlucoseReading> readings) async {
    final box = await _local.openUserReadingsBox(userId);
    await box.put(cacheKey, readings.map((r) => r.toLocalJson()).toList());
  }
}
