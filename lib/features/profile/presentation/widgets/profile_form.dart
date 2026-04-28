import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/profile/presentation/widgets/profile_actions.dart';
import 'package:src/features/profile/presentation/widgets/profile_form_card.dart';
import 'package:src/features/profile/presentation/widgets/profile_header_card.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.currentUser;
    if (!_filled && user != null) {
      _filled = true;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _passwordController.text = user.password;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ProfileHeaderCard(user: user),
        const SizedBox(height: 24),
        ProfileFormCard(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
        ),
        const SizedBox(height: 24),
        ProfileActions(
          isLoading: auth.state.isLoading,
          onSave: _save,
          onLogout: _logout,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final User user = User(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );
    await context.read<AuthController>().updateProfile(user);
    if (mounted) {
      _show(context.read<AuthController>().state.info ?? 'Profile updated.');
    }
  }

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to leave the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await context.read<AuthController>().logOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginPage.routeName,
        (_) => false,
      );
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
