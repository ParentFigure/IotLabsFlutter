import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';
import 'package:src/shared/widgets/section_title.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                const SectionTitle(
                  title: 'Create account',
                  subtitle: 'Prepare your profile for the lamp app.',
                ),
                const SizedBox(height: 28),
                const AppTextField(
                  hintText: 'Full name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  hintText: 'Confirm password',
                  prefixIcon: Icons.lock_reset_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 28),
                AppButton(
                  title: 'Sign up',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
