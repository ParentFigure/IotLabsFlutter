final class Validators {
  static String? validateName(String? value) {
    final normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return 'Enter your name';
    }

    if (RegExp(r'\d').hasMatch(normalized)) {
      return 'Name must not contain digits';
    }

    if (normalized.length < 2) {
      return 'Name is too short';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return 'Enter your email';
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(normalized)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final normalized = value ?? '';

    if (normalized.isEmpty) {
      return 'Enter your password';
    }

    if (normalized.length < 6) {
      return 'Minimum 6 symbols';
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
  ) {
    final normalized = value ?? '';

    if (normalized.isEmpty) {
      return 'Confirm your password';
    }

    if (normalized != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
