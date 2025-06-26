import 'package:reservasi/models/payment.dart';
import 'package:reservasi/utils/database_helper.dart';

class PaymentRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Payment>> getAllPayments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, c.name as customer_name, v.name as venue_name
      FROM payments p
      JOIN bookings b ON p.booking_id = b.id
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
    ''');
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<Payment?> getPaymentById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, c.name as customer_name, v.name as venue_name
      FROM payments p
      JOIN bookings b ON p.booking_id = b.id
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
      WHERE p.id = ?
    ''', [id]);
    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Payment>> getPaymentsByBookingId(int bookingId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, c.name as customer_name, v.name as venue_name
      FROM payments p
      JOIN bookings b ON p.booking_id = b.id
      JOIN customers c ON b.customer_id = c.id
      JOIN venues v ON b.venue_id = v.id
      WHERE p.booking_id = ?
    ''', [bookingId]);
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
