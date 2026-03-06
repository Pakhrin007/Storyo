import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  const SearchBarWidget({super.key, required this.onChanged, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              onTap: onTap,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search stories, authors, or genres…",
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}