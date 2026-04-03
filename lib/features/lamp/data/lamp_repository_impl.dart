import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/lamp_state.dart';

class LampRepositoryImpl implements LampRepository {
  static const String _lampStateKey = 'lamp_state';

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
  Future<void> saveLampState(LampState state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lampStateKey, jsonEncode(state.toJson()));
  }
}
