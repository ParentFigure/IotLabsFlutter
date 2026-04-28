import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/domain/validators.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/auth/presentation/register_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!context.read<NetworkController>().isOnline) {
      _show('Internet is required for manual login.');
      return;
    }
    final bool ok = await context.read<AuthController>().signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    final authState = context.read<AuthController>().state;
    if (authState.error != null) _show(authState.error!);
    if (ok) {
      _show(authState.info ?? 'Signed in.');
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<AuthController>().state.isLoading;
    return Column(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline_rounded,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: Validators.validatePassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AppButton(
          title: isLoading ? 'Signing in...' : 'Sign in',
          onPressed: isLoading ? null : _signIn,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, RegisterPage.routeName),
          child: const Text('Create account'),
        ),
      ],
    );
  }
}
