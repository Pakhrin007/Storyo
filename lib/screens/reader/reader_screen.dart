import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:storyo/core/colors.dart'; // or app_colors.dart (use your correct file)
import 'package:storyo/data/story_data.dart';
import 'package:velocity_x/velocity_x.dart';

class ReaderScreen extends StatefulWidget {
  final StoryItem item;
  const ReaderScreen({super.key, required this.item});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  PdfControllerPinch? _pdfController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  void _loadPdf() {
  setState(() {
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.item.pdfAsset),
    );
    _loading = false;
  });
}

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            HStack(
              [
                Icon(Icons.arrow_back_ios_new, color: Colors.white)
                    .p8()
                    .onInkTap(() => Navigator.pop(context)),
                6.widthBox,
                "STORYO".text.white.semiBold.textStyle(TextStyle(fontFamily: 'libertin')).make(),
              
              ],
            ).px8(),

            8.heightBox,
            widget.item.title.text.white.bold.xl2.textStyle(TextStyle(fontFamily: 'libertin')).make().px16(),
            widget.item.author.text.color(Colors.white60).textStyle(TextStyle(fontFamily: 'libertin')).make().px20(),
            12.heightBox,

            // PDF ONLY
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : (_error != null)
                          ? _error!.text.white.makeCentered()
                          : PdfViewPinch(controller: _pdfController!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}