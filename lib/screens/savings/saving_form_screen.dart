import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reservasi/models/saving.dart';
import 'package:reservasi/repositories/saving_repository.dart';
import 'package:reservasi/utils/app_theme.dart';

class SavingFormScreen extends StatefulWidget {
  final Saving? saving;

  const SavingFormScreen({super.key, this.saving});

  @override
  State<SavingFormScreen> createState() => _SavingFormScreenState();
}

class _SavingFormScreenState extends State<SavingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SavingRepository _savingRepository = SavingRepository();
  
  bool _isLoading = false;
  
  String _type = 'deposit';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.saving != null) {
      _type = widget.saving!.type;
      _amountController.text = widget.saving!.amount.toString();
      _descriptionController.text = widget.saving!.description ?? '';
      _date = DateTime.parse(widget.saving!.date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveSaving() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Format date
        final dateStr = DateFormat('yyyy-MM-dd').format(_date);
        
        final saving = Saving(
          id: widget.saving?.id,
          type: _type,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          date: dateStr,
        );

        if (widget.saving == null) {
          await _savingRepository.insertSaving(saving);
        } else {
          await _savingRepository.updateSaving(saving);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data tabungan berhasil disimpan'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal menyimpan data tabungan: ${e.toString()}');
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
        title: Text(widget.saving == null ? 'Tambah Tabungan' : 'Edit Tabungan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Saving type
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Setoran'),
                    value: 'deposit',
                    groupValue: _type,
                    activeColor: AppTheme.successColor,
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Penarikan'),
                    value: 'withdrawal',
                    groupValue: _type,
                    activeColor: AppTheme.errorColor,
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
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
                  return 'Jumlah tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Date
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_date),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSaving,
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
