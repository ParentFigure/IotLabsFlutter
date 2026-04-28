import 'package:flutter/material.dart';
import 'package:src/features/auth/presentation/widgets/register_form.dart';
import 'package:src/shared/widgets/section_title.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

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
              children: const <Widget>[
                SectionTitle(
                  title: 'Create account',
                  subtitle: 'Prepare your profile for the lamp app.',
                ),
                SizedBox(height: 28),
                RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
