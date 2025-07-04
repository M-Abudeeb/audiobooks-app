import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRewind;
  final VoidCallback onFastForward;
  final Color? primaryColor; // Custom primary color
  final Color? accentColor; // Custom accent color

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onRewind,
    required this.onFastForward,
    this.primaryColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Main control row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous chapter
              _buildControlButton(
                context: context,
                icon: Icons.skip_previous_rounded,
                size: 32,
                onPressed: onPrevious,
                isSecondary: true,
              ),

              // Rewind 10 seconds
              _buildRewindButton(context),

              // Play/Pause button (main)
              _buildPlayPauseButton(context),

              // Fast forward 10 seconds
              _buildFastForwardButton(context),

              // Next chapter
              _buildControlButton(
                context: context,
                icon: Icons.skip_next_rounded,
                size: 32,
                onPressed: onNext,
                isSecondary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    final effectivePrimaryColor =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color:
            isSecondary
                ? Colors.white.withOpacity(0.2)
                : effectivePrimaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size, color: Colors.white),
        splashRadius: 28,
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context) {
    return Container(
      width: 44, // As per JSON spec: tab_buttons: "44x44"
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: const Center(
        child: Text(
          '1×',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRewindButton(BuildContext context) {
    return GestureDetector(
      onTap: onRewind,
      child: Container(
        width: 48, // As per JSON spec: secondary_buttons: "48x48"
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.replay_10, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFastForwardButton(BuildContext context) {
    return GestureDetector(
      onTap: onFastForward,
      child: Container(
        width: 48, // As per JSON spec: secondary_buttons: "48x48"
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.forward_10, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context) {
    final effectivePrimaryColor =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: 60, // As per JSON spec: primary_play_button: "60x60"
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPlayPause,
        icon:
            isLoading
                ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      effectivePrimaryColor,
                    ),
                  ),
                )
                : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 30, // Adjusted for 60x60 button
                  color: effectivePrimaryColor,
                ),
        splashRadius: 30,
      ),
    );
  }

  Widget _buildSleepTimerButton(BuildContext context) {
    return Container(
      width: 44, // As per JSON spec: tab_buttons: "44x44"
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: const Icon(Icons.bedtime_outlined, color: Colors.white, size: 24),
    );
  }
}
