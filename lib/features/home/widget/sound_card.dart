import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/sound_data.dart';
import '../../../core/providers/sound_providers.dart';
import '../../../core/providers/favourites_provider.dart';

class SoundCard extends ConsumerStatefulWidget {
  final SoundModel sound;
  final bool disabled; // true = locked by rewarded ad gate
  const SoundCard({super.key, required this.sound, this.disabled = false});

  @override
  ConsumerState<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends ConsumerState<SoundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final activeSounds = ref.watch(activeSoundsProvider);
    final favourites  = ref.watch(favouritesProvider);
    final isActive    = activeSounds.containsKey(widget.sound.id);
    final isFav       = favourites.contains(widget.sound.id);
    final volume      = activeSounds[widget.sound.id]?.volume ?? 0.7;
    final hasImage    = widget.sound.imagePath.isNotEmpty;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap: widget.disabled
          ? null // HomeScreen's GestureDetector handles locked tap
          : () => ref.read(activeSoundsProvider.notifier).toggleSound(widget.sound),
      onLongPress: widget.disabled
          ? null
          : () {
        ref.read(favouritesProvider.notifier).toggle(widget.sound.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav
                  ? '${widget.sound.name} removed from favourites'
                  : '${widget.sound.name} added to favourites',
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.cyan,
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? AppColors.cyan.withOpacity(
                      0.5 + _pulseController.value * 0.3)
                      : Colors.white.withOpacity(0.06),
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: AppColors.cyan.withOpacity(
                        0.1 + _pulseController.value * 0.12),
                    blurRadius: 12 + _pulseController.value * 6,
                    spreadRadius: 0,
                  )
                ]
                    : [],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [

                // ── Background ──
                if (hasImage)
                  Image.asset(
                    widget.sound.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.surface),
                  )
                else
                  Container(color: AppColors.surface),

                // ── Gradient overlay ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isActive
                          ? [
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.70),
                      ]
                          : [
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),

                // ── Cyan tint pulse when active ──
                if (isActive)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      color: AppColors.cyan.withOpacity(
                          0.04 + _pulseController.value * 0.06),
                    ),
                  ),

                // ── Main content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 10, 7, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.cyan.withOpacity(0.22)
                              : Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? AppColors.cyan.withOpacity(0.55)
                                : Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getIcon(widget.sound.iconName),
                          color: isActive
                              ? AppColors.cyan
                              : Colors.white.withOpacity(0.85),
                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.sound.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      if (isActive) ...[
                        const SizedBox(height: 3),
                        _MiniVolumeSlider(
                          volume: volume,
                          soundId: widget.sound.id,
                        ),
                      ] else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),

                // ── Active dot ──
                if (isActive)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(
                              0.7 + _pulseController.value * 0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.6),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Favourite heart badge ──
                if (isFav && !widget.disabled)
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppColors.cyan,
                      size: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniVolumeSlider extends ConsumerStatefulWidget {
  final double volume;
  final String soundId;
  const _MiniVolumeSlider({required this.volume, required this.soundId});

  @override
  ConsumerState<_MiniVolumeSlider> createState() =>
      _MiniVolumeSliderState();
}

class _MiniVolumeSliderState extends ConsumerState<_MiniVolumeSlider> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          activeTrackColor: AppColors.cyan,
          inactiveTrackColor: Colors.white.withOpacity(0.2),
          thumbColor: Colors.white,
          overlayColor: AppColors.cyan.withOpacity(0.2),
        ),
        child: Slider(
          value: widget.volume,
          onChanged: (v) => ref
              .read(activeSoundsProvider.notifier)
              .setVolume(widget.soundId, v),
        ),
      ),
    );
  }
}