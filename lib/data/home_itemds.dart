class HomePdfItem {
  final String title;
  final String author;
  final String minutes;
  final String coverAsset; // image shown in home
  final String pdfAsset;   // pdf opened in reader

  const HomePdfItem({
    required this.title,
    required this.author,
    required this.minutes,
    required this.coverAsset,
    required this.pdfAsset,
  });
}

// ✅ Change filenames to match what you have in assets/home and assets/pdfs
const featuredItem = HomePdfItem(
  title: "The Echo of Silence",
  author: "Elena Vance",
  minutes: "15 min read",
  coverAsset: "assets/home/featured.jpg",
  pdfAsset: "assets/pdfs/midnight_echo.pdf",
);

const trendingItems = [
  HomePdfItem(
    title: "Beyond the Horizon",
    author: "Marcus Aurel",
    minutes: "12 min",
    coverAsset: "assets/home/trending1.jpg",
    pdfAsset: "assets/pdfs/neon_horizon.pdf",
  ),
  HomePdfItem(
    title: "Warped Reality",
    author: "Sara K.",
    minutes: "8 min",
    coverAsset: "assets/home/trending1.jpg",
    pdfAsset: "assets/pdfs/silent_clue.pdf",
  ),
];

const justAddedItems = [
  HomePdfItem(
    title: "Silicon Souls",
    author: "R.H. Miller",
    minutes: "10 MIN READ",
    coverAsset: "assets/home/trending1.jpg",
    pdfAsset: "assets/pdfs/love_letters.pdf",
  ),
  HomePdfItem(
    title: "Midnight in Kyoto",
    author: "Hana Sato",
    minutes: "15 MIN READ",
    coverAsset: "assets/home/trending1.jpg",
    pdfAsset: "assets/pdfs/midnight_echo.pdf",
  ),
];