import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_button.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    required this.isLoading,
    required this.onSave,
    required this.onLogout,
    super.key,
  });

  final bool isLoading;
  final Future<void> Function() onSave;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppButton(
          title: isLoading ? 'Saving...' : 'Save changes',
          icon: Icons.save_outlined,
          onPressed: isLoading ? null : onSave,
        ),
        const SizedBox(height: 12),
        AppButton(
          title: 'Log out',
          icon: Icons.logout_rounded,
          onPressed: onLogout,
        ),
      ],
    );
  }
}
