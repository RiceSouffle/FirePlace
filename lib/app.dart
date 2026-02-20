import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'providers/interests_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/app_shell.dart';

class FirePlaceApp extends ConsumerWidget {
  const FirePlaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final onboardingDone = storage.isOnboardingComplete;

    return MaterialApp(
      title: 'FirePlace',
      debugShowCheckedModeBanner: false,
      theme: FirePlaceTheme.lightTheme(),
      darkTheme: FirePlaceTheme.darkTheme(),
      themeMode: ThemeMode.system, // follows device light/dark setting
      home: onboardingDone ? const AppShell() : const OnboardingScreen(),
    );
  }
}
