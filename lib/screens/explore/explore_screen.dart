import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/data/story_data.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String query = "";

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    for (final s in stories) {
      precacheImage(AssetImage(s.coverAsset), context);
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: genres.length,
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        body: SafeArea(
          child: VStack(
            [
              // Header Row
              HStack(
                [
                  "Explore".text.white.bold.xl5.textStyle(TextStyle(fontFamily: 'libertin')).make(),
                  const Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ],
              ).px16().py12(),

              // Search bar
              _searchBar().px16(),
              16.heightBox,

              // Tabs
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
                    .map((g) => Tab(child: g.text.semiBold.lg.textStyle(TextStyle(fontFamily: 'libertin')).make().px16().py8()))
                    .toList(),
              ).px12(),

              18.heightBox,

              // Section title
              HStack(
                [
                  "Discover New Stories".text.white.bold.xl2.textStyle(TextStyle(fontFamily: 'libertin')).make(),
                  const Spacer(),
                  "See all".text.color(AppColors.accent).semiBold.lg.make(),
                ],
              ).px16(),

              14.heightBox,

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _storyCard(filtered[i]),
    );
  }

  Widget _storyCard(StoryItem item) {
    return VStack(
      [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                item.coverAsset,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: CircleAvatar(
            //     radius: 18,
            //     backgroundColor: Colors.black.withOpacity(0.35),
            //     child: const Icon(Icons.bookmark_border, color: Colors.white, size: 18),
            //   ),
            // ),
          ],
        ),
        12.heightBox,
        item.title.text.white.bold.xl.textStyle(TextStyle(fontFamily: 'libertin')).make(),
        6.heightBox,
        item.author.text.color(Colors.white60).lg.make(),
      ],
      crossAlignment: CrossAxisAlignment.start,
    ).onInkTap(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReaderScreen(item: item)),
      );
    });
  }
}