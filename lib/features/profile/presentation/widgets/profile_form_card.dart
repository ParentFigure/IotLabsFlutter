import 'package:flutter/material.dart';
import 'package:src/features/auth/domain/validators.dart';
import 'package:src/shared/widgets/app_text_field.dart';

class ProfileFormCard extends StatelessWidget {
  const ProfileFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Edit profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameController,
                labelText: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                labelText: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: Validators.validatePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
