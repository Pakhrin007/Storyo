import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/widgets/bottom_nav.dart';
import 'package:storyo/widgets/search_bar.dart';
import 'package:storyo/widgets/top_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _tabIndex = 0;

  bool loading = true;

  List<String> preferredGenres = [];
  List<StoryModel> allStories = [];

  Map<String, List<StoryModel>> genreStories = {};

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  Future<void> loadHome() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        final data = userDoc.data();
        final prefs = data?["readingPreferences"];

        if (prefs is List) {
          preferredGenres = prefs.map((e) => e.toString()).toList();
        }
      }

      final storySnap = await FirebaseFirestore.instance
          .collection("stories")
          .where("status", isEqualTo: "published")
          .get();

      final stories = storySnap.docs
          .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      allStories = stories;

      Map<String, List<StoryModel>> map = {};

      for (var genre in preferredGenres) {
        map[genre] = stories
            .where((s) =>
                s.genre.trim().toLowerCase() ==
                genre.trim().toLowerCase())
            .toList();
      }

      setState(() {
        genreStories = map;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void openStory(StoryModel story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onAvatarTap: () => setState(() => _tabIndex = 3),
              onBellTap: () {
                Navigator.pushNamed(context, MyRoutes.notificationsPage);
              },
            ),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      children: [
                        SearchBarWidget(onChanged: (v) {}, onTap: () {}),
                        const SizedBox(height: 20),

                        const Text(
                          "Recommended for You",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allStories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final story = allStories[i];
                              return StoryCard(
                                story: story,
                                onTap: () => openStory(story),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 28),

                        ...preferredGenres.map((genre) {
                          final stories = genreStories[genre] ?? [];

                          if (stories.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$genre Picks",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                height: 220,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, i) {
                                    final story = stories[i];

                                    return StoryCard(
                                      story: story,
                                      onTap: () => openStory(story),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 28),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 90),
                      ],
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNav(
        index: _tabIndex,
        onChanged: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, MyRoutes.explorePage);
            return;
          }

          if (i == 2) {
            Navigator.pushNamed(context, MyRoutes.libraryPage);
            return;
          }

          if (i == 3) {
            Navigator.pushNamed(context, MyRoutes.profilePage);
            return;
          }

          setState(() => _tabIndex = i);
        },
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                story.coverUrl,
                height: 160,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  width: 150,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              story.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}