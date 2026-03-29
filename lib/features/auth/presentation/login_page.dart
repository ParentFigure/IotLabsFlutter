import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
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
                  'ESP32 UI for lighting lamp with a light sensor '
                  'and user schedule.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                const AppTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 20),
                const AppTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 28),
                AppButton(
                  title: 'Sign in',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
