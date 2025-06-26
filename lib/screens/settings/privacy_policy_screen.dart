import 'package:flutter/material.dart';
import 'package:reservasi/utils/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berlaku sejak: 1 Juli 2024',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _sectionTitle('1. Pengantar'),
              const Text(
                'Kebijakan Privasi ini menjelaskan bagaimana aplikasi kami menangani data Anda. Karena aplikasi ini beroperasi 100% secara offline, pendekatan kami terhadap privasi sangat sederhana: data Anda adalah milik Anda dan tetap berada di perangkat Anda.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('2. Pengumpulan dan Penggunaan Data'),
              const Text(
                'Kami tidak mengumpulkan, menyimpan, atau mentransmisikan informasi pribadi apa pun dari Anda atau perangkat Anda. Semua data yang Anda masukkan—seperti data reservasi, pelanggan, atau transaksi—disimpan secara eksklusif di penyimpanan lokal perangkat Anda. Data ini tidak pernah dikirim kepada kami atau pihak ketiga mana pun.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('3. Penyimpanan Lokal'),
              const Text(
                'Seluruh fungsionalitas aplikasi dirancang untuk bekerja tanpa koneksi internet. Data yang Anda simpan tetap berada di dalam aplikasi di perangkat Anda. Jika Anda menghapus instalan aplikasi, semua data yang terkait dengannya akan dihapus secara permanen dari perangkat Anda.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('4. Izin Aplikasi (Permissions)'),
              const Text(
                'Aplikasi ini mungkin meminta izin akses ke penyimpanan perangkat Anda. Izin ini hanya diperlukan untuk menyimpan dan mengelola basis data lokal aplikasi. Kami tidak mengakses, membaca, atau memanipulasi file pribadi Anda lainnya.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('5. Layanan Pihak Ketiga'),
              const Text(
                'Aplikasi ini tidak menggunakan layanan dari pihak ketiga mana pun untuk analitik, periklanan, atau tujuan lain yang dapat mengumpulkan data dari Anda.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('6. Perubahan Kebijakan'),
              const Text(
                'Kami dapat memperbarui Kebijakan Privasi ini sewaktu-waktu. Perubahan akan diinformasikan melalui aplikasi atau website resmi.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('7. Kontak'),
              const Text(
                'Jika ada pertanyaan terkait Kebijakan Privasi, silakan hubungi kami melalui halaman Kontak.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 