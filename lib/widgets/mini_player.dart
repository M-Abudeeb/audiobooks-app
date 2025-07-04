import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audiobook_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioBookProvider>(
      builder: (context, provider, child) {
        // Only show mini player if there's a current book
        if (provider.currentBook == null) {
          return const SizedBox.shrink();
        }

        final book = provider.currentBook!;
        final progress = provider.currentPosition;
        final duration = provider.totalDuration;
        final isPlaying = provider.isPlaying;

        return Container(
          width: double.infinity,
          height: double.infinity,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1B09), // Dark brown/black color
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(book: book),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Play/Pause Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            provider.pause();
                          } else {
                            provider.resume();
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Forward 10 seconds button
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(17.5),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          final newPosition =
                              progress + const Duration(seconds: 10);
                          if (newPosition <= duration) {
                            provider.seekTo(newPosition);
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Book info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimeRemaining(duration - progress),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Book cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          book.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return '0:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '-$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '-$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
