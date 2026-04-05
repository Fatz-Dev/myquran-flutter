import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        if (!audio.hasAudio) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
        final primary = Theme.of(context).colorScheme.primary;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  activeTrackColor: primary,
                  inactiveTrackColor: primary.withOpacity(0.2),
                  thumbColor: primary,
                  overlayColor: primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: audio.progress.clamp(0.0, 1.0),
                  onChanged: (v) => audio.seekTo(v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio.currentTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            audio.currentSubtitle,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (audio.isLoading)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: primary),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          audio.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: primary,
                        ),
                        onPressed: () {
                          if (audio.isPlaying) {
                            audio.pause();
                          } else {
                            audio.resume();
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => audio.stop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
