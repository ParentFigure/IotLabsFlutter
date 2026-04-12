import 'package:flutter/material.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/validators.dart';
import 'package:src/features/auth/presentation/register_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = await _authRepository.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Check email and password.'),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, HomePage.routeName);
  }

  @override
  Widget build(BuildContext context) {
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
                  'ESP32 UI for lighting lamp with a light sensor and '
                  'user schedule.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
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
                  title: _isLoading ? 'Signing in...' : 'Sign in',
                  onPressed: _isLoading ? null : _signIn,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const RegisterPage(),
                      ),
                    );
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
