import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/services/cloudinary_service.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateStoryScreen extends StatefulWidget {
  final StoryModel? story;

  const CreateStoryScreen({super.key, this.story});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  int selectedGenre = 0;
  final genres = ["Fantasy", "Romance", "Sci-Fi", "Mystery"];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Uint8List? _coverBytes;
  String? _coverFileName;

  Uint8List? _pdfBytes;
  String? _pdfFileName;

  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.story != null) {
      _titleController.text = widget.story!.title;
      _tagsController.text = widget.story!.tags.join(', ');

      final genreIndex = genres.indexOf(widget.story!.genre);
      selectedGenre = genreIndex >= 0 ? genreIndex : 0;

      _coverFileName = widget.story!.coverFileName;
      _pdfFileName = widget.story!.pdfFileName;
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _coverBytes = bytes;
          _coverFileName = picked.name;
        });
      }
    } catch (e) {
      log("Cover image pick error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick cover image")),
      );
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not read PDF file")),
          );
          return;
        }

        setState(() {
          _pdfBytes = file.bytes;
          _pdfFileName = file.name;
        });
      }
    } catch (e) {
      log("PDF pick error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to pick PDF")));
    }
  }

  Future<void> _publishStory() async {
    final user = FirebaseAuth.instance.currentUser;
    final title = _titleController.text.trim();
    final genre = genres[selectedGenre];

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter story title")));
      return;
    }

    final hasExistingCover =
        widget.story != null && widget.story!.coverUrl.isNotEmpty;

    final hasExistingPdf =
        widget.story != null && widget.story!.pdfUrl.isNotEmpty;

    if (_coverBytes == null && !hasExistingCover) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a cover image")),
      );
      return;
    }

    if (_pdfBytes == null && !hasExistingPdf) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a PDF file")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final isEditing = widget.story != null;

      final docRef = isEditing
          ? FirebaseFirestore.instance
                .collection('stories')
                .doc(widget.story!.id)
          : FirebaseFirestore.instance.collection('stories').doc();

      final storyId = isEditing ? widget.story!.id : docRef.id;

      final authorName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (user.email?.split('@').first ?? 'User');

      String? coverUrl = isEditing ? widget.story!.coverUrl : null;
      String? pdfUrl = isEditing ? widget.story!.pdfUrl : null;

      if (_coverBytes != null && _coverFileName != null) {
        coverUrl = await CloudinaryService.uploadImage(
          bytes: _coverBytes!,
          fileName: _coverFileName!,
        );
      }

      if (_pdfBytes != null && _pdfFileName != null) {
        pdfUrl = await CloudinaryService.uploadPdf(
          bytes: _pdfBytes!,
          fileName: _pdfFileName!,
        );
      }

      await docRef.set({
        'id': storyId,
        'title': title,
        'genre': genre,
        'tags': tags,
        'coverUrl': coverUrl,
        'pdfUrl': pdfUrl,
        'coverFileName': _coverFileName,
        'pdfFileName': _pdfFileName,
        'authorId': user.uid,
        'authorEmail': user.email,
        'authorName': authorName,
        'status': 'published',
        'format': 'pdf',
        'createdAt': isEditing
            ? widget.story!.createdAt
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "Story updated successfully"
                : "Story published successfully",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      log("Publish story error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Publish failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveDraft() async {
    final user = FirebaseAuth.instance.currentUser;
    final title = _titleController.text.trim();
    final genre = genres[selectedGenre];

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter title before saving draft")),
      );
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('stories').doc();
      final storyId = docRef.id;

      await docRef.set({
        'id': storyId,
        'title': title,
        'genre': genre,
        'tags': tags,
        'coverUrl': null,
        'pdfUrl': null,
        'coverFileName': _coverFileName,
        'pdfFileName': _pdfFileName,
        'authorId': user.uid,
        'authorEmail': user.email,
        'status': 'draft',
        'format': 'pdf',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Draft saved")));
    } catch (e) {
      log("Save draft error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Draft save failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack([
          HStack([
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ).p8().onInkTap(() => Navigator.pop(context)),
            (widget.story != null ? "Edit\nStory" : "NewStory")
                .text
                .white
                .bold
                .xl2
                .make()
                .centered(),
            const Spacer(),
            
            // const Spacer(),
            // "Save\nDraft".text
                // .color(Colors.deepPurpleAccent)
                // .semiBold
                // .make()
                // .p8()
                // .onInkTap(_saveDraft),
          ]).px8(),
          16.heightBox,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              children: [
                "COVER PICTURE".text.color(Colors.white54).sm.semiBold.make(),
                10.heightBox,
                _dashedBox(
                  icon: Icons.image_outlined,
                  title: _coverFileName ?? "Add Cover Photo",
                  subtitle: "JPG / PNG",
                  onTap: _pickCoverImage,
                ),
                20.heightBox,

                "STORY TITLE".text.color(Colors.white54).sm.semiBold.make(),
                10.heightBox,
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your story title...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                20.heightBox,

                HStack([
                  "GENRE".text.color(Colors.white54).sm.semiBold.make(),
                  const Spacer(),
                  "Required".text.color(Colors.deepPurpleAccent).sm.make(),
                ]),
                12.heightBox,

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(genres.length, (i) {
                    final active = i == selectedGenre;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.deepPurpleAccent
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: genres[i].text.white.semiBold.make(),
                    ).onInkTap(() => setState(() => selectedGenre = i));
                  }),
                ),

                22.heightBox,

                "UPLOAD STORY PDF".text
                    .color(Colors.white54)
                    .sm
                    .semiBold
                    .make(),
                10.heightBox,
                _dashedBox(
                  icon: Icons.picture_as_pdf,
                  title: _pdfFileName ?? "Upload Story",
                  subtitle: "PDF only",
                  onTap: _pickPdf,
                ),

                20.heightBox,

                "ADD TAGS".text
                    .color(Colors.deepPurpleAccent)
                    .sm
                    .semiBold
                    .make(),
                10.heightBox,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: TextField(
                    controller: _tagsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "epic, dragons, magic",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                20.heightBox,

                if (_coverFileName != null)
                  "Selected cover: $_coverFileName".text
                      .color(Colors.white70)
                      .sm
                      .make(),

                if (_pdfFileName != null)
                  "Selected PDF: $_pdfFileName".text
                      .color(Colors.white70)
                      .sm
                      .make(),

                20.heightBox,
              ],
            ),
          ),
        ]),
      ),
      bottomSheet: Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: HStack([
          Expanded(
            child:
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HStack([
                    const Icon(Icons.rocket_launch, color: Colors.white),
                    10.widthBox,
                    (_isUploading
                            ? (widget.story != null
                                  ? "Updating..."
                                  : "Publishing...")
                            : (widget.story != null
                                  ? "Update Story"
                                  : "Publish Story"))
                        .text
                        .white
                        .semiBold
                        .make(),
                  ], alignment: MainAxisAlignment.center),
                ).onInkTap(() {
                  if (!_isUploading) {
                    _publishStory();
                  }
                }),
          ),
        ]),
      ),
    );
  }

  Widget _dashedBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: VStack([
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.deepPurple.withOpacity(0.25),
          child: Icon(icon, color: Colors.deepPurpleAccent),
        ),
        10.heightBox,
        title.text.white.semiBold.make(),
        6.heightBox,
        subtitle.text.color(Colors.white54).sm.make(),
      ], alignment: MainAxisAlignment.center),
    ).onInkTap(onTap);
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: text.text.color(Colors.white70).make(),
    );
  }
}
