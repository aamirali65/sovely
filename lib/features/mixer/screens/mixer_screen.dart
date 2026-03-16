import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/sound_data.dart';
import '../../../core/providers/sound_providers.dart';

class MixerScreen extends ConsumerWidget {
  const MixerScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'rain':    return Icons.water_drop_rounded;
      case 'thunder': return Icons.flash_on_rounded;
      case 'cafe':    return Icons.local_cafe_rounded;
      case 'fire':    return Icons.local_fire_department_rounded;
      case 'ocean':   return Icons.waves_rounded;
      case 'forest':  return Icons.forest_rounded;
      case 'noise':   return Icons.graphic_eq_rounded;
      case 'fan':     return Icons.air_rounded;
      case 'moon':    return Icons.nightlight_round;
      case 'river':   return Icons.water_rounded;
      case 'wind':    return Icons.tornado_rounded;
      default:        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSounds = ref.watch(activeSoundsProvider);
    final notifier = ref.read(activeSoundsProvider.notifier);
    final activeSoundModels = kSounds
        .where((s) => activeSounds.containsKey(s.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mixer',
                        style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        activeSoundModels.isEmpty
                            ? 'No sounds active'
                            : '${activeSoundModels.length} sound${activeSoundModels.length != 1 ? 's' : ''} active',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (activeSoundModels.isNotEmpty)
                    GestureDetector(
                      onTap: () => notifier.stopAll(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stop_rounded,
                                color: Colors.redAccent, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              'Stop All',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            // List
            Expanded(
              child: activeSoundModels.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 32,
                        color: AppColors.iconInactive,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing mixing yet',
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Go to Home and tap a sound',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.iconInactive,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: activeSoundModels.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sound = activeSoundModels[index];
                  final info = activeSounds[sound.id]!;
                  final isPlaying =
                      info.playState == SoundPlayState.playing;
                  final hasImage = sound.imagePath.isNotEmpty;

                  return _MixerTile(
                    sound: sound,
                    info: info,
                    isPlaying: isPlaying,
                    hasImage: hasImage,
                    icon: _getIcon(sound.iconName),
                    onPlayPause: () {
                      if (isPlaying) {
                        notifier.pauseSound(sound.id);
                      } else {
                        notifier.resumeSound(sound.id);
                      }
                    },
                    onStop: () => notifier.stopSound(sound),
                    onVolume: (v) =>
                        notifier.setVolume(sound.id, v),
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MixerTile extends StatelessWidget {
  final SoundModel sound;
  final ActiveSoundInfo info;
  final bool isPlaying;
  final bool hasImage;
  final IconData icon;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onVolume;
  final int index;

  const _MixerTile({
    required this.sound,
    required this.info,
    required this.isPlaying,
    required this.hasImage,
    required this.icon,
    required this.onPlayPause,
    required this.onStop,
    required this.onVolume,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? AppColors.cyan.withOpacity(0.3)
              : AppColors.cardBorder,
        ),
        boxShadow: isPlaying
            ? [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.07),
            blurRadius: 14,
          )
        ]
            : [],
      ),
      child: Column(
        children: [

          // Top row — image + info + controls
          Row(
            children: [

              // Image thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  bottomLeft: Radius.circular(0),
                ),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      if (hasImage)
                        Image.asset(
                          sound.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.surface),
                        )
                      else
                        Container(color: AppColors.surface),

                      // Dark overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),

                      // Icon overlay centered
                      Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? AppColors.cyan.withOpacity(0.2)
                                : Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isPlaying
                                  ? AppColors.cyan.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isPlaying
                                ? AppColors.cyan
                                : Colors.white70,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sound.category,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlaying
                                ? AppColors.cyan
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Playing' : 'Paused',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: isPlaying
                                ? AppColors.cyan
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                children: [
                  // Play / Pause
                  GestureDetector(
                    onTap: onPlayPause,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.cyan.withOpacity(0.35)),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.cyan,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Stop
                  GestureDetector(
                    onTap: onStop,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.red.withOpacity(0.25)),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),

          // Volume row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Icon(
                  Icons.volume_down_rounded,
                  color: AppColors.iconInactive,
                  size: 15,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12),
                      activeTrackColor: AppColors.cyan,
                      inactiveTrackColor:
                      AppColors.cardBorder,
                      thumbColor: Colors.white,
                      overlayColor: AppColors.cyan.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: info.volume,
                      onChanged: onVolume,
                    ),
                  ),
                ),
                Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.iconInactive,
                  size: 15,
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${(info.volume * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 80).ms)
        .slideY(begin: 0.05, end: 0);
  }
}