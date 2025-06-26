import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reservasi/providers/auth_provider.dart';
import 'package:reservasi/screens/login_screen.dart';
import 'package:reservasi/screens/settings/profile_screen.dart';
import 'package:reservasi/screens/splash_screen.dart';
import 'package:reservasi/screens/settings/change_username_screen.dart';
import 'package:reservasi/screens/settings/change_password_screen.dart';
import 'package:reservasi/screens/settings/delete_account_screen.dart';
import 'package:reservasi/screens/settings/terms_of_service_screen.dart';
import 'package:reservasi/screens/settings/privacy_policy_screen.dart';
import 'package:reservasi/screens/settings/contact_us_screen.dart';
import 'package:reservasi/screens/settings/setting_screen.dart';
import 'package:reservasi/utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Reservasi Tempat Usaha',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
        ],
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/change-username': (context) => const ChangeUsernameScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/delete-account': (context) => const DeleteAccountScreen(),
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/contact-us': (context) => const ContactUsScreen(),
          '/business-settings': (context) => const SettingScreen(),
        },
      ),
    );
  }
}
