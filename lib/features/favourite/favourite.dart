// lib/features/favourites/screens/favourites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sovely/core/constants/sound_data.dart';
import 'package:sovely/core/providers/favourites_provider.dart';
import 'package:sovely/core/theme/app_colors.dart';
import 'package:sovely/features/home/widget/sound_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sovely/core/providers/admob_banner.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favouritesProvider);
    final favSounds =
    kSounds.where((s) => favIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Favourites',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                  letterSpacing: -0.5,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            if (favSounds.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded,
                          color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No favourites yet',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Long-press any sound to save it',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: favSounds.length,
                  itemBuilder: (context, index) {
                    return SoundCard(sound: favSounds[index])
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                        .slideY(begin: 0.2, end: 0, delay: (index * 60).ms);
                  },
                  ),
                ),
              // ── AdMob Banner ────────────────────────────
              const Center(child: AdmobBanner()),
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
}
}