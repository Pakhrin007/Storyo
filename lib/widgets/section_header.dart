import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(actionText, style: const TextStyle(color: Color(0xFF1E88FF), fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class TextOnlyHeader extends StatelessWidget {
  final String text;
  const TextOnlyHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
    );
  }
}