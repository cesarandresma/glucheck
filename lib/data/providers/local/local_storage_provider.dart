import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/errors/app_exception.dart';

class LocalStorageProvider {
  static const preferencesBoxName = 'preferences';
  static const readingsCachePrefix = 'readings_cache_';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(preferencesBoxName)) {
      await Hive.openBox<dynamic>(preferencesBoxName);
    }
  }

  Box<dynamic> get _prefs => Hive.box<dynamic>(preferencesBoxName);

  Future<Box<dynamic>> openUserReadingsBox(String userId) async {
    final name = '$readingsCachePrefix$userId';
    if (Hive.isBoxOpen(name)) {
      return Hive.box<dynamic>(name);
    }
    return Hive.openBox<dynamic>(name);
  }

  Future<void> closeUserReadingsBox(String userId) async {
    final name = '$readingsCachePrefix$userId';
    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).close();
    }
  }

  Future<void> deleteUserReadingsBox(String userId) async {
    final name = '$readingsCachePrefix$userId';
    if (Hive.isBoxOpen(name)) {
      await Hive.box<dynamic>(name).clear();
      await Hive.box<dynamic>(name).close();
    }
    if (await Hive.boxExists(name)) {
      await Hive.deleteBoxFromDisk(name);
    }
  }

  T? getPreference<T>(String key, {T? defaultValue}) {
    final value = _prefs.get(key, defaultValue: defaultValue);
    return value as T?;
  }

  Future<void> setPreference(String key, dynamic value) async {
    await _prefs.put(key, value);
  }

  Future<void> clearPreferencesForUser(String userId) async {
    final keys = _prefs.keys
        .where((k) => k.toString().startsWith('user_$userId'))
        .toList();
    for (final key in keys) {
      await _prefs.delete(key);
    }
  }

  Future<void> clearAllUserLocalData(String userId) async {
    await deleteUserReadingsBox(userId);
    await clearPreferencesForUser(userId);
  }
}

class LocalStorageException extends CacheException {
  const LocalStorageException(super.message);
}
