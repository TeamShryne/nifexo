import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  final AppDatabase _appDatabase = AppDatabase();

  Future<void> setSetting(String key, String value) async {
    final db = await _appDatabase.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'];
  }

  Future<void> deleteSetting(String key) async {
    final db = await _appDatabase.database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }
}
