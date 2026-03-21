import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/services/reading_progress_service.dart';
import 'package:velocity_x/velocity_x.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String query = "";
  List<StoryModel> stories = [];
  List<String> genres = [];
  bool loading = true;

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('status', isEqualTo: 'published')
          .get();

      final loadedStories = snapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      final genreSet = <String>{};
      for (final story in loadedStories) {
        if (story.genre.trim().isNotEmpty) {
          genreSet.add(story.genre);
        }
      }

      if (!mounted) return;

      setState(() {
        stories = loadedStories;
        genres = genreSet.toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load stories: $e")));
    }
  }

  Future<void> _openStory(StoryModel item) async {
    try {
      await _readingProgressService.saveContinueReading(
        storyId: item.id,
        title: item.title,
        authorName: item.author,
        coverUrl: item.coverUrl,
        pdfUrl: item.pdfUrl,
        genre: item.genre,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReaderScreen(story: item)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to open story: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (genres.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: const Text(
            'Explore',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: Text(
            "No stories found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: genres.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: const Text(
            'Explore',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: AppColors.secondary,
        body: SafeArea(
          child: VStack([
            _searchBar().px16(),
            16.heightBox,
            TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(22),
              ),
              tabs: genres
                  .map(
                    (g) => Tab(
                      child: g.text.semiBold.lg
                          .textStyle(const TextStyle(fontFamily: 'libertin'))
                          .make()
                          .px16()
                          .py8(),
                    ),
                  )
                  .toList(),
            ).px12(),
            18.heightBox,

            14.heightBox,
            Expanded(
              child: TabBarView(
                children: genres.map((g) => _gridForGenre(g)).toList(),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search stories, authors, or genres...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.75)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _gridForGenre(String genre) {
    final filtered = stories.where((s) {
      if (s.genre != genre) return false;
      if (query.isEmpty) return true;

      return s.title.toLowerCase().contains(query) ||
          s.author.toLowerCase().contains(query) ||
          s.genre.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No stories found in this genre",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 16,
        childAspectRatio: 0.50,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _storyCard(filtered[i]),
    );
  }

  Widget _storyCard(StoryModel item) {
    return VStack([
      Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              item.coverUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      12.heightBox,
      item.title.text.white.bold.xl
          .textStyle(const TextStyle(fontFamily: 'libertin'))
          .make(),
      6.heightBox,
      item.author.text.color(Colors.white60).lg.make(),
    ], crossAlignment: CrossAxisAlignment.start).onInkTap(() async {
      await _openStory(item);
    });
  }
}
