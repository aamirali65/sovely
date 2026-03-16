// lib/core/providers/favourites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesNotifier extends StateNotifier<Set<String>> {
  FavouritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'favourite_sounds';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    state = saved.toSet();
  }

  Future<void> toggle(String soundId) async {
    final updated = {...state};
    if (updated.contains(soundId)) {
      updated.remove(soundId);
    } else {
      updated.add(soundId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.toList());
  }

  bool isFavourite(String soundId) => state.contains(soundId);
}

final favouritesProvider =
StateNotifierProvider<FavouritesNotifier, Set<String>>(
      (ref) => FavouritesNotifier(),
);