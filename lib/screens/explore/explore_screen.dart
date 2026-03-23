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

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load stories: $e"),
          backgroundColor: Colors.redAccent.shade200,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to open story: $e"),
          backgroundColor: Colors.redAccent.shade200,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Finding stories…',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (genres.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined,
                  color: Colors.white24, size: 52),
              const SizedBox(height: 16),
              const Text(
                "No stories available yet",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  fontFamily: 'libertin',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: genres.length,
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _searchBar(),
              ),
              const SizedBox(height: 20),
              _genreTabs(),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  children: genres.map((g) => _gridForGenre(g)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: true,
      title: const Text(
        'Explore',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: 'libertin',
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search stories, authors, genres…",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.4), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _genreTabs() {
    return TabBar(
      isScrollable: true,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accent.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      labelStyle: const TextStyle(
        fontFamily: 'libertin',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'libertin',
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      tabs: genres
          .map(
            (g) => Tab(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(g),
              ),
            ),
          )
          .toList(),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            const Text(
              "No stories found",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontFamily: 'libertin',
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.50,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _storyCard(filtered[i]),
    );
  }

  Widget _storyCard(StoryModel item) {
    return GestureDetector(
      onTap: () => _openStory(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.coverUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.06),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        color: Colors.white24,
                        size: 36,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'libertin',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}