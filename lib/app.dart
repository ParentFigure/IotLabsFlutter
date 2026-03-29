import 'package:flutter/material.dart';
import 'package:src/core/theme/app_theme.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/auth/presentation/register_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/features/schedule/presentation/schedule_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lamp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        HomePage.routeName: (context) => const HomePage(),
        ProfilePage.routeName: (context) => const ProfilePage(),
        SchedulePage.routeName: (context) => const SchedulePage(),
      },
    );
  }
}
