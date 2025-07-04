# Audiobooks App - انصت

A professional Flutter audiobooks application with secure client sharing capabilities.

## 📱 App Overview

**تطبيق الكتب الصوتية - انصت** is a cross-platform audiobooks application built with Flutter, featuring:

- 📚 Multiple audiobook support
- 🎵 High-quality audio playback
- 🎨 Modern Arabic UI design
- 📱 Cross-platform (iOS, Android, Web, Desktop)
- 🔒 Secure client sharing options

## 🚀 Professional Client Sharing Options

### Option 1: Private Git Repository (Recommended)
```bash
# Clone the repository
git clone [PRIVATE_REPO_URL]
cd audiobooks_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Option 2: Secure File Sharing
- **Google Drive/OneDrive**: Password-protected folder
- **Dropbox**: Team folder with access controls
- **WeTransfer Pro**: Secure file transfer with expiration

### Option 3: Private App Distribution
- **TestFlight** (iOS): Apple's official beta testing platform
- **Google Play Console** (Android): Internal testing track
- **Firebase App Distribution**: Secure beta distribution

## 🔐 Security Features

### Code Security
- ✅ No hardcoded API keys
- ✅ Environment-based configuration
- ✅ Secure asset handling
- ✅ Privacy-focused design

### Data Protection
- ✅ Local audio file storage
- ✅ No external data collection
- ✅ Offline functionality
- ✅ Secure file access

## 📦 Build Instructions

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK
- Android Studio / Xcode (for mobile builds)
- VS Code (recommended)

### Setup
```bash
# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Run on device/emulator
flutter run
```

### Build for Distribution
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## 📁 Project Structure

```
audiobooks_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── providers/             # State management
│   ├── screens/               # UI screens
│   ├── utils/                 # Utilities
│   └── widgets/               # Reusable widgets
├── assets/
│   ├── audio/                 # Audio files
│   ├── images/                # Book covers
│   └── icon/                  # App icons
└── platform-specific/         # Native configurations
```

## 🎯 Features

### Core Functionality
- 📖 Audiobook library management
- 🎵 Advanced audio player with controls
- 📱 Responsive design for all screen sizes
- 🌙 Dark/Light theme support
- 🔄 Background audio playback
- 📊 Progress tracking and bookmarks

### Technical Features
- 🏗️ Provider state management
- 🎨 Material Design 3
- 📱 Platform-specific optimizations
- 🔧 Modular architecture
- 🧪 Comprehensive testing support

## 🔧 Configuration

### Environment Setup
Create a `.env` file for sensitive configuration:
```env
# Add any API keys or configuration here
# This file should not be committed to version control
```

### Platform-Specific Settings
- **Android**: Minimum SDK 21, target SDK 34
- **iOS**: Deployment target 12.0+
- **Web**: Modern browser support
- **Desktop**: Windows 10+, macOS 10.14+

## 📋 Client Delivery Checklist

### Before Sharing
- [ ] Remove any development/debug code
- [ ] Update version numbers
- [ ] Test on all target platforms
- [ ] Verify audio files are included
- [ ] Check app icons are generated
- [ ] Review security settings

### Delivery Package
- [ ] Source code (private repository)
- [ ] Built applications (APK, IPA, etc.)
- [ ] Documentation (this README)
- [ ] License information
- [ ] Contact information
- [ ] Support documentation

## 📞 Support & Maintenance

### Contact Information
- **Developer**: [Your Name]
- **Email**: [Your Email]
- **Phone**: [Your Phone]

### Maintenance Schedule
- Regular updates for Flutter SDK
- Security patches as needed
- Feature updates based on client feedback

## 📄 License

This project is proprietary software. All rights reserved.

---

**Version**: 1.0.0  
**Last Updated**: [Current Date]  
**Flutter Version**: 3.7.2+  
**Dart Version**: 3.0.0+

## Audio Files Setup

The app expects audio files in the `assets/audio/` directory. Make sure to:

1. Create the `assets/audio/` directory if it doesn't exist
2. Add your `.mp3` audio files
3. Update the `pubspec.yaml` if you add new audio files
4. Run `flutter pub get` after adding new assets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
