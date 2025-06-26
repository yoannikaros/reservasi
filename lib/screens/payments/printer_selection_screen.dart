import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:reservasi/services/printer_service.dart';
import 'package:reservasi/utils/app_theme.dart';

class PrinterSelectionScreen extends StatefulWidget {
  final Function(PrinterDevice) onPrinterSelected;

  const PrinterSelectionScreen({
    super.key,
    required this.onPrinterSelected,
  });

  @override
  State<PrinterSelectionScreen> createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  List<PrinterDevice> _printers = [];
  bool _isLoading = true;
  PrinterDevice? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PrinterService.initialize();
      await _discoverPrinters();
    } catch (e) {
      _showErrorSnackBar('Gagal menginisialisasi printer: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _discoverPrinters() async {
    try {
      final printers = await PrinterService.discoverPrinters();
      setState(() {
        _printers = printers;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal menemukan printer: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Printer')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Silakan pilih printer Bluetooth yang tersedia',
              textAlign: TextAlign.center,
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_printers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.print_disabled, size: 64),
                    const SizedBox(height: 16),
                    const Text('Tidak ada printer ditemukan'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _discoverPrinters,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cari Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _printers.length,
                itemBuilder: (context, index) {
                  final printer = _printers[index];
                  final isSelected = _selectedPrinter?.address == printer.address;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.print),
                      title: Text(printer.name ?? 'Printer Tidak Dikenal'),
                      subtitle: Text(printer.address!),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPrinter = printer;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPrinter == null
                        ? null
                        : () {
                      PrinterService.selectPrinter(_selectedPrinter!);
                      widget.onPrinterSelected(_selectedPrinter!);
                      Navigator.pop(context);
                    },
                    child: const Text('Pilih Printer'),
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
