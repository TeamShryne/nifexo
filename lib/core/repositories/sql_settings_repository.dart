import 'package:nifexo/core/database/app_database.dart';
import 'package:nifexo/core/repositories/settings_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqlSettingsRepository implements SettingsRepository {
  AppDatabase get _appDatabase => AppDatabase();

  @override
  Future<void> setSetting(String key, String value) async {
    final db = await _appDatabase.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
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

  @override
  Future<void> deleteSetting(String key) async {
    final db = await _appDatabase.database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }
}
