import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _checkSession(context),
        builder: (context, snapshot) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _checkSession(BuildContext context) async {
    final AuthRepository authRepository = context.read<AuthRepository>();
    final bool isOnline = context.read<NetworkController>().isOnline;
    final user = await authRepository.getCurrentUser();
    if (!context.mounted) {
      return;
    }
    if (user == null) {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
      return;
    }
    Navigator.pushReplacementNamed(context, HomePage.routeName);
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-login worked, but Internet is unavailable.'),
        ),
      );
    }
  }
}
