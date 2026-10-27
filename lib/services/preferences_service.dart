import '../data/providers/local/local_storage_provider.dart';

class PreferencesService {
  PreferencesService(this._local);

  final LocalStorageProvider _local;

  String _key(String userId, String suffix) => 'user_${userId}_$suffix';

  bool showDemoBanner(String userId) =>
      _local.getPreference<bool>(
        _key(userId, 'show_demo_banner'),
        defaultValue: true,
      ) ??
      true;

  Future<void> setShowDemoBanner(String userId, bool value) =>
      _local.setPreference(_key(userId, 'show_demo_banner'), value);

  String assistantBaseUrl(String userId) =>
      _local.getPreference<String>(
        _key(userId, 'assistant_url'),
        defaultValue: '',
      ) ??
      '';

  Future<void> setAssistantBaseUrl(String userId, String url) =>
      _local.setPreference(_key(userId, 'assistant_url'), url.trim());

  bool useCompactCharts(String userId) =>
      _local.getPreference<bool>(
        _key(userId, 'compact_charts'),
        defaultValue: false,
      ) ??
      false;

  Future<void> setUseCompactCharts(String userId, bool value) =>
      _local.setPreference(_key(userId, 'compact_charts'), value);
}
