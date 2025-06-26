import 'package:reservasi/models/saving.dart';
import 'package:reservasi/utils/database_helper.dart';

class SavingRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Saving>> getAllSavings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('savings');
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<Saving?> getSavingById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.insert('savings', saving.toMap());
  }

  Future<int> updateSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.update(
      'savings',
      saving.toMap(),
      where: 'id = ?',
      whereArgs: [saving.id],
    );
  }

  Future<int> deleteSaving(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
