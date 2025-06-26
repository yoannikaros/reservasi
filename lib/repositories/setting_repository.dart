import 'package:reservasi/models/setting.dart';
import 'package:reservasi/utils/database_helper.dart';

class SettingRepository {
  final dbHelper = DatabaseHelper();

  Future<Setting?> getSettings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    if (maps.isNotEmpty) {
      return Setting.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSettings(Setting setting) async {
    final db = await dbHelper.database;
    return await db.update(
      'settings',
      setting.toMap(),
      where: 'id = ?',
      whereArgs: [setting.id],
    );
  }
}
