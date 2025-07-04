import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audiobook.dart';

class AudioBookProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<AudioBook> _audioBooks = [];
  AudioBook? _currentBook;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _playbackSpeed = 1.0;
  double _volume = 0.7; // Default volume at 70%
  SharedPreferences? _prefs;

  // Getters
  List<AudioBook> get audioBooks => _audioBooks;
  AudioBook? get currentBook => _currentBook;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get playbackSpeed => _playbackSpeed;
  double get volume => _volume;
  AudioPlayer get audioPlayer => _audioPlayer;

  AudioBookProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    _prefs = await SharedPreferences.getInstance();
    _loadVolumeSettings();
    _initializePlayer();
    _loadSampleBooks();
    _configureAudioSession();
  }

  void _configureAudioSession() async {
    // Configure audio session for background playbook
    await _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.allowBluetooth,
            AVAudioSessionOptions.allowBluetoothA2DP,
            AVAudioSessionOptions.allowAirPlay,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  void _initializePlayer() {
    // Set initial volume from loaded settings
    _audioPlayer.setVolume(_volume);

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      // Save progress every 5 seconds to avoid too many writes
      if (position.inSeconds % 5 == 0 && _currentBook != null) {
        _saveBookProgress(_currentBook!.id, position);
      }
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isLoading = state == PlayerState.stopped;

      // Save progress when paused or stopped
      if ((state == PlayerState.paused || state == PlayerState.stopped) &&
          _currentBook != null) {
        _saveBookProgress(_currentBook!.id, _currentPosition);
      }

      notifyListeners();
    });
  }

  // Save book progress to SharedPreferences
  Future<void> _saveBookProgress(String bookId, Duration position) async {
    if (_prefs != null) {
      await _prefs!.setInt('book_${bookId}_progress', position.inSeconds);
      // Progress saved successfully
    }
  }

  // Load book progress from SharedPreferences
  Duration _loadBookProgress(String bookId) {
    if (_prefs != null) {
      final seconds = _prefs!.getInt('book_${bookId}_progress') ?? 0;
      // Progress loaded successfully
      return Duration(seconds: seconds);
    } else {
      return Duration.zero;
    }
  }

  // Load volume settings from SharedPreferences
  void _loadVolumeSettings() {
    if (_prefs != null) {
      _volume = _prefs!.getDouble('app_volume') ?? 0.7;
      // Volume settings loaded
    }
  }

  // Save volume settings to SharedPreferences
  Future<void> _saveVolumeSettings() async {
    if (_prefs != null) {
      await _prefs!.setDouble('app_volume', _volume);
      // Volume settings saved
    }
  }

  void _loadSampleBooks() {
    // Your audiobooks matched with the correct audio files and images
    _audioBooks = [
      AudioBook(
        id: '1',
        title: 'الصلاة مجمع الكمال',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath: 'assets/images/salah_book.jpg',
        audioPath: 'audio/salah_book.mp3', // Matched with salah_book.mp3
        duration: const Duration(hours: 1, minutes: 30),
      ),
      AudioBook(
        id: '2',
        title: 'الامام المهدي عدالة منتظرة - الجزء الأول',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath: 'assets/images/mahdi_book.jpg',
        audioPath: 'audio/mahdi_book.mp3', // Matched with mahdi_book.mp3
        duration: const Duration(hours: 4, minutes: 0),
      ),
      AudioBook(
        id: '3',
        title: 'من قضايا النهضة الحسينية - الجزء الأول',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath: 'assets/images/husseini_book.jpg',
        audioPath: 'audio/husseini_book.mp3', // Matched with husseini_book.mp3
        duration: const Duration(hours: 4, minutes: 30),
      ),
      AudioBook(
        id: '4',
        title: 'من قضايا النهضة الحسينية - الجزء الثاني',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath:
            'assets/images/husseini_book.jpg', // Same image for all parts
        audioPath:
            'audio/husseini_book_part2.mp3', // Now using husseini_book_part2.mp3
        duration: const Duration(hours: 5, minutes: 0),
      ),
      AudioBook(
        id: '5',
        title: 'من قضايا النهضة الحسينية - الجزء الثالث',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath:
            'assets/images/husseini_book.jpg', // Same image for all parts
        audioPath:
            'audio/husseini_book_part3.mp3', // Matched with husseini_book_part3.mp3
        duration: const Duration(hours: 4, minutes: 30),
      ),
      AudioBook(
        id: '6',
        title: 'إنهما ناصران',
        author: 'الشيخ فوزي آل سيف',
        description: 'test',
        imagePath: 'assets/images/nasirani_book.jpg',
        audioPath: 'audio/nasirani_book.mp3', // Matched with nasirani_book.mp3
        duration: const Duration(hours: 5, minutes: 30),
      ),
    ];
    notifyListeners();
  }

  Future<void> playBook(AudioBook book) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Save current book progress before switching
      if (_currentBook != null && _currentBook!.id != book.id) {
        await _saveBookProgress(_currentBook!.id, _currentPosition);
      }

      _currentBook = book;

      // Load saved progress before playing
      final savedPosition = _loadBookProgress(book.id);
      // Loading book with saved position

      // Start playing the audio
      await _audioPlayer.play(AssetSource(book.audioPath));

      // Wait a bit for audio to load, then seek to saved position
      if (savedPosition.inSeconds > 0) {
        // Wait for audio to be ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Seek to saved position
        await _audioPlayer.seek(savedPosition);
        _currentPosition = savedPosition;
        // Seeked to saved position
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Error occurred while playing book
    }
  }

  Future<void> pause() async {
    if (_currentBook != null) {
      await _saveBookProgress(_currentBook!.id, _currentPosition);
    }
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> stop() async {
    if (_currentBook != null) {
      await _saveBookProgress(_currentBook!.id, _currentPosition);
    }
    await _audioPlayer.stop();
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    if (_currentBook != null) {
      await _saveBookProgress(_currentBook!.id, position);
    }
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audioPlayer.setPlaybackRate(speed);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0); // Ensure volume is between 0 and 1
    await _audioPlayer.setVolume(_volume);
    await _saveVolumeSettings(); // Save volume setting
    notifyListeners();
  }

  // Get saved progress for a specific book (for UI display)
  Duration getSavedProgress(String bookId) {
    return _loadBookProgress(bookId);
  }

  // Reset progress for a specific book
  Future<void> resetBookProgress(String bookId) async {
    if (_prefs != null) {
      await _prefs!.remove('book_${bookId}_progress');
      notifyListeners();
    }
  }

  // Play book immediately (for tap-to-play functionality)
  Future<void> playBookImmediately(AudioBook book) async {
    try {
      // If the same book is already playing, don't interrupt it
      if (_currentBook?.id == book.id && _isPlaying) {
        // Same book already playing
        return; // Just navigate to player, don't restart audio
      }

      _isLoading = true;
      notifyListeners();

      // If there's a different book currently playing, stop it first
      if (_currentBook != null && _currentBook!.id != book.id && _isPlaying) {
        await _saveBookProgress(_currentBook!.id, _currentPosition);
        await _audioPlayer.stop();
      }

      // Save current book progress before switching (if different book)
      if (_currentBook != null && _currentBook!.id != book.id) {
        await _saveBookProgress(_currentBook!.id, _currentPosition);
      }

      _currentBook = book;

      // Load saved progress before playing
      final savedPosition = _loadBookProgress(book.id);

      // Start playing the audio
      await _audioPlayer.play(AssetSource(book.audioPath));

      // Wait for audio to be ready and duration to be detected
      int attempts = 0;
      while (_totalDuration == Duration.zero && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      // If we have a saved position, seek to it immediately after audio is ready
      if (savedPosition.inSeconds > 0 && _totalDuration.inSeconds > 0) {
        // Pause first to avoid playing from beginning
        await _audioPlayer.pause();

        // Seek to saved position
        await _audioPlayer.seek(savedPosition);
        _currentPosition = savedPosition;

        // Wait a bit for seek to complete, then resume
        await Future.delayed(const Duration(milliseconds: 300));
        await _audioPlayer.resume();

        // Automatically seeked to saved position
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Error occurred during immediate playback
    }
  }

  // Prepare book for playing (set as current but don't start audio yet)
  Future<void> prepareBook(AudioBook book) async {
    try {
      // If the same book is already playing, don't interrupt it
      if (_currentBook?.id == book.id && _isPlaying) {
        // Same book already playing
        return; // Just navigate to player, don't restart audio
      }

      _isLoading = true;
      notifyListeners();

      // If there's a different book currently playing, stop it first
      if (_currentBook != null && _currentBook!.id != book.id && _isPlaying) {
        await _saveBookProgress(_currentBook!.id, _currentPosition);
        await _audioPlayer.stop();
      }

      // Save current book progress before switching (if different book)
      if (_currentBook != null && _currentBook!.id != book.id) {
        await _saveBookProgress(_currentBook!.id, _currentPosition);
      }

      _currentBook = book;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Error occurred during book preparation
    }
  }

  // Start playing the current book (called after UI is shown)
  Future<void> startCurrentBook() async {
    if (_currentBook == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Load saved progress before playing
      final savedPosition = _loadBookProgress(_currentBook!.id);

      // Start playing the audio
      await _audioPlayer.play(AssetSource(_currentBook!.audioPath));

      // Wait for audio to be ready and duration to be detected
      int attempts = 0;
      while (_totalDuration == Duration.zero && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      // If we have a saved position, seek to it immediately after starting
      if (savedPosition.inSeconds > 0 && _totalDuration.inSeconds > 0) {
        // Pause first to avoid playing from beginning
        await _audioPlayer.pause();

        // Seek to saved position
        await _audioPlayer.seek(savedPosition);
        _currentPosition = savedPosition;

        // Wait a bit for seek to complete, then resume
        await Future.delayed(const Duration(milliseconds: 200));
        await _audioPlayer.resume();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Error occurred starting current book
    }
  }

  void addBook(AudioBook book) {
    _audioBooks.add(book);
    notifyListeners();
  }

  void removeBook(String bookId) {
    _audioBooks.removeWhere((book) => book.id == bookId);
    if (_currentBook?.id == bookId) {
      stop();
      _currentBook = null;
    }
    // Also remove saved progress
    resetBookProgress(bookId);
    notifyListeners();
  }

  @override
  void dispose() {
    // Save current progress before disposing
    if (_currentBook != null) {
      _saveBookProgress(_currentBook!.id, _currentPosition);
    }
    _audioPlayer.dispose();
    super.dispose();
  }
}
