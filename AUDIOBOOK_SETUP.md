# 🎧 Quick Setup Guide for Your 6 Audiobooks

Follow these simple steps to add your audiobooks to the app:

## Step 1: Add Your Files

1. **Copy your 6 cover images** to: `assets/images/`
   - Name them: `book1.jpg`, `book2.jpg`, `book3.jpg`, `book4.jpg`, `book5.jpg`, `book6.jpg`
   - Or use your own naming convention (just remember the names)

2. **Copy your 6 audio files** to: `assets/audio/`
   - Name them: `book1.mp3`, `book2.mp3`, `book3.mp3`, `book4.mp3`, `book5.mp3`, `book6.mp3`
   - Or use your own naming convention

## Step 2: Update Your Book Information

Edit the file: `lib/providers/audiobook_provider.dart`

Find the `_loadSampleBooks()` method and replace it with your book details:

```dart
void _loadSampleBooks() {
  _audioBooks = [
    AudioBook(
      id: '1',
      title: 'YOUR BOOK 1 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your first book...',
      imagePath: 'assets/images/book1.jpg',
      audioPath: 'audio/book1.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
    AudioBook(
      id: '2',
      title: 'YOUR BOOK 2 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your second book...',
      imagePath: 'assets/images/book2.jpg',
      audioPath: 'audio/book2.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
    AudioBook(
      id: '3',
      title: 'YOUR BOOK 3 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your third book...',
      imagePath: 'assets/images/book3.jpg',
      audioPath: 'audio/book3.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
    AudioBook(
      id: '4',
      title: 'YOUR BOOK 4 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your fourth book...',
      imagePath: 'assets/images/book4.jpg',
      audioPath: 'audio/book4.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
    AudioBook(
      id: '5',
      title: 'YOUR BOOK 5 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your fifth book...',
      imagePath: 'assets/images/book5.jpg',
      audioPath: 'audio/book5.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
    AudioBook(
      id: '6',
      title: 'YOUR BOOK 6 TITLE',
      author: 'AUTHOR NAME',
      description: 'Description of your sixth book...',
      imagePath: 'assets/images/book6.jpg',
      audioPath: 'audio/book6.mp3',
      duration: const Duration(hours: 0, minutes: 0), // Set actual duration
    ),
  ];
  notifyListeners();
}
```

## Step 3: Run the App

```bash
flutter pub get
flutter run
```

## 📝 Template for Quick Copy-Paste

Just fill in your details:

```dart
AudioBook(
  id: 'UNIQUE_ID',
  title: 'BOOK_TITLE',
  author: 'AUTHOR_NAME',
  description: 'BOOK_DESCRIPTION',
  imagePath: 'assets/images/IMAGE_FILENAME',
  audioPath: 'audio/AUDIO_FILENAME',
  duration: const Duration(hours: HOURS, minutes: MINUTES),
),
```

## 🎯 Quick Tips

- **Image formats**: JPG, PNG work best
- **Audio formats**: MP3 is recommended
- **File sizes**: Keep images under 2MB for better performance
- **Duration**: You can estimate or leave as 0 initially

That's it! Your audiobook app will be ready to use! 🚀 