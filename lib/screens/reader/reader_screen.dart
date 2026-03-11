import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:storyo/models/story_model.dart';

class ReaderScreen extends StatelessWidget {
  final StoryModel story;

  const ReaderScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: SfPdfViewer.network(story.pdfUrl),
    );
  }
}
