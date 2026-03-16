import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sovely/core/constants/sound_data.dart';
import 'package:sovely/core/providers/admob_banner.dart';
import 'package:sovely/core/providers/admob_service.dart';
import 'package:sovely/core/providers/sound_providers.dart';
import 'package:sovely/core/theme/app_colors.dart';
import 'package:sovely/features/home/widget/sound_card.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const int kFreesoundLimit = 9;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Nature', 'Urban', 'Noise'];

  final Set<String> _sessionUnlocked = {};

  List<SoundModel> get _filteredSounds {
    if (_selectedCategory == 'All') return kSounds;
    return kSounds
        .where((s) =>
    s.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  bool _isLocked(int globalIndex) =>
      globalIndex >= kFreesoundLimit &&
          !_sessionUnlocked.contains(kSounds[globalIndex].id);

  void _showRewardedToUnlock(SoundModel sound) {
    AdmobService.showRewarded(
      onRewarded: (_, __) {
        setState(() => _sessionUnlocked.add(sound.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sound.name} unlocked!'),
            backgroundColor: AppColors.cyan,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSounds = ref.watch(activeSoundsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sovely',                          // ✅ updated name
                        style: GoogleFonts.sora(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyan,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Sleep through sound',            // ✅ updated tagline
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/favourites'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.cyan.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: AppColors.cyan, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 20),

            // ── Category chips ───────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cyan
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.cyan
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.black
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            // ── Sound grid ───────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _filteredSounds.length,
                itemBuilder: (context, index) {
                  final sound = _filteredSounds[index];
                  final globalIndex = kSounds.indexOf(sound);
                  final locked = _isLocked(globalIndex);

                  return GestureDetector(
                    onTap: locked
                        ? () => _showRewardedToUnlock(sound)
                        : null,
                    child: Stack(
                      children: [
                        SoundCard(sound: sound, disabled: locked),
                        if (locked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: AppColors.cyan,
                                      size: 28),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Watch ad\nto unlock',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                      .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: (index * 60).ms);
                },
              ),
            ),

            // ── AdMob Banner ─────────────────────────────────
            const Center(child: AdmobBanner()),
            const SizedBox(height: 8),
          ],
        ),
      ),

      // ── Active sounds floating bar ───────────────────────
      floatingActionButton: activeSounds.isNotEmpty
          ? GestureDetector(
        onTap: () => context.go('/mixer'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 60),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: AppColors.cyan.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cyan.withOpacity(0.2),
                  blurRadius: 16)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EqBars(),
              const SizedBox(width: 10),
              Text(
                '${activeSounds.length} sound${activeSounds.length > 1 ? 's' : ''} playing',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.cyan, size: 18),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 1, end: 0)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _EqBars extends StatefulWidget {
  @override
  State<_EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<_EqBars> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 120),
      )..repeat(reverse: true);
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            width: 3,
            height: 8 + _controllers[i].value * 10,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: AppColors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}