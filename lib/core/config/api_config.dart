import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://192.168.99.101:8000';
    if (Platform.isAndroid) return 'http://192.168.99.101:8000';
    return 'http://192.168.99.101:8000';
  }
}
