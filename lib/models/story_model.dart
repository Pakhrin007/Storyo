class StoryModel {
  final String id;
  final String title;
  final String genre;
  final String coverUrl;
  final String pdfUrl;
  final String author;
  final bool isAsset;

  final List<String> tags;
  final String? coverFileName;
  final String? pdfFileName;
  final dynamic createdAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.coverUrl,
    required this.pdfUrl,
    required this.author,
    this.isAsset = false,
    this.tags = const [],
    this.coverFileName,
    this.pdfFileName,
    this.createdAt,
  });

  factory StoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawTags = data['tags'];

    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString()).toList();
    } else if (rawTags is String && rawTags.trim().isNotEmpty) {
      parsedTags = [rawTags.trim()];
    }

    return StoryModel(
      id: id,
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      author: data['authorName'] ?? data['authorEmail'] ?? 'Unknown Author',
      isAsset: false,
      tags: parsedTags,
      coverFileName: data['coverFileName'],
      pdfFileName: data['pdfFileName'],
      createdAt: data['createdAt'],
    );
  }
}