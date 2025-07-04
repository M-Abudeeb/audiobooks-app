import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final Duration progress;
  final Duration total;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final Color? thumbColor;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.total,
    required this.onSeek,
    this.activeColor,
    this.thumbColor,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final double progressValue =
        widget.total.inMilliseconds > 0
            ? widget.progress.inMilliseconds / widget.total.inMilliseconds
            : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl, // Force RTL for progress bar
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor:
                  widget.activeColor ?? Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.2),
              thumbColor: widget.thumbColor ?? Colors.white,
              overlayColor: (widget.activeColor ??
                      Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2),
            ),
            child: Slider(
              value: _isDragging ? _dragValue : progressValue.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) {
                final newPosition = Duration(
                  milliseconds: (value * widget.total.inMilliseconds).round(),
                );
                widget.onSeek(newPosition);
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Legacy widget for backward compatibility
class AudioProgressBar extends StatefulWidget {
  final Duration current;
  final Duration total;
  final ValueChanged<Duration> onSeek;

  const AudioProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.onSeek,
  });

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final double progress =
        widget.total.inMilliseconds > 0
            ? widget.current.inMilliseconds / widget.total.inMilliseconds
            : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl, // Force RTL for progress bar
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.outline,
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _isDragging ? _dragValue : progress.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) {
                final newPosition = Duration(
                  milliseconds: (value * widget.total.inMilliseconds).round(),
                );
                widget.onSeek(newPosition);
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Time Labels - RTL layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(widget.total),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDuration(widget.current),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
