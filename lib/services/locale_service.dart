import 'package:flutter/widgets.dart';

/// Global app locale notifier. Update `appLocale.value = Locale('my')` to change
/// the application's locale at runtime.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
