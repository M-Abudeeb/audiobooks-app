import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import '../providers/audiobook_provider.dart';
import '../models/audiobook.dart';
import '../widgets/progress_bar.dart';

class PlayerScreen extends StatefulWidget {
  final AudioBook book;

  const PlayerScreen({super.key, required this.book});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _coverAnimationController;
  late AnimationController _controlsAnimationController;
  late AnimationController _volumeAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _coverAnimation;
  late Animation<double> _controlsAnimation;
  late Animation<double> _volumeAnimation;
  late Animation<double> _buttonScaleAnimation;

  final bool _showInfo = false;

  // Dynamic color state - Apple Podcasts style
  Color _primaryColor = const Color(
    0xFF6B7B8A,
  ); // Default blue-grey instead of golden
  Color _secondaryColor = const Color(0xFF4A5562); // Default dark blue-grey
  Color _accentColor = const Color(0xFF8B9BAD); // Default light blue-grey
  bool _colorsExtracted = false;

  @override
  void initState() {
    super.initState();

    // Animation controllers with different durations for staggered effects
    _coverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _volumeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Enhanced animations with different curves
    _coverAnimation = CurvedAnimation(
      parent: _coverAnimationController,
      curve: Curves.elasticOut,
    );

    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOutCubic,
    );

    _volumeAnimation = CurvedAnimation(
      parent: _volumeAnimationController,
      curve: Curves.bounceOut,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Staggered animation sequence
    _startAnimationSequence();

    // Extract colors from cover image - Apple Podcasts style
    _extractColorsFromImage();

    // Start playing the book
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AudioBookProvider>(context, listen: false);
      provider.playBookImmediately(widget.book);
    });
  }

  void _startAnimationSequence() async {
    // Staggered entrance animations
    await Future.delayed(const Duration(milliseconds: 200));
    _coverAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _controlsAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _volumeAnimationController.forward();
  }

  Future<void> _extractColorsFromImage() async {
    try {
      final ImageProvider imageProvider = AssetImage(widget.book.imagePath);
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
            imageProvider,
            size: const Size(200, 200),
            maximumColorCount: 32, // Increased for better color extraction
          );

      if (mounted) {
        setState(() {
          // Get all available colors for better selection
          Color? dominant = paletteGenerator.dominantColor?.color;
          Color? vibrant = paletteGenerator.vibrantColor?.color;
          Color? muted = paletteGenerator.mutedColor?.color;
          Color? darkVibrant = paletteGenerator.darkVibrantColor?.color;
          Color? lightVibrant = paletteGenerator.lightVibrantColor?.color;
          Color? darkMuted = paletteGenerator.darkMutedColor?.color;
          Color? lightMuted = paletteGenerator.lightMutedColor?.color;

          // Extract colors for theme

          // Prioritize muted and dark colors for better backgrounds
          // Avoid overly saturated yellows/oranges - use blue-grey fallbacks
          Color selectedPrimary = const Color(0xFF6B7B8A);
          Color selectedSecondary = const Color(0xFF4A5562);
          Color selectedAccent = const Color(0xFF8B9BAD);

          // Choose primary color - prefer muted or dark colors
          if (darkVibrant != null && !_isUndesirableColor(darkVibrant)) {
            selectedPrimary = darkVibrant;
          } else if (muted != null && !_isUndesirableColor(muted)) {
            selectedPrimary = muted;
          } else if (darkMuted != null && !_isUndesirableColor(darkMuted)) {
            selectedPrimary = darkMuted;
          } else if (dominant != null && !_isUndesirableColor(dominant)) {
            selectedPrimary = dominant;
          }

          // Choose secondary color - should be darker than primary
          if (darkMuted != null && !_isUndesirableColor(darkMuted)) {
            selectedSecondary = darkMuted;
          } else if (darkVibrant != null && !_isUndesirableColor(darkVibrant)) {
            selectedSecondary = darkVibrant;
          } else {
            selectedSecondary = _darkenColor(selectedPrimary, 0.3);
          }

          // Choose accent color - can be lighter or more vibrant
          if (lightMuted != null && !_isUndesirableColor(lightMuted)) {
            selectedAccent = lightMuted;
          } else if (vibrant != null && !_isUndesirableColor(vibrant)) {
            selectedAccent = vibrant;
          } else {
            selectedAccent = _lightenColor(selectedPrimary, 0.2);
          }

          _primaryColor = selectedPrimary;
          _secondaryColor = selectedSecondary;
          _accentColor = selectedAccent;

          // Colors successfully extracted

          // Always mark as extracted to avoid theme color fallbacks
          _colorsExtracted = true;
        });
      }
    } catch (e) {
      // Use fallback colors if extraction fails
      if (mounted) {
        setState(() {
          _primaryColor = const Color(0xFF6B7B8A);
          _secondaryColor = const Color(0xFF4A5562);
          _accentColor = const Color(0xFF8B9BAD);
          _colorsExtracted = true;
        });
      }
    }
  }

  bool _isUndesirableColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    // Be more aggressive about avoiding yellows and oranges
    // Completely avoid yellow range (30-90 degrees) if saturated
    if (saturation > 0.4 && hue >= 30 && hue <= 90) {
      return true; // Avoid all yellows and yellow-oranges
    }

    // Also avoid pure oranges and warm colors
    if (saturation > 0.5 && hue >= 10 && hue <= 40) {
      return true; // Avoid oranges
    }

    // Avoid very light colors that won't work well as backgrounds
    if (lightness > 0.85) {
      return true;
    }

    // Avoid very saturated colors that might be too bright
    if (saturation > 0.8 && lightness > 0.6) {
      return true;
    }

    return false;
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  @override
  void dispose() {
    _coverAnimationController.dispose();
    _controlsAnimationController.dispose();
    _volumeAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _secondaryColor,
        body: Stack(
          children: [
            // Apple Podcasts style background gradient
            _buildAppleStyleBackground(),

            // Main content with proper spacing per specification
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Top bar
                    _buildTopBar(),

                    // Main content with proper spacing
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 24,
                              ), // section_vertical spacing
                              // 3D Isometric artwork section
                              _buildArtworkSection(),

                              const SizedBox(
                                height: 24,
                              ), // section_vertical spacing
                              // Info section (date, title, subtitle)
                              _buildInfoSection(),

                              const SizedBox(
                                height: 24,
                              ), // section_vertical spacing
                              // Progress section
                              _buildProgressSection(),

                              const SizedBox(
                                height: 24,
                              ), // section_vertical spacing
                              // Control buttons (as per JSON spec)
                              _buildControlButtonsSection(),

                              const SizedBox(
                                height: 24,
                              ), // section_vertical spacing
                              // Volume control section
                              _buildVolumeControlSection(),
                            ],
                          ),

                          // Bottom navigation space
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleStyleBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _primaryColor,
            _primaryColor.withOpacity(0.95),
            _secondaryColor,
            _secondaryColor.withOpacity(0.98),
            _darkenColor(_secondaryColor, 0.1),
          ],
          stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: [
              _accentColor.withOpacity(0.3),
              Colors.transparent,
              _secondaryColor.withOpacity(0.2),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button - Apple Podcasts style
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              iconSize: 20,
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Title - white text for Apple Podcasts style
          Text(
            'مشغل الصوت',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Menu button - Apple Podcasts style
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              iconSize: 20,
              color: Colors.white,
              onPressed: () => _showOptionsBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkSection() {
    return AnimatedBuilder(
      animation: _coverAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _coverAnimation.value)),
          child: Opacity(
            opacity: _coverAnimation.value.clamp(0.0, 1.0),
            child: Consumer<AudioBookProvider>(
              builder: (context, provider, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 1.0,
                    end: provider.isPlaying ? 1.02 : 1.0,
                  ),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _colorsExtracted
                                      ? _primaryColor.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            widget.book.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'غلاف غير متوفر',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Date section (small caps style)
                Text(
                  '${DateTime.now().day.toString().padLeft(2, '0')} ${_getMonthName(DateTime.now().month).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8), // element_vertical spacing
                // Title (large bold style)
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8), // element_vertical spacing
                // Subtitle (medium muted style)
                Text(
                  widget.book.author,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value.clamp(0.0, 1.0),
            child: Consumer<AudioBookProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // Custom progress bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ProgressBar(
                        progress: provider.currentPosition,
                        total: provider.totalDuration,
                        onSeek: (position) {
                          provider.seekTo(position);
                        },
                        activeColor: _colorsExtracted ? _accentColor : null,
                        thumbColor: _colorsExtracted ? _accentColor : null,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time labels - RTL layout with Apple Podcasts style
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Directionality(
                        textDirection:
                            TextDirection.ltr, // Force LTR for time labels
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT SIDE: Total Duration (e.g., 04:15:50)
                            Text(
                              _formatDuration(provider.totalDuration),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // RIGHT SIDE: Current Position (e.g., 00:02)
                            Text(
                              _formatDuration(provider.currentPosition),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtonsSection() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _controlsAnimation.value)),
          child: Opacity(
            opacity: _controlsAnimation.value.clamp(0.0, 1.0),
            child: Consumer<AudioBookProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Speed control (44x44 as per spec)
                      _buildSpeedButton(),

                      // Rewind 10 seconds (48x48 as per spec)
                      _buildRewindButton(),

                      // Play/Pause button (60x60 as per spec)
                      _buildPlayPauseButton(provider),

                      // Fast forward 10 seconds (48x48 as per spec)
                      _buildFastForwardButton(),

                      // Sleep timer (44x44 as per spec)
                      _buildSleepTimerButton(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeControlSection() {
    return AnimatedBuilder(
      animation: _volumeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _volumeAnimation.value)),
          child: Opacity(
            opacity: _volumeAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<AudioBookProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      Icon(
                        _getVolumeIcon(provider.volume, false),
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: Colors.white.withOpacity(0.8),
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: provider.volume,
                            onChanged: (value) {
                              provider.setVolume(value);
                            },
                          ),
                        ),
                      ),
                      Icon(
                        _getVolumeIcon(provider.volume, true),
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _buttonAnimationController.forward(),
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: () => _showSpeedBottomSheet(),
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.speed, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewindButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _buttonAnimationController.forward(),
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: () {
            HapticFeedback.lightImpact();
            final provider = Provider.of<AudioBookProvider>(
              context,
              listen: false,
            );
            final newPosition =
                provider.currentPosition - const Duration(seconds: 10);
            provider.seekTo(
              newPosition.isNegative ? Duration.zero : newPosition,
            );
          },
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayPauseButton(AudioBookProvider provider) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            _buttonAnimationController.forward();
            HapticFeedback.mediumImpact();
          },
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: () {
            if (provider.isPlaying) {
              provider.pause();
            } else {
              provider.resume();
            }
          },
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: provider.isPlaying ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child:
                    provider.isLoading
                        ? TweenAnimationBuilder<double>(
                          key: const ValueKey('loading'),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle:
                                  value * 2 * 3.14159, // 2π for full rotation
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : Icon(
                          provider.isPlaying ? Icons.pause : Icons.play_arrow,
                          key: ValueKey(provider.isPlaying),
                          color: Colors.white,
                          size: 36,
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFastForwardButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _buttonAnimationController.forward(),
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: () {
            HapticFeedback.lightImpact();
            final provider = Provider.of<AudioBookProvider>(
              context,
              listen: false,
            );
            final newPosition =
                provider.currentPosition + const Duration(seconds: 10);
            final maxPosition = provider.totalDuration;
            provider.seekTo(
              newPosition > maxPosition ? maxPosition : newPosition,
            );
          },
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.replay_10, color: Colors.white, size: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepTimerButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _buttonAnimationController.forward(),
          onTapUp: (_) => _buttonAnimationController.reverse(),
          onTapCancel: () => _buttonAnimationController.reverse(),
          onTap: () {
            HapticFeedback.lightImpact();
            _showTimerBottomSheet();
          },
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.timer, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
  }

  void _showTimerBottomSheetAnimated() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated handle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, handleValue, child) {
                          return Transform.scale(
                            scale: handleValue,
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.outline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Animated title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, titleValue, child) {
                          return Opacity(
                            opacity: titleValue.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - titleValue)),
                              child: Text(
                                'مؤقت الإيقاف',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Timer options (animation removed)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            [5, 15, 30, 45, 60].map((minutes) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  HapticFeedback.selectionClick();
                                  _showSnackBar(
                                    'سيتم إيقاف التشغيل خلال $minutes دقيقة',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$minutes دقيقة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showSpeedBottomSheetAnimated() {
    HapticFeedback.lightImpact(); // Add haptic feedback
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
      builder:
          (context) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: _buildSpeedBottomSheetContent(),
                ),
              );
            },
          ),
    );
  }

  Widget _buildSpeedBottomSheetContent() {
    return Consumer<AudioBookProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated handle
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Animated title
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Text(
                        'سرعة التشغيل',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Speed options (animation removed)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                      final isSelected = provider.playbackSpeed == speed;
                      return GestureDetector(
                        onTap: () {
                          provider.setPlaybackSpeed(speed);
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Text(
                            '${speed}x',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Consumer<AudioBookProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'سرعة التشغيل',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                            final isSelected = provider.playbackSpeed == speed;
                            return GestureDetector(
                              onTap: () {
                                provider.setPlaybackSpeed(speed);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${speed}x',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showTimerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'مؤقت الإيقاف',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      [5, 15, 30, 45, 60].map((minutes) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showSnackBar(
                              'سيتم إيقاف التشغيل خلال $minutes دقيقة',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$minutes دقيقة',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'خيارات إضافية',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 24),

                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('معلومات الكتاب'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show book info
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('تحميل للاستماع بدون انترنت'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('التحميل قيد التطوير');
                  },
                ),

                Consumer<AudioBookProvider>(
                  builder: (context, provider, child) {
                    return ListTile(
                      leading: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('إعادة تعيين التقدم'),
                      onTap: () {
                        Navigator.pop(context);
                        provider.resetBookProgress(widget.book.id);
                        _showSnackBar('تم إعادة تعيين التقدم');
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            _colorsExtracted
                ? _primaryColor
                : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(milliseconds: 2000),
        animation: CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 400),
            vsync: this,
          )..forward(),
          curve: Curves.elasticOut,
        ),
      ),
    );

    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  // Helper method for month names
  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  // Helper method for volume icon based on volume level
  IconData _getVolumeIcon(double volume, bool isHigh) {
    if (volume == 0.0) {
      return Icons.volume_off_rounded;
    } else if (volume < 0.3) {
      return isHigh ? Icons.volume_down_rounded : Icons.volume_mute_rounded;
    } else if (volume < 0.7) {
      return Icons.volume_down_rounded;
    } else {
      return Icons.volume_up_rounded;
    }
  }
}
