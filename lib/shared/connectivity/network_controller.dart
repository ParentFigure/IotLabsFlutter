import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkController extends ChangeNotifier {
  NetworkController({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    _setStatus(results);

    await _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(_setStatus);
  }

  void _setStatus(List<ConnectivityResult> results) {
    final bool hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (_isOnline == hasConnection) {
      return;
    }

    _isOnline = hasConnection;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
