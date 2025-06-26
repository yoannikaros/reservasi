import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reservasi/models/booking.dart';
import 'package:reservasi/models/customer.dart';
import 'package:reservasi/models/venue.dart';
import 'package:reservasi/repositories/booking_repository.dart';
import 'package:reservasi/repositories/customer_repository.dart';
import 'package:reservasi/repositories/venue_repository.dart';
import 'package:reservasi/utils/app_theme.dart';

class BookingFormScreen extends StatefulWidget {
  final Booking? booking;

  const BookingFormScreen({super.key, this.booking});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingRepository _bookingRepository = BookingRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final VenueRepository _venueRepository = VenueRepository();
  
  List<Customer> _customers = [];
  List<Venue> _venues = [];
  bool _isLoading = true;
  bool _isSaving = false;
  
  int? _selectedCustomerId;
  int? _selectedVenueId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  final _notesController = TextEditingController();
  String _status = 'reserved';
  bool _isPaid = false;
  double? _totalPrice;
  Venue? _selectedVenue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _customerRepository.getAllCustomers();
      final venues = await _venueRepository.getAllVenues();
      
      setState(() {
        _customers = customers;
        _venues = venues;
        _isLoading = false;
      });
      
      if (widget.booking != null) {
        _selectedCustomerId = widget.booking!.customerId;
        _selectedVenueId = widget.booking!.venueId;
        _selectedDate = DateTime.parse(widget.booking!.date);
        _startTime = TimeOfDay.fromDateTime(DateTime.parse(widget.booking!.startTime));
        _endTime = TimeOfDay.fromDateTime(DateTime.parse(widget.booking!.endTime));
        _notesController.text = widget.booking!.notes ?? '';
        _status = widget.booking!.status;
        _isPaid = widget.booking!.isPaid == 1;
        _totalPrice = widget.booking!.totalPrice;
        
        // Find selected venue to calculate price
        _selectedVenue = _venues.firstWhere((venue) => venue.id == _selectedVenueId);
        _calculateTotalPrice();
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

  void _onVenueChanged(int? venueId) {
    setState(() {
      _selectedVenueId = venueId;
      _selectedVenue = _venues.firstWhere((venue) => venue.id == venueId);
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    if (_selectedVenue != null) {
      final startHour = _startTime.hour + _startTime.minute / 60;
      final endHour = _endTime.hour + _endTime.minute / 60;
      final duration = endHour - startHour;
      
      if (duration > 0) {
        setState(() {
          _totalPrice = _selectedVenue!.pricePerHour * duration;
        });
      } else {
        setState(() {
          _totalPrice = 0;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _calculateTotalPrice();
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomerId == null) {
        _showErrorSnackBar('Silakan pilih pelanggan');
        return;
      }
      
      if (_selectedVenueId == null) {
        _showErrorSnackBar('Silakan pilih tempat');
        return;
      }
      
      // Check if end time is after start time
      final startHour = _startTime.hour + _startTime.minute / 60;
      final endHour = _endTime.hour + _endTime.minute / 60;
      if (endHour <= startHour) {
        _showErrorSnackBar('Waktu selesai harus setelah waktu mulai');
        return;
      }
      
      setState(() {
        _isSaving = true;
      });

      try {
        // Format date and time
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
        final now = DateTime.now();
        final startTimeStr = DateTime(
          now.year, now.month, now.day, _startTime.hour, _startTime.minute
        ).toIso8601String();
        final endTimeStr = DateTime(
          now.year, now.month, now.day, _endTime.hour, _endTime.minute
        ).toIso8601String();
        
        final booking = Booking(
          id: widget.booking?.id,
          customerId: _selectedCustomerId!,
          venueId: _selectedVenueId!,
          date: dateStr,
          startTime: startTimeStr,
          endTime: endTimeStr,
          totalPrice: _totalPrice,
          status: _status,
          isPaid: _isPaid ? 1 : 0,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        if (widget.booking == null) {
          await _bookingRepository.insertBooking(booking);
        } else {
          await _bookingRepository.updateBooking(booking);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data reservasi berhasil disimpan'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal menyimpan data reservasi: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Tambah Reservasi' : 'Edit Reservasi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Customer selection
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Pelanggan',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCustomerId,
                    items: _customers.map((customer) {
                      return DropdownMenuItem<int>(
                        value: customer.id,
                        child: Text(customer.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomerId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Silakan pilih pelanggan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Venue selection
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Tempat',
                      prefixIcon: Icon(Icons.place),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedVenueId,
                    items: _venues.map((venue) {
                      return DropdownMenuItem<int>(
                        value: venue.id,
                        child: Text('${venue.name} - Rp ${venue.pricePerHour.toStringAsFixed(0)}/jam'),
                      );
                    }).toList(),
                    onChanged: _onVenueChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Silakan pilih tempat';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date selection
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Time selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Waktu Mulai',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatTimeOfDay(_startTime)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Waktu Selesai',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatTimeOfDay(_endTime)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Total price
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Total Harga',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      'Rp ${_totalPrice?.toStringAsFixed(0) ?? "0"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info),
                      border: OutlineInputBorder(),
                    ),
                    value: _status,
                    items: const [
                      DropdownMenuItem(
                        value: 'reserved',
                        child: Text('Dipesan'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Selesai'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Dibatalkan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment status
                  SwitchListTile(
                    title: const Text('Status Pembayaran'),
                    subtitle: Text(_isPaid ? 'Lunas' : 'Belum Lunas'),
                    value: _isPaid,
                    activeColor: AppTheme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isPaid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
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
                    onPressed: _isSaving ? null : _saveBooking,
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
