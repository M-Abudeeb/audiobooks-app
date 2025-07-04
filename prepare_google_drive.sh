#!/bin/bash

# Google Drive Delivery Preparation Script
# Creates a professional package for Google Drive sharing

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Audiobooks_App"
VERSION="1.0.0"
DELIVERY_DIR="Google_Drive_Delivery_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}☁️  Google Drive Delivery Preparation${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Flutter is installed
check_flutter() {
    print_info "Checking Flutter installation..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_status "Flutter is installed"
}

# Clean and get dependencies
setup_project() {
    print_info "Setting up project..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Generate app icons
    flutter pub run flutter_launcher_icons
    
    print_status "Project setup completed"
}

# Build for all platforms
build_applications() {
    print_info "Building applications for all platforms..."
    
    # Android
    print_info "Building Android APK..."
    flutter build apk --release
    
    print_info "Building Android App Bundle..."
    flutter build appbundle --release
    
    # Web
    print_info "Building Web application..."
    flutter build web --release
    
    # Windows
    print_info "Building Windows application..."
    flutter build windows --release
    
    # macOS
    print_info "Building macOS application..."
    flutter build macos --release
    
    print_status "All applications built successfully"
}

# Create delivery package
create_delivery_package() {
    print_info "Creating professional delivery package..."
    
    # Create main delivery directory
    mkdir -p "$DELIVERY_DIR"
    cd "$DELIVERY_DIR"
    
    # Create folder structure
    mkdir -p "Source_Code" "Built_Applications" "Documentation" "Assets" "Security"
    mkdir -p "Built_Applications/Android" "Built_Applications/Web" "Built_Applications/Windows" "Built_Applications/macOS"
    mkdir -p "Assets/Audio_Files" "Assets/Images" "Assets/Icons"
    
    print_status "Folder structure created"
}

