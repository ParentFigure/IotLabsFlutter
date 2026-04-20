import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/core/theme/app_theme.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/presentation/auth_gate_page.dart';
import 'package:src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:src/features/auth/presentation/login_page.dart';
import 'package:src/features/auth/presentation/register_page.dart';
import 'package:src/features/home/presentation/home_page.dart';
import 'package:src/features/lamp/data/lamp_repository_impl.dart';
import 'package:src/features/lamp/data/mqtt_service_impl.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/mqtt_service.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';
import 'package:src/shared/network/api_client.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<AuthRepository>(
          create: (BuildContext context) =>
              AuthRepositoryImpl(client: context.read<ApiClient>()),
        ),
        Provider<LampRepository>(
          create: (BuildContext context) =>
              LampRepositoryImpl(client: context.read<ApiClient>()),
        ),
        Provider<MqttService>(create: (_) => MqttServiceImpl()),
        ChangeNotifierProvider<NetworkController>(
          create: (_) => NetworkController()..initialize(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (BuildContext context) =>
              AuthController(authRepository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProxyProvider3<
          LampRepository,
          MqttService,
          NetworkController,
          LampController
        >(
          create: (BuildContext context) => LampController(
            lampRepository: context.read<LampRepository>(),
            mqttService: context.read<MqttService>(),
            networkController: context.read<NetworkController>(),
          ),
          update:
              (_, lampRepository, mqttService, networkController, controller) =>
                  controller ??
                  LampController(
                    lampRepository: lampRepository,
                    mqttService: mqttService,
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
          AuthGatePage.routeName: (_) => const AuthGatePage(),
          LoginPage.routeName: (_) => const LoginPage(),
          RegisterPage.routeName: (_) => const RegisterPage(),
          HomePage.routeName: (_) => const HomePage(),
          ProfilePage.routeName: (_) => const ProfilePage(),
        },
      ),
    );
  }
}
