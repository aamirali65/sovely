import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovely/features/favourite/favourite.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/mixer/screens/mixer_screen.dart';
import 'features/timer/timer_screen.dart';
import 'shared/widgets/app_shell.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/',       builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/mixer',  builder: (_, __) => const MixerScreen()),
        GoRoute(path: '/timer',  builder: (_, __) => const TimerScreen()),
        GoRoute(path: '/favourites',    builder: (_, __) => const FavouritesScreen()),
      ],
    ),
  ],
);

class FocusNoiseApp extends ConsumerWidget {
  const FocusNoiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Focus Noise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}