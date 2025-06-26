import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_updated/esc_pos_utils_updated.dart';

class PrinterService {
  static final PrinterManager _printerManager = PrinterManager.instance;
  static List<PrinterDevice> _printers = [];
  static PrinterDevice? _selectedPrinter;

  /// Inisialisasi dan minta izin Bluetooth
  static Future<void> initialize() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    // PrinterManager doesn't have initialize method, it's initialized when instance is accessed
  }

  /// Temukan printer Bluetooth
  static Future<List<PrinterDevice>> discoverPrinters() async {
    try {
      // Convert the Stream<PrinterDevice> to List<PrinterDevice>
      final stream = _printerManager.discovery(
        type: PrinterType.bluetooth,
        isBle: false,
      );

      _printers = await stream.toList();
      return _printers;
    } catch (e) {
      debugPrint('Error discovering printers: $e');
      return [];
    }
  }

  /// Pilih printer
  static void selectPrinter(PrinterDevice printer) {
    _selectedPrinter = printer;
  }

  /// Dapatkan printer yang dipilih
  static PrinterDevice? getSelectedPrinter() {
    return _selectedPrinter;
  }

  /// Cetak PDF dalam bentuk gambar
  static Future<bool> printPdf(Uint8List pdfData) async {
    try {
      if (_selectedPrinter == null) {
        debugPrint('No printer selected');
        return false;
      }

      final pdfPages = await Printing.raster(pdfData, pages: [0], dpi: 203);
      if (pdfPages.isEmpty == true) return false;

      final pageImage = await pdfPages.first;
      final page = await pageImage.toPng();

      final image = img.decodeImage(page);
      if (image == null) return false;

      final resizedImage = img.copyResize(
        image,
        width: 384, // sesuaikan dengan printer Anda
        interpolation: img.Interpolation.linear,
      );

      final pngBytes = img.encodePng(resizedImage);

      // Hubungkan ke printer
      await _printerManager.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: _selectedPrinter!.name ?? 'Unknown Printer',
          address: _selectedPrinter!.address ?? '',
          isBle: false,
          autoConnect: true,
        ),
      );

      // Kirim gambar ke printer
      await _printerManager.send(
        type: PrinterType.bluetooth,
        bytes: Uint8List.fromList(pngBytes),
      );

      // Tambahkan pemotongan kertas
      final generator = Generator(PaperSize.mm80, await CapabilityProfile.load());
      final cut = generator.cut();
      await _printerManager.send(
        type: PrinterType.bluetooth,
        bytes: Uint8List.fromList(cut),
      );

      return true;
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      return false;
    }
  }

  /// Putuskan koneksi printer
  static Future<void> disconnect() async {
    await _printerManager.disconnect(type: PrinterType.bluetooth);
  }
}
