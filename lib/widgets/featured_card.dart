import 'package:flutter/material.dart';
import 'package:storyo/data/home_itemds.dart';

class FeaturedCard extends StatelessWidget {
  final HomePdfItem item;
  final VoidCallback onReadNow;
  final VoidCallback onBookmark;

  const FeaturedCard({
    super.key,
    required this.item,
    required this.onReadNow,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: DecorationImage(
          image: AssetImage(item.coverAsset),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.80),
              Colors.black.withOpacity(0.10),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "FEATURED STORY",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(item.title,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text("by ${item.author} • ${item.minutes}",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReadNow,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("Read Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onBookmark,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}