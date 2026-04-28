import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';
import 'package:src/features/auth/domain/user.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({required this.user, super.key});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.cardLight,
          child: Icon(Icons.person, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'User',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(user?.email ?? 'No email', textAlign: TextAlign.center),
      ],
    );
  }
}
