import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/core/theme/app_theme.dart';
import 'package:src/features/auth/presentation/auth_gate_page.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/auth/presentation/register_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/features/lamp/data/lamp_repository_impl.dart';
import 'package:src/features/lamp/data/mqtt_service_impl.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkController>(
          create: (BuildContext context) => NetworkController()..initialize(),
        ),
        ChangeNotifierProxyProvider<NetworkController, LampController>(
          create: (BuildContext context) => LampController(
            lampRepository: LampRepositoryImpl(),
            mqttService: MqttServiceImpl(),
            networkController: context.read<NetworkController>(),
          ),
          update:
              (
                BuildContext context,
                NetworkController networkController,
                LampController? previous,
              ) =>
                  previous ??
                  LampController(
                    lampRepository: LampRepositoryImpl(),
                    mqttService: MqttServiceImpl(),
                    networkController: networkController,
                  ),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Lamp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AuthGatePage.routeName,
        routes: <String, WidgetBuilder>{
          AuthGatePage.routeName: (BuildContext context) =>
              const AuthGatePage(),
          LoginPage.routeName: (BuildContext context) => const LoginPage(),
          RegisterPage.routeName: (BuildContext context) =>
              const RegisterPage(),
          HomePage.routeName: (BuildContext context) => const HomePage(),
          ProfilePage.routeName: (BuildContext context) => const ProfilePage(),
        },
      ),
    );
  }
}
