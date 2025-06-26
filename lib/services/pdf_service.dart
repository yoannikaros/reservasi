import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';
import 'package:reservasi/models/booking.dart';
import 'package:reservasi/models/payment.dart';
import 'package:reservasi/models/setting.dart';

class PdfService {
  static Future<Uint8List> generateReceiptPdf({
    required Payment payment,
    required Booking booking,
    required Setting? setting,
  }) async {
    final pdf = pw.Document();
    
    // Load font data
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    
    // Format dates
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    // Get payment method text
    String getPaymentMethodText(String? method) {
      switch (method) {
        case 'cash':
          return 'Tunai';
        case 'transfer':
          return 'Transfer Bank';
        case 'qris':
          return 'QRIS';
        default:
          return method ?? 'Tidak disebutkan';
      }
    }
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  setting?.businessName ?? 'Reservasi Tempat Usaha',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (setting?.noteHeader != null && setting!.noteHeader!.isNotEmpty)
                  pw.Text(
                    setting.noteHeader!,
                    style: pw.TextStyle(font: ttf, fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                
                // Receipt info
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'STRUK PEMBAYARAN',
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      'No: #${payment.id}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text(
                      'Tanggal: ${dateFormat.format(DateTime.parse(payment.paymentDate))}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                
                // Customer info
                pw.Row(
                  children: [
                    pw.Text(
                      'INFORMASI PELANGGAN',
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text(
                      'Nama: ${booking.customerName}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                
                // Venue info
                pw.Row(
                  children: [
                    pw.Text(
                      'INFORMASI TEMPAT',
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text(
                      'Tempat: ${booking.venueName}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'Tanggal: ${dateFormat.format(DateTime.parse(booking.date))}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'Waktu: ${timeFormat.format(DateTime.parse(booking.startTime))} - ${timeFormat.format(DateTime.parse(booking.endTime))}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                
                // Payment details
                pw.Row(
                  children: [
                    pw.Text(
                      'DETAIL PEMBAYARAN',
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Reservasi:',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      'Rp ${booking.totalPrice?.toStringAsFixed(0) ?? "0"}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Jumlah Dibayar:',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      'Rp ${payment.amount.toStringAsFixed(0)}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Metode Pembayaran:',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      getPaymentMethodText(payment.method),
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Status:',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      booking.isPaid == 1 ? 'LUNAS' : 'BELUM LUNAS',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Notes
                if (payment.note != null && payment.note!.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Text(
                        'CATATAN',
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Text(
                        payment.note!,
                        style: pw.TextStyle(font: ttf, fontSize: 10),
                      ),
                    ],
                  ),
                ],
                
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),
                
                // Footer
                if (setting?.noteFooter != null && setting!.noteFooter!.isNotEmpty)
                  pw.Text(
                    setting.noteFooter!,
                    style: pw.TextStyle(font: ttf, fontSize: 10, fontStyle: pw.FontStyle.italic),
                    textAlign: pw.TextAlign.center,
                  )
                else
                  pw.Text(
                    'Terima kasih telah menggunakan layanan kami.',
                    style: pw.TextStyle(font: ttf, fontSize: 10, fontStyle: pw.FontStyle.italic),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  static Future<String> savePdfFile(Uint8List pdfData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file.path;
  }
}