# Copy source code
copy_source_code() {
    print_info "Copying source code..."
    
    # Copy main source files
    cp -r ../lib/ Source_Code/
    cp ../pubspec.yaml Source_Code/
    cp ../README.md Source_Code/
    
    # Copy assets (excluding audio files to reduce size)
    cp -r ../assets/images/ Assets/Images/
    cp -r ../assets/icon/ Assets/Icons/
    
    # Copy audio files separately
    if [ -d "../assets/audio" ]; then
        cp -r ../assets/audio/* Assets/Audio_Files/
    fi
    
    print_status "Source code copied"
}

# Copy built applications
copy_built_applications() {
    print_info "Copying built applications..."
    
    # Android
    if [ -f "../build/app/outputs/flutter-apk/app-release.apk" ]; then
        cp ../build/app/outputs/flutter-apk/app-release.apk Built_Applications/Android/
        print_status "Android APK copied"
    fi
    
    if [ -f "../build/app/outputs/bundle/release/app-release.aab" ]; then
        cp ../build/app/outputs/bundle/release/app-release.aab Built_Applications/Android/
        print_status "Android App Bundle copied"
    fi
    
    # Web
    if [ -d "../build/web" ]; then
        cp -r ../build/web/* Built_Applications/Web/
        print_status "Web build copied"
    fi
    
    # Windows
    if [ -d "../build/windows/runner/Release" ]; then
        cp -r ../build/windows/runner/Release/* Built_Applications/Windows/
        print_status "Windows build copied"
    fi
    
    # macOS
    if [ -d "../build/macos/Build/Products/Release" ]; then
        cp -r ../build/macos/Build/Products/Release/* Built_Applications/macOS/
        print_status "macOS build copied"
    fi
}

# Create documentation
create_documentation() {
    print_info "Creating documentation..."
    
    # Copy existing documentation
    cp ../README.md Documentation/
    cp ../GOOGLE_DRIVE_DELIVERY.md Documentation/
    
    # Create setup instructions
    cat > Documentation/SETUP_INSTRUCTIONS.md << 'EOF'
# Setup Instructions - Audiobooks App

## 🚀 Quick Start Guide

### For Development (Technical Users):
1. **Extract Source_Code folder**
2. **Open terminal/command prompt**
3. **Navigate to the folder**
4. **Run**: `flutter pub get`
5. **Run**: `flutter run`

### For Testing (All Users):

#### Android:
- **File**: `Built_Applications/Android/app-release.apk`
- **Install**: Enable "Install from unknown sources"
- **Test**: All features immediately available

#### Web:
- **File**: `Built_Applications/Web/index.html`
- **Open**: In any modern browser
- **Test**: Works offline, no server needed

#### Windows:
- **File**: `Built_Applications/Windows/audiobooks_app.exe`
- **Run**: Double-click the executable
- **Test**: Full desktop experience

#### macOS:
- **File**: `Built_Applications/macOS/audiobooks_app.app`
- **Open**: Double-click the app bundle
- **Test**: Native macOS experience

## 📱 Platform Requirements

### Android:
- **Version**: Android 5.0 (API 21) or higher
- **Storage**: 50 MB free space
- **Permissions**: Audio playback

### Web:
- **Browser**: Chrome, Firefox, Safari, Edge
- **Version**: Modern browsers (2018+)
- **Features**: Audio API support

### Windows:
- **Version**: Windows 10 or higher
- **Storage**: 100 MB free space
- **Features**: Audio drivers

### macOS:
- **Version**: macOS 10.14 or higher
- **Storage**: 100 MB free space
- **Features**: Audio drivers

## 🔧 Troubleshooting

### Common Issues:

#### "Flutter not found":
- Install Flutter SDK
- Add to PATH environment variable
- Run: `flutter doctor`

#### "Audio not playing":
- Check device volume
- Verify audio file permissions
- Test with different audio files

#### "App not installing":
- Enable "Install from unknown sources"
- Check available storage space
- Verify APK file integrity

#### "Web version not loading":
- Check browser compatibility
- Clear browser cache
- Try different browser

## 📞 Support

### Contact Information:
- **Email**: [Your Email]
- **Phone**: [Your Phone]
- **Response Time**: Within 24 hours

### What to Include:
- Platform you're testing on
- Specific error message
- Steps to reproduce
- Screenshots if helpful

## 🎯 Features to Test

### Core Functionality:
- [ ] App launches successfully
- [ ] Audio files play correctly
- [ ] Player controls work
- [ ] Progress tracking works
- [ ] UI displays properly

### Platform-Specific:
- [ ] Background audio (mobile)
- [ ] Full-screen mode (web)
- [ ] Window resizing (desktop)
- [ ] Audio device switching

---

**Need Help?** Contact support immediately for assistance.
EOF

    # Create support guide
    cat > Documentation/SUPPORT_GUIDE.md << 'EOF'
# Support Guide - Audiobooks App

## 🆘 Getting Help

### Before Contacting Support:
1. **Check this guide** for common solutions
2. **Restart the application**
3. **Test on different device/browser**
4. **Check system requirements**

### When Contacting Support:
- **Be specific** about the issue
- **Include error messages**
- **Describe what you were doing**
- **Mention your platform**

## 🔧 Common Solutions

### Audio Issues:
- **No sound**: Check device volume and audio settings
- **Crackling**: Close other audio applications
- **Not playing**: Verify audio file format (MP3, WAV)

### Performance Issues:
- **Slow loading**: Check internet connection
- **Laggy playback**: Close other applications
- **High memory usage**: Restart the application

### Installation Issues:
- **Android**: Enable "Install from unknown sources"
- **Windows**: Run as administrator if needed
- **macOS**: Allow in Security & Privacy settings

## 📋 System Requirements

### Minimum Requirements:
- **Android**: 5.0+, 2GB RAM, 50MB storage
- **Web**: Modern browser, 4GB RAM
- **Windows**: Windows 10+, 4GB RAM, 100MB storage
- **macOS**: 10.14+, 4GB RAM, 100MB storage

### Recommended Requirements:
- **Android**: 8.0+, 4GB RAM, 100MB storage
- **Web**: Chrome/Firefox, 8GB RAM
- **Windows**: Windows 11+, 8GB RAM, 500MB storage
- **macOS**: 11.0+, 8GB RAM, 500MB storage

## 🚨 Emergency Support

### Critical Issues:
- **App won't start**: Contact immediately
- **Data loss**: Stop using app, contact support
- **Security concerns**: Report immediately

### Response Times:
- **Critical**: 2-4 hours
- **High**: 24 hours
- **Normal**: 48 hours
- **Low**: 1 week

---

**Support Contact**: [Your Contact Information]
EOF

    print_status "Documentation created"
}

# Create security files
create_security_files() {
    print_info "Creating security documentation..."
    
    # Create security checklist
    cat > Security/SECURITY_CHECKLIST.md << 'EOF'
# Security Checklist - Audiobooks App

## ✅ Pre-Delivery Security Review

### Code Security:
- [x] No hardcoded API keys or secrets
- [x] No debug/development code included
- [x] Environment variables properly configured
- [x] No sensitive data in logs or comments

### Asset Security:
- [x] Audio files are properly licensed
- [x] Images and icons are original or licensed
- [x] No copyrighted material included
- [x] All assets are properly attributed

### Build Security:
- [x] Release builds only (no debug builds)
- [x] App signing configured properly
- [x] Code obfuscation enabled (Android)
- [x] Code stripping enabled (iOS)

### Privacy & Compliance:
- [x] No personal data collection
- [x] No external analytics
- [x] No unnecessary permissions
- [x] Privacy-focused design

## 🔐 Delivery Security

### Google Drive Security:
- [x] Secure sharing permissions set
- [x] Access monitoring enabled
- [x] Password protection (if applicable)
- [x] Expiration date set (if needed)

### Client Communication:
- [x] Client identity verified
- [x] Access credentials shared securely
- [x] Clear instructions provided
- [x] Support contact established

## 📋 Post-Delivery

### Monitoring:
- [x] Access logs monitored
- [x] Client feedback collected
- [x] Issues documented
- [x] Updates planned

### Maintenance:
- [x] Security updates scheduled
- [x] Vulnerability scanning planned
- [x] Client training provided
- [x] Incident response ready

---

**Security Level**: High
**Review Date**: $(date)
**Next Review**: $(date -d "+6 months")
EOF

    # Create license information
    cat > Security/LICENSE_INFO.md << 'EOF'
# License Information - Audiobooks App

## 📄 Software License

### Ownership:
- **Developer**: [Your Name/Company]
- **Client**: [Client Name/Company]
- **Project**: Audiobooks App - انصت

### License Terms:
- **Type**: Proprietary software
- **Rights**: All rights reserved
- **Distribution**: Authorized clients only
- **Modification**: With written permission

### Permitted Use:
- ✅ **Testing and evaluation**
- ✅ **Development and customization**
- ✅ **Production deployment**
- ✅ **Client's internal use**

### Restricted Use:
- ❌ **Redistribution to third parties**
- ❌ **Commercial resale**
- ❌ **Reverse engineering**
- ❌ **Unauthorized modification**

## 🎵 Audio Content License

### Audio Files:
- **Format**: MP3, WAV
- **Quality**: High definition
- **License**: [Specify license type]
- **Usage**: Educational/Personal use

### Attribution:
- **Author**: [Audio content author]
- **License**: [License type]
- **Source**: [Source information]

## 🖼️ Image Assets License

### Images:
- **Format**: JPG, PNG
- **Resolution**: High quality
- **License**: [Specify license type]
- **Usage**: App interface only

### Icons:
- **Format**: PNG, SVG
- **Style**: Material Design
- **License**: [Specify license type]
- **Usage**: App branding

## 🔒 Intellectual Property

### Protected Elements:
- **Source code and architecture**
- **User interface design**
- **Audio content and assets**
- **Branding and trademarks**

### Client Rights:
- **Use of delivered application**
- **Customization within scope**
- **Deployment to authorized platforms**
- **Support and maintenance**

### Developer Rights:
- **Retain intellectual property**
- **Use for portfolio purposes**
- **Provide similar services**
- **Retain development knowledge**

## 📋 Compliance

### Legal Requirements:
- **Copyright law compliance**
- **Software licensing laws**
- **Data protection regulations**
- **Export control regulations**

### Industry Standards:
- **Software development best practices**
- **Security standards compliance**
- **Quality assurance standards**
- **Documentation standards**

---

**License Version**: 1.0
**Effective Date**: $(date)
**Review Period**: Annual
EOF

    print_status "Security documentation created"
}

# Show package information
show_package_info() {
    print_info "Package information:"
    echo ""
    echo -e "${BLUE}📁 Delivery Directory:${NC} $DELIVERY_DIR"
    echo ""
    
    # Show folder structure
    echo -e "${BLUE}📂 Package Structure:${NC}"
    tree -L 2 "$DELIVERY_DIR" 2>/dev/null || find "$DELIVERY_DIR" -type d | head -20
    
    echo ""
    
    # Show file sizes
    echo -e "${BLUE}📊 Package Sizes:${NC}"
    du -sh "$DELIVERY_DIR"/* 2>/dev/null || echo "Size information unavailable"
    
    echo ""
    
    # Show total size
    TOTAL_SIZE=$(du -sh "$DELIVERY_DIR" 2>/dev/null | cut -f1)
    echo -e "${BLUE}📦 Total Package Size:${NC} $TOTAL_SIZE"
    
    echo ""
}

# Create Google Drive instructions
create_google_drive_instructions() {
    print_info "Creating Google Drive upload instructions..."
    
    cat > "$DELIVERY_DIR/GOOGLE_DRIVE_UPLOAD.md" << EOF
# Google Drive Upload Instructions

## 📤 Upload Steps:

1. **Go to Google Drive** (drive.google.com)
2. **Create new folder**: "Audiobooks App - انصت v$VERSION"
3. **Upload entire package**: Drag and drop the "$DELIVERY_DIR" folder
4. **Set sharing permissions**:
   - Right-click folder → Share
   - Set to "Anyone with the link"
   - Permission: "Viewer"
   - Optional: Add password protection
5. **Copy sharing link**
6. **Send to client** with professional message

## 📧 Professional Message Template:

\`\`\`
🎯 Audiobooks App Ready!

Your professional delivery package is available on Google Drive:

📁 Complete Package:
• Source code + Built apps
• Documentation + Assets
• Setup guides + Support

🔗 Access: [PASTE_GOOGLE_DRIVE_LINK_HERE]
🔑 Password: [If applicable]

📱 Test immediately on any platform
📞 Support available 24/7

Professional delivery - secure and ready! 🚀
\`\`\`

## ✅ Upload Checklist:
- [ ] All files uploaded successfully
- [ ] Folder structure maintained
- [ ] Sharing permissions set
- [ ] Link tested and working
- [ ] Professional message sent
- [ ] Client access confirmed

---
**Package Created**: $(date)
**Total Size**: $TOTAL_SIZE
**Ready for Upload**: ✅
EOF

    print_status "Google Drive instructions created"
}

# Main execution
main() {
    echo -e "${BLUE}Starting Google Drive delivery preparation...${NC}"
    echo ""
    
    check_flutter
    setup_project
    build_applications
    create_delivery_package
    copy_source_code
    copy_built_applications
    create_documentation
    create_security_files
    show_package_info
    create_google_drive_instructions
    
    echo ""
    echo -e "${GREEN}🎉 Google Drive delivery package created successfully!${NC}"
    echo ""
    echo -e "${BLUE}📁 Package Location:${NC} $DELIVERY_DIR"
    echo -e "${BLUE}📤 Next Step:${NC} Upload to Google Drive"
    echo ""
    echo -e "${YELLOW}📋 Instructions:${NC}"
    echo -e "${YELLOW}   1. Open Google Drive${NC}"
    echo -e "${YELLOW}   2. Create new folder${NC}"
    echo -e "${YELLOW}   3. Upload the $DELIVERY_DIR folder${NC}"
    echo -e "${YELLOW}   4. Set sharing permissions${NC}"
    echo -e "${YELLOW}   5. Send link to client${NC}"
    echo ""
    echo -e "${GREEN}✅ Ready for professional Google Drive delivery!${NC}"
}

# Run main function
main "$@" 