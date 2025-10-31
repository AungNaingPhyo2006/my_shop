import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/screens/auth/login_screen.dart';
import 'package:my_shop/bottomNavigation/main_navigator.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_shop/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final authNotifier = container.read(authProvider.notifier);

  final user = await authNotifier.tryAutoLogin();

  // Load saved locale
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'en';

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(
        isLoggedIn: user != null,
        initialLocale: Locale(localeCode),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final Locale initialLocale;

  const MyApp({super.key, required this.isLoggedIn, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    // initialize the global notifier so other parts can update it
    appLocale.value = _locale;
  }

  // Change locale dynamically
  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);

    setState(() {
      _locale = locale;
      appLocale.value = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, localeValue, _) {
        return MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          locale: localeValue,
          supportedLocales: const [
            Locale('en'),
            Locale('my'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: widget.isLoggedIn ? const MainNavigator() : const LoginScreen(),
        );
      },
    );
  }
}
