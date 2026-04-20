import 'package:src/features/lamp/domain/lamp_state.dart';

abstract class LampRepository {
  Future<LampState> getLampState();
  Future<LampState> syncLampState();
  Future<void> saveLampState(LampState state);
}
