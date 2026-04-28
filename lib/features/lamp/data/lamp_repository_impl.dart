import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/lamp_state.dart';
import 'package:src/shared/network/api_client.dart';

class LampRepositoryImpl implements LampRepository {
  LampRepositoryImpl({ApiClient? client}) : _client = client ?? ApiClient();

  static const String _lampStateKey = 'lamp_state';
  final ApiClient _client;

  @override
  Future<LampState> getLampState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawState = prefs.getString(_lampStateKey);
    if (rawState == null) {
      return LampState.initial();
    }

    final Object? decoded = jsonDecode(rawState);
    if (decoded is! Map<String, dynamic>) {
      return LampState.initial();
    }

    return LampState.fromJson(decoded);
  }

  @override
  Future<LampState> syncLampState() async {
    final LampState localState = await getLampState();
    try {
      final Map<String, dynamic> response = await _client.get('/lamp/state');
      final Object? rawState = response['lampState'];
      if (rawState is! Map<String, dynamic>) {
        return localState;
      }

      final LampState remoteState = LampState.fromJson(rawState);
      await _saveLocal(remoteState);
      return remoteState;
    } catch (_) {
      return localState;
    }
  }

  @override
  Future<void> saveLampState(LampState state) async {
    await _saveLocal(state);
    try {
      await _client.put(
        '/lamp/state',
        body: <String, dynamic>{'lampState': state.toJson()},
      );
    } catch (_) {}
  }

  Future<void> _saveLocal(LampState state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lampStateKey, jsonEncode(state.toJson()));
  }
}
