import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reservasi/models/booking.dart';
import 'package:reservasi/models/payment.dart';
import 'package:reservasi/repositories/booking_repository.dart';
import 'package:reservasi/repositories/payment_repository.dart';
import 'package:reservasi/screens/payments/receipt_screen.dart';
import 'package:reservasi/utils/app_theme.dart';

class PaymentFormScreen extends StatefulWidget {
  final Payment? payment;

  const PaymentFormScreen({super.key, this.payment});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final BookingRepository _bookingRepository = BookingRepository();
  
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _isSaving = false;
  
  int? _selectedBookingId;
  final _amountController = TextEditingController();
  String _method = 'cash';
  DateTime _paymentDate = DateTime.now();
  final _noteController = TextEditingController();
  Payment? _savedPayment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await _bookingRepository.getAllBookings();
      
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
      
      if (widget.payment != null) {
        _selectedBookingId = widget.payment!.bookingId;
        _amountController.text = widget.payment!.amount.toString();
        _method = widget.payment!.method ?? 'cash';
        _paymentDate = DateTime.parse(widget.payment!.paymentDate);
        _noteController.text = widget.payment!.note ?? '';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data: ${e.toString()}');
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBookingId == null) {
        _showErrorSnackBar('Silakan pilih reservasi');
        return;
      }
      
      setState(() {
        _isSaving = true;
      });

      try {
        // Format date
        final dateStr = DateFormat('yyyy-MM-dd').format(_paymentDate);
        
        final payment = Payment(
          id: widget.payment?.id,
          bookingId: _selectedBookingId!,
          amount: double.parse(_amountController.text),
          method: _method,
          paymentDate: dateStr,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        int paymentId;
        if (widget.payment == null) {
          paymentId = await _paymentRepository.insertPayment(payment);
          
          // Update booking payment status if needed
          final booking = await _bookingRepository.getBookingById(_selectedBookingId!);
          if (booking != null && booking.isPaid == 0) {
            final totalPaid = await _getTotalPaidForBooking(_selectedBookingId!);
            if (totalPaid >= (booking.totalPrice ?? 0)) {
              await _bookingRepository.updateBooking(
                booking.copyWith(isPaid: 1),
              );
            }
          }
          
          // Get the saved payment with customer and venue names
          _savedPayment = await _paymentRepository.getPaymentById(paymentId);
        } else {
          await _paymentRepository.updatePayment(payment);
          _savedPayment = await _paymentRepository.getPaymentById(payment.id!);
        }

        if (mounted) {
          // Show dialog asking if user wants to view and print receipt
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Pembayaran Berhasil'),
              content: const Text('Apakah Anda ingin melihat dan mencetak struk pembayaran?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to payment list
                  },
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to payment list
                    
                    if (_savedPayment != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(payment: _savedPayment!),
                        ),
                      );
                    }
                  },
                  child: const Text('Ya'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal menyimpan data pembayaran: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<double> _getTotalPaidForBooking(int bookingId) async {
    try {
      final payments = await _paymentRepository.getPaymentsByBookingId(bookingId);
      double total = 0;
      for (var payment in payments) {
        total += payment.amount;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment == null ? 'Tambah Pembayaran' : 'Edit Pembayaran'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Booking selection
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Reservasi',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedBookingId,
                    items: _bookings.map((booking) {
                      final dateFormat = DateFormat('dd MMM yyyy');
                      return DropdownMenuItem<int>(
                        value: booking.id,
                        child: Text(
                          '${booking.customerName} - ${booking.venueName} (${dateFormat.format(DateTime.parse(booking.date))})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBookingId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Silakan pilih reservasi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Pembayaran',
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah pembayaran tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment method
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                      prefixIcon: Icon(Icons.payment),
                      border: OutlineInputBorder(),
                    ),
                    value: _method,
                    items: const [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text('Tunai'),
                      ),
                      DropdownMenuItem(
                        value: 'transfer',
                        child: Text('Transfer Bank'),
                      ),
                      DropdownMenuItem(
                        value: 'qris',
                        child: Text('QRIS'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _method = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment date
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pembayaran',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(_paymentDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Note
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePayment,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),
    );
  }
}
