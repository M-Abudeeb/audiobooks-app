import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/audiobook_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AudioBooksApp());
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Check if running on web
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C2C2C), // Dark background for web
        body: Center(
          child: Container(
            width: 393, // iPhone 14/15 width
            height: 852, // iPhone 14/15 height
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // App background color
              borderRadius: BorderRadius.circular(
                30,
              ), // iPhone-like rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      );
    }

    // Return child as-is for mobile platforms
    return child;
  }
}

class AudioBooksApp extends StatelessWidget {
  const AudioBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioBookProvider(),
      child: MaterialApp(
        title: 'انصت',
        debugShowCheckedModeBanner: false,

        // Localization support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'), // Arabic
          Locale('en', 'US'), // English fallback
        ],
        locale: const Locale('ar', 'SA'),

        // Professional theme based on design system
        theme: _buildAppTheme(),

        home: const ResponsiveWrapper(child: HomeScreen()),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    // Design System Colors
    const Color primaryGold = Color(0xFFD0B05B);
    const Color primaryLightGold = Color(0xFFE6C779);
    const Color primaryDarkGold = Color(0xFFB8954A);
    const Color secondaryDark = Color(0xFF2C2C2C);
    const Color backgroundWhite = Color(0xFFF5F5F5);
    const Color surfaceLight = Color(0xFFF8F9FA);
    const Color surfaceVariant = Color(0xFFF5F5F5);
    const Color textPrimary = Color(0xFF1A1A1A);
    const Color textSecondary = Color(0xFF666666);
    const Color textTertiary = Color(0xFF999999);
    const Color dividerColor = Color(0xFFE0E0E0);

    // Color scheme based on design system
    const ColorScheme colorScheme = ColorScheme.light(
      primary: primaryGold,
      secondary: secondaryDark,
      surface: surfaceLight,
      surfaceContainerHighest: surfaceVariant,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      outline: dividerColor,
      outlineVariant: textTertiary,
    );

    // Arabic typography using Lalezar font
    final TextTheme textTheme = GoogleFonts.lalezarTextTheme().copyWith(
      // Display styles
      displayLarge: GoogleFonts.lalezar(
        fontSize: 32,
        fontWeight: FontWeight.w200,
        height: 1.2,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.lalezar(
        fontSize: 28,
        fontWeight: FontWeight.w200,
        height: 1.3,
        letterSpacing: -0.25,
        color: textPrimary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.lalezar(
        fontSize: 24,
        fontWeight: FontWeight.w200,
        height: 1.3,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.lalezar(
        fontSize: 20,
        fontWeight: FontWeight.w200,
        height: 1.4,
        color: textPrimary,
      ),

      // Title styles
      titleLarge: GoogleFonts.lalezar(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        height: 1.4,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.lalezar(
        fontSize: 16,
        fontWeight: FontWeight.w200,
        height: 1.5,
        letterSpacing: 0.1,
        color: textPrimary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.lalezar(
        fontSize: 16,
        fontWeight: FontWeight.w200,
        height: 1.6,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.lalezar(
        fontSize: 14,
        fontWeight: FontWeight.w200,
        height: 1.6,
        letterSpacing: 0.25,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.lalezar(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        height: 1.5,
        letterSpacing: 0.4,
        color: textSecondary,
      ),

      // Label styles
      labelLarge: GoogleFonts.lalezar(
        fontSize: 14,
        fontWeight: FontWeight.w200,
        height: 1.4,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.lalezar(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        height: 1.3,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryGold,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(color: primaryGold),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
        elevation: 6,
        iconSize: 24,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textTertiary),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryGold,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGold,
        inactiveTrackColor: dividerColor,
        thumbColor: primaryGold,
        overlayColor: primaryGold.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 8,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 16,
      ),
    );
  }
}
