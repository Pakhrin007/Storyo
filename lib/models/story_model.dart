class StoryModel {
  final String id;
  final String title;
  final String genre;
  final String coverUrl;
  final String pdfUrl;
  final String author;
  final bool isAsset;

  StoryModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.coverUrl,
    required this.pdfUrl,
    required this.author,
    this.isAsset = false,
  });

  factory StoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StoryModel(
      id: id,
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      author: data['authorEmail'] ?? 'Unknown Author',
      isAsset: false,
    );
  }
}
