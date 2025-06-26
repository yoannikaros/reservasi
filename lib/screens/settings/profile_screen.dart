import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservasi/providers/auth_provider.dart';
import 'package:reservasi/utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade400,
          ),
        ),
      );
    }

    Widget _buildMenuItem({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Colors.grey.shade700,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Username',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                       
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildSectionTitle('Account'),
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Change Username',
                onTap: () {
                  Navigator.pushNamed(context, '/change-username');
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: () {
                  Navigator.pushNamed(context, '/change-password');
                },
              ),
              _buildMenuItem(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                iconColor: Colors.red.shade400,
                onTap: () {
                  Navigator.pushNamed(context, '/delete-account');
                },
              ),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: Colors.red.shade400,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            authProvider.logout();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildSectionTitle('General'),
              _buildMenuItem(
                icon: Icons.store_rounded,
                title: 'Pengaturan Usaha',
                onTap: () {
                  Navigator.pushNamed(context, '/business-settings');
                },
              ),
              _buildSectionTitle('Support'),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {
                  Navigator.pushNamed(context, '/terms-of-service');
                },
              ),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.pushNamed(context, '/privacy-policy');
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Contact Us',
                onTap: () {
                  Navigator.pushNamed(context, '/contact-us');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 