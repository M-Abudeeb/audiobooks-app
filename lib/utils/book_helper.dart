import '../models/audiobook.dart';

class BookHelper {
  /// Creates an AudioBook with the given parameters
  /// This helper makes it easy to add new books to your library
  static AudioBook createBook({
    required String id,
    required String title,
    required String author,
    required String description,
    required String imageName, // Just the filename, e.g., "book1.jpg"
    required String audioName, // Just the filename, e.g., "book1.mp3"
    required Duration duration,
    List<Chapter>? chapters,
  }) {
    return AudioBook(
      id: id,
      title: title,
      author: author,
      description: description,
      imagePath: 'assets/images/$imageName',
      audioPath: 'audio/$audioName',
      duration: duration,
      chapters: chapters ?? [],
    );
  }

  /// Helper method to create duration from hours and minutes
  static Duration createDuration({
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) {
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  /// Sample method showing how to add your books
  /// Copy this pattern and modify with your actual book details
  static List<AudioBook> createSampleBooks() {
    return [
      createBook(
        id: '1',
        title: 'Your First Book Title',
        author: 'Author Name',
        description: 'Description of your first audiobook...',
        imageName: 'book1.jpg', // Your image filename
        audioName: 'book1.mp3', // Your audio filename
        duration: createDuration(hours: 2, minutes: 30),
      ),
      createBook(
        id: '2',
        title: 'Your Second Book Title',
        author: 'Another Author',
        description: 'Description of your second audiobook...',
        imageName: 'book2.jpg',
        audioName: 'book2.mp3',
        duration: createDuration(hours: 1, minutes: 45),
      ),
      // Add more books here following the same pattern
    ];
  }

  /// Quick method to add a book with minimal details
  static AudioBook quickBook(
    String title,
    String author,
    String imageName,
    String audioName,
  ) {
    return createBook(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author,
      description: 'Add your book description here...',
      imageName: imageName,
      audioName: audioName,
      duration: createDuration(hours: 1), // Default 1 hour, adjust as needed
    );
  }
}
