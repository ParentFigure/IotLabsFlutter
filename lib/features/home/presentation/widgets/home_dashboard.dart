import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/home/presentation/helpers/schedule_utils.dart';
import 'package:src/features/home/presentation/widgets/home_dashboard_sections.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final lamp = context.watch<LampController>();
    final auth = context.watch<AuthController>();
    final state = lamp.state;
    final bool isOnline = context.watch<NetworkController>().isOnline;
    final bool isWide = MediaQuery.sizeOf(context).width >= 760;
    final List<ScheduleEntry> schedules = sortSchedules(state.schedules);
    final String sensorLabel = state.sensorLux < state.sensitivity
        ? 'Dark'
        : 'Bright';

    final Widget status = StatusSection(sensorLabel: sensorLabel);
    final Widget schedule = ScheduleSection(
      schedules: schedules,
      isOnline: isOnline,
      email: auth.state.currentUser?.email,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: status),
          const SizedBox(width: 24),
          Expanded(child: schedule),
        ],
      );
    }

    return Column(
      children: <Widget>[status, const SizedBox(height: 24), schedule],
    );
  }
}
