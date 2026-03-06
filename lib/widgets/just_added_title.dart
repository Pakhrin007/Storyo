import 'package:flutter/material.dart';
import 'package:storyo/data/home_itemds.dart';

class JustAddedTile extends StatelessWidget {
  final HomePdfItem item;
  final String tag;
  final VoidCallback onTap;

  const JustAddedTile({super.key, required this.item, required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                item.coverAsset,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.08),
                  child: const Icon(Icons.image_outlined, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text("${item.author} • $tag", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(item.minutes, style: const TextStyle(color: Color(0xFF1E88FF), fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white38),
            )
          ],
        ),
      ),
    );
  }
}