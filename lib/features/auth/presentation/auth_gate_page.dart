import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  static const String routeName = '/';

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final bool isOnline = context.read<NetworkController>().isOnline;
    final user = await _authRepository.getCurrentUser();

    if (!mounted) {
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
          content: Text(
            'Auto-login worked, but Internet is unavailable. MQTT is limited.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
