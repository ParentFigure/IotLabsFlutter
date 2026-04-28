import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/presentation/widgets/login_form.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final bool isOnline = context.watch<NetworkController>().isOnline;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: <Widget>[
                const SizedBox(height: 16),
                const Icon(Icons.lightbulb_rounded, size: 132),
                const SizedBox(height: 32),
                Text(
                  'Smart Lamp',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'ESP32 UI for a lamp, MQTT telemetry and weekly schedules.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (!isOnline)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Manual login is blocked while offline.'),
                    ),
                  ),
                const SizedBox(height: 24),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
