import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class OtherProfileScreen extends StatefulWidget {
  final String authorId;
  final String authorName;
  final String? authorEmail;

  const OtherProfileScreen({
    super.key,
    required this.authorId,
    required this.authorName,
    this.authorEmail,
  });

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  List<StoryModel> stories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthorStories();
  }

  Future<void> _loadAuthorStories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('authorId', isEqualTo: widget.authorId)
          .where('status', isEqualTo: 'published')
          .orderBy('createdAt', descending: true)
          .get();

      final loadedStories = snapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      setState(() {
        stories = loadedStories;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load author profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.authorEmail ?? "";
    final username = email.isNotEmpty && email.contains('@')
        ? email.split('@').first
        : widget.authorName.toLowerCase().replaceAll(" ", "_");

    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                "Profile".text.white.bold.xl2.make(),
              ],
            ).px8().py4(),

            16.heightBox,

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.08),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.accent,
                child: Text(
                  widget.authorName.isNotEmpty
                      ? widget.authorName[0].toUpperCase()
                      : "A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).centered(),

            14.heightBox,

            widget.authorName.text.white.bold.xl3.make().centered(),
            6.heightBox,
            ("@$username").text.color(AppColors.accent).semiBold.lg.make().centered(),

            if (email.isNotEmpty) ...[
              8.heightBox,
              email.text.color(Colors.white60).make().centered(),
            ],

            20.heightBox,

            HStack([
              _countBox(stories.length.toString(), "STORIES"),
            ]).px16(),

            20.heightBox,

            "Stories".text.white.bold.xl2.make().px16(),
            12.heightBox,

            Expanded(
              child: stories.isEmpty
                  ? Center(
                      child: "No published stories yet"
                          .text
                          .color(Colors.white60)
                          .lg
                          .make(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StoryCard(
                            story: story,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReaderScreen(story: story),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countBox(String value, String label) {
    return Expanded(
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: VStack(
          [
            value.text.white.bold.xl2.make(),
            6.heightBox,
            label.text.color(Colors.white60).sm.make(),
          ],
          alignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Image.network(
              story.coverUrl,
              width: 90,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 90,
                  height: 120,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: VStack(
                [
                  Text(
                    story.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  6.heightBox,
                  Text(
                    story.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60),
                  ),
                  6.heightBox,
                  Text(
                    "Genre: ${story.genre}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
                crossAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
        ],
      ),
    ).onInkTap(onTap);
  }
}