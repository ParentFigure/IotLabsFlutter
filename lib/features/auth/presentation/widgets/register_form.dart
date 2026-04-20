import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/auth/domain/validators.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final User user = User(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );
    final bool ok = await context.read<AuthController>().register(user);
    if (!mounted) return;
    final state = context.read<AuthController>().state;
    _show(state.error ?? state.info ?? 'Done.');
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomePage.routeName,
        (Route<dynamic> route) => false,
      );
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
                controller: _nameController,
                labelText: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmController,
                labelText: 'Confirm password',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
                validator: (String? value) =>
                    Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AppButton(
          title: isLoading ? 'Saving...' : 'Sign up',
          onPressed: isLoading ? null : _submit,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, LoginPage.routeName),
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }
}
