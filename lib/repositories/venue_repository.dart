import 'package:reservasi/models/venue.dart';
import 'package:reservasi/utils/database_helper.dart';

class VenueRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Venue>> getAllVenues() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('venues');
    return List.generate(maps.length, (i) {
      return Venue.fromMap(maps[i]);
    });
  }

  Future<Venue?> getVenueById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'venues',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Venue.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertVenue(Venue venue) async {
    final db = await dbHelper.database;
    return await db.insert('venues', venue.toMap());
  }

  Future<int> updateVenue(Venue venue) async {
    final db = await dbHelper.database;
    return await db.update(
      'venues',
      venue.toMap(),
      where: 'id = ?',
      whereArgs: [venue.id],
    );
  }

  Future<int> deleteVenue(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'venues',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
