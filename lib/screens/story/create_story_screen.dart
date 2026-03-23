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

class CreateStoryScreen extends StatefulWidget {
  final StoryModel? story;

  const CreateStoryScreen({super.key, this.story});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  int selectedGenre = 0;

  final genres = [
    "Fantasy",
    "Sci-Fi",
    "Mystery",
    "Romance",
    "Thriller",
    "Horror",
    "Adventure",
    "Drama",
    "Crime",
    "Comedy",
    "Historical",
    "Action",
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Uint8List? _coverBytes;
  String? _coverFileName;

  Uint8List? _pdfBytes;
  String? _pdfFileName;

  bool _isUploading = false;

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

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked =
          await picker.pickImage(source: ImageSource.gallery);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Failed to pick cover image", error: true));
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
          ScaffoldMessenger.of(context)
              .showSnackBar(_snackBar("Could not read PDF file", error: true));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Failed to pick PDF", error: true));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Please login first", error: true));
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Please enter a story title", error: true));
      return;
    }

    final hasExistingCover =
        widget.story != null && widget.story!.coverUrl.isNotEmpty;
    final hasExistingPdf =
        widget.story != null && widget.story!.pdfUrl.isNotEmpty;

    if (_coverBytes == null && !hasExistingCover) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Please select a cover image", error: true));
      return;
    }
    if (_pdfBytes == null && !hasExistingPdf) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Please select a PDF file", error: true));
      return;
    }

    setState(() => _isUploading = true);

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
            bytes: _coverBytes!, fileName: _coverFileName!);
      }
      if (_pdfBytes != null && _pdfFileName != null) {
        pdfUrl = await CloudinaryService.uploadPdf(
            bytes: _pdfBytes!, fileName: _pdfFileName!);
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
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(
          isEditing
              ? "Story updated successfully"
              : "Story published successfully"));
      Navigator.pop(context, true);
    } catch (e) {
      log("Publish story error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Publish failed: $e", error: true));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  SnackBar _snackBar(String msg, {bool error = false}) {
    return SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? Colors.redAccent.shade200 : const Color(0xFF1E88FF),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.story != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isEditing),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  _sectionLabel("Cover Picture"),
                  const SizedBox(height: 10),
                  _uploadBox(
                    icon: Icons.image_outlined,
                    title: _coverFileName ?? "Add Cover Photo",
                    subtitle: "JPG or PNG",
                    isSelected: _coverFileName != null,
                    onTap: _pickCoverImage,
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel("Story Title"),
                  const SizedBox(height: 10),
                  _titleField(),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _sectionLabel("Genre"),
                      const Spacer(),
                      const Text(
                        "Required",
                        style: TextStyle(
                          color: Color(0xFF1E88FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _genreChips(),
                  const SizedBox(height: 24),

                  _sectionLabel("Upload Story PDF"),
                  const SizedBox(height: 10),
                  _uploadBox(
                    icon: Icons.picture_as_pdf_outlined,
                    title: _pdfFileName ?? "Upload PDF",
                    subtitle: "PDF only",
                    isSelected: _pdfFileName != null,
                    onTap: _pickPdf,
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel("Tags"),
                  const SizedBox(height: 10),
                  _tagsField(),
                  const SizedBox(height: 8),
                  Text(
                    "Separate tags with commas  •  e.g. epic, dragons, magic",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(isEditing),
    );
  }

  Widget _buildTopBar(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            isEditing ? 'Edit Story' : 'New Story',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'libertin',
              fontSize: 22,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _uploadBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E88FF).withOpacity(0.07)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E88FF).withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E88FF).withOpacity(0.15)
                    : AppColors.accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_circle_outline_rounded : icon,
                color: isSelected
                    ? const Color(0xFF1E88FF)
                    : AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected ? "Tap to replace" : subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: "Enter your story title…",
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _genreChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(genres.length, (i) {
        final active = i == selectedGenre;
        return GestureDetector(
          onTap: () => setState(() => selectedGenre = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accent
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.08),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Text(
              genres[i],
              style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _tagsField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _tagsController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "epic, dragons, magic…",
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          prefixIcon: Icon(Icons.label_outline_rounded,
              color: Colors.white.withOpacity(0.3), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      color: const Color(0xFF0C0C0F),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: GestureDetector(
        onTap: _isUploading ? null : _publishStory,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _isUploading
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF1E88FF), Color(0xFF1565C0)],
                  ),
            color: _isUploading ? Colors.white10 : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isUploading
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF1E88FF).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: _isUploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEditing
                            ? Icons.check_rounded
                            : Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEditing ? "Update Story" : "Publish Story",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'libertin',
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}