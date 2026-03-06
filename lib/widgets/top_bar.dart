import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final VoidCallback onBellTap;

  const TopBar({super.key, required this.onAvatarTap, required this.onBellTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1E88FF),
              child: const Text("S",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Storyo",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: onBellTap,
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}