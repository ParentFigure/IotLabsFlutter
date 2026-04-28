import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecretFlashlight {
  const SecretFlashlight._();

  static const MethodChannel _channel = MethodChannel(
    'secret_flashlight',
  );

  static Future<bool> onLight() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'Flashlight control is supported only on Android devices.',
      );
    }

    final bool? isEnabled = await _channel.invokeMethod<bool>('toggleTorch');
    return isEnabled ?? false;
  }
}
