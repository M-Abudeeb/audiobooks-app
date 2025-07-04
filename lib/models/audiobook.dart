class AudioBook {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imagePath;
  final String audioPath;
  final Duration duration;
  final List<Chapter> chapters;

  AudioBook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
    this.chapters = const [],
  });

  AudioBook copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? imagePath,
    String? audioPath,
    Duration? duration,
    List<Chapter>? chapters,
  }) {
    return AudioBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      chapters: chapters ?? this.chapters,
    );
  }
}

class Chapter {
  final String title;
  final Duration startTime;
  final Duration endTime;

  Chapter({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}
