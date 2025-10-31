import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/screens/auth/login_screen.dart';
import 'package:my_shop/bottomNavigation/main_navigator.dart';
import 'package:my_shop/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create ProviderContainer so we can access providers before runApp
  final container = ProviderContainer();
  final authNotifier = container.read(authProvider.notifier);

  // Try auto login (restore user if saved)
  final user = await authNotifier.tryAutoLogin();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(isLoggedIn: user != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainNavigator() : const LoginScreen(),
    );
  }
}
