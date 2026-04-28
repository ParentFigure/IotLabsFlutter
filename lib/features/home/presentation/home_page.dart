import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/home/presentation/widgets/home_dashboard.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LampController>().initialize();
      context.read<AuthController>().loadProfile();
    });
    final lamp = context.watch<LampController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Lamp Dashboard'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: lamp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: HomeDashboard(),
              ),
            ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthController>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to leave the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => navigator.pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await auth.logOut();
    navigator.pushNamedAndRemoveUntil(LoginPage.routeName, (_) => false);
  }
}
