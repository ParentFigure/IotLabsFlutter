import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/profile/presentation/widgets/profile_form.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().loadProfile();
    });
    final bool isLoading = context.watch<AuthController>().state.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : const ProfileForm(),
          ),
        ),
      ),
    );
  }
}
