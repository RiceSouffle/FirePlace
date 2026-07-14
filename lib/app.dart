import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design/ember_theme.dart';
import 'providers/interests_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/app_shell.dart';
import 'widgets/hearth.dart';

class FirePlaceApp extends ConsumerWidget {
  const FirePlaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final onboardingDone = storage.isOnboardingComplete;

    return MaterialApp(
      title: 'FirePlace',
      debugShowCheckedModeBanner: false,
      theme: EmberTheme.light(),
      darkTheme: EmberTheme.dark(),
      themeMode: ThemeMode.system, // follows device light/dark setting
      // One shared "hearth clock" lives above every route so the living-ember
      // surfaces all breathe on the same 6s cadence.
      builder: (context, child) {
        final overlay = Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: HearthTicker(child: child ?? const SizedBox.shrink()),
        );
      },
      home: onboardingDone ? const AppShell() : const OnboardingScreen(),
    );
  }
}
