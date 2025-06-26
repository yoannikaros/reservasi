import 'package:reservasi/models/booking.dart';
import 'package:reservasi/utils/database_helper.dart';

class BookingRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Booking>> getAllBookings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as customer_name, v.name as venue_name
      FROM bookings b
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
    ''');
    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as customer_name, v.name as venue_name
      FROM bookings b
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
      WHERE b.id = ?
    ''', [id]);
    if (maps.isNotEmpty) {
      return Booking.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Booking>> getBookingsByCustomerId(int customerId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as customer_name, v.name as venue_name
      FROM bookings b
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
      WHERE b.customer_id = ?
    ''', [customerId]);
    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<List<Booking>> getBookingsByVenueId(int venueId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as customer_name, v.name as venue_name
      FROM bookings b
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
      WHERE b.venue_id = ?
    ''', [venueId]);
    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<int> insertBooking(Booking booking) async {
    final db = await dbHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await dbHelper.database;
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
