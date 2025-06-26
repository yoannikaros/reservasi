import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reservasi/models/venue.dart';
import 'package:reservasi/repositories/venue_repository.dart';
import 'package:reservasi/utils/app_theme.dart';

class VenueFormScreen extends StatefulWidget {
  final Venue? venue;

  const VenueFormScreen({super.key, this.venue});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  
  final VenueRepository _venueRepository = VenueRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.venue != null) {
      _nameController.text = widget.venue!.name;
      _descriptionController.text = widget.venue!.description ?? '';
      _locationController.text = widget.venue!.location ?? '';
      _capacityController.text = widget.venue!.capacity?.toString() ?? '';
      _pricePerHourController.text = widget.venue!.pricePerHour.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _pricePerHourController.dispose();
    super.dispose();
  }

  Future<void> _saveVenue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final venue = Venue(
          id: widget.venue?.id,
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          capacity: _capacityController.text.isEmpty ? null : int.parse(_capacityController.text),
          pricePerHour: double.parse(_pricePerHourController.text),
        );

        if (widget.venue == null) {
          await _venueRepository.insertVenue(venue);
        } else {
          await _venueRepository.updateVenue(venue);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data tempat berhasil disimpan'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data tempat: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venue == null ? 'Tambah Tempat' : 'Edit Tempat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Tempat',
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tempat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi (Opsional)',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Kapasitas (Opsional)',
                prefixIcon: Icon(Icons.people),
                suffixText: 'orang',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pricePerHourController,
              decoration: const InputDecoration(
                labelText: 'Harga per Jam',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga per jam tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveVenue,
              child: _isLoading
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
