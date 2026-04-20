import 'package:flutter/material.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/auth/domain/validators.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/app_text_field.dart';
import 'package:src/shared/widgets/section_title.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final User user = User(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );

    try {
      await _authRepository.register(user);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful.')),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      HomePage.routeName,
      (Route<dynamic> route) => false,
    );
  }

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
              children: <Widget>[
                const SectionTitle(
                  title: 'Create account',
                  subtitle: 'Prepare your profile for the lamp app.',
                ),
                const SizedBox(height: 28),
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
                        controller: _confirmPasswordController,
                        labelText: 'Confirm password',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: true,
                        validator: (String? value) {
                          return Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AppButton(
                  title: _isLoading ? 'Saving...' : 'Sign up',
                  onPressed: _isLoading ? null : _register,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement<void, void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
