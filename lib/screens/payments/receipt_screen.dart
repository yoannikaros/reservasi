import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:reservasi/models/booking.dart';
import 'package:reservasi/models/payment.dart';
import 'package:reservasi/models/setting.dart';
import 'package:reservasi/repositories/booking_repository.dart';
import 'package:reservasi/repositories/setting_repository.dart';
import 'package:reservasi/screens/payments/printer_selection_screen.dart';
import 'package:reservasi/services/pdf_service.dart';
import 'package:reservasi/services/printer_service.dart';
import 'package:reservasi/utils/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatefulWidget {
  final Payment payment;

  const ReceiptScreen({super.key, required this.payment});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final BookingRepository _bookingRepository = BookingRepository();
  final SettingRepository _settingRepository = SettingRepository();
  
  bool _isLoading = true;
  bool _isPrinting = false;
  Booking? _booking;
  Setting? _setting;
  Uint8List? _pdfData;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final booking = await _bookingRepository.getBookingById(widget.payment.bookingId);
      final setting = await _settingRepository.getSettings();
      
      setState(() {
        _booking = booking;
        _setting = setting;
      });
      
      if (booking != null) {
        await _generatePdf();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data: ${e.toString()}');
    }
  }

  Future<void> _generatePdf() async {
    try {
      if (_booking == null) return;
      
      final pdfData = await PdfService.generateReceiptPdf(
        payment: widget.payment,
        booking: _booking!,
        setting: _setting,
      );
      
      final fileName = 'struk_${widget.payment.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final pdfPath = await PdfService.savePdfFile(pdfData, fileName);
      
      setState(() {
        _pdfData = pdfData;
        _pdfPath = pdfPath;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal membuat PDF: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null) return;
    
    try {
      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        text: 'Struk Pembayaran #${widget.payment.id}',
      );
    } catch (e) {
      _showErrorSnackBar('Gagal membagikan PDF: ${e.toString()}');
    }
  }

  Future<void> _printPdf() async {
    if (_pdfData == null) return;
    
    setState(() {
      _isPrinting = true;
    });
    
    try {
      final selectedPrinter = PrinterService.getSelectedPrinter();
      
      if (selectedPrinter == null) {
        // Show printer selection screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrinterSelectionScreen(
              onPrinterSelected: (printer) {
                PrinterService.selectPrinter(printer);
              },
            ),
          ),
        );
      }
      
      // Check if printer is selected after returning from selection screen
      if (PrinterService.getSelectedPrinter() != null) {
        final success = await PrinterService.printPdf(_pdfData!);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Struk berhasil dicetak'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          _showErrorSnackBar('Gagal mencetak struk');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mencetak: ${e.toString()}');
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        actions: [
          if (_pdfPath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
              tooltip: 'Bagikan',
            ),
          if (_pdfData != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _isPrinting ? null : _printPdf,
              tooltip: 'Cetak',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
              ? const Center(child: Text('Data reservasi tidak ditemukan'))
              : _pdfPath == null
                  ? const Center(child: Text('Gagal membuat PDF'))
                  : Column(
                      children: [
                        Expanded(
                          child: PDFView(
                            filePath: _pdfPath!,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: false,
                            pageFling: false,
                            pageSnap: false,
                            fitPolicy: FitPolicy.BOTH,
                            preventLinkNavigation: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isPrinting ? null : _printPdf,
                                  icon: _isPrinting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.print),
                                  label: const Text('Cetak Struk'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
