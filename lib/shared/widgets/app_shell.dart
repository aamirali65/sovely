// lib/shared/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:sovely/core/providers/admob_service.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/mixer'))      return 1;
    if (location.startsWith('/timer'))      return 2;
    if (location.startsWith('/favourites')) return 3;
    return 0;
  }

  void _onTabTap(BuildContext context, int index, int currentIndex) {
    if (index == currentIndex) return;

    // Navigate immediately, show interstitial in background
    switch (index) {
      case 0: context.go('/');            break;
      case 1: context.go('/mixer');       break;
      case 2: context.go('/timer');       break;
      case 3: context.go('/favourites'); break;
    }

    AdmobService.showInterstitial();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTap(context, index, currentIndex),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded),
            label: 'Mixer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),   // ← was star (Pro)
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}