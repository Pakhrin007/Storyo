class StoryItem {
  final String id;
  final String title;
  final String author;
  final String genre; // must match tab names
  final String coverAsset;
  final String pdfAsset;
  // final List<String> pageImages; // images of pages

  const StoryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverAsset,
    required this.pdfAsset,
    // required this.pageImages,
  });
}

const List<String> genres = [
  "Fantasy",
  "Sci-Fi",
  "Mystery",
  "Romance",
];
final List<StoryItem> stories = [
  StoryItem(
    id: "1",
    title: "The Midnight Echo",
    author: "Elena Vance",
    genre: "Fantasy",
    coverAsset: "assets/covers/midnight_echo.jpg",
    pdfAsset: "assets/pdfs/midnight_echo.pdf",
    // pageImages: const [], // you don't have page images yet
  ),
  StoryItem(
    id: "2",
    title: "Neon Horizon",
    author: "Marcus K.",
    genre: "Sci-Fi",
    coverAsset: "assets/covers/neon_horizon.png", // ✅ png (fixed)
    pdfAsset: "assets/pdfs/neon_horizon.pdf",
    // pageImages: const [],
  ),
  StoryItem(
    id: "3",
    title: "Silent Clue",
    author: "Noah Grey",
    genre: "Mystery",
    coverAsset: "assets/covers/silent_clue.jpg",
    pdfAsset: "assets/pdfs/silent_clue.pdf",
    // pageImages: const [],
  ),
  StoryItem(
    id: "4",
    title: "Love Letters",
    author: "Ava Rose",
    genre: "Romance",
    coverAsset: "assets/covers/love_letters.jpg",
    pdfAsset: "assets/pdfs/love_letters.pdf",
    // pageImages: const [],
  ),
];