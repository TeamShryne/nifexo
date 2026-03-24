abstract class SettingsRepository {
  Future<void> setSetting(String key, String value);
  Future<String?> getSetting(String key);
  Future<void> deleteSetting(String key);
}
