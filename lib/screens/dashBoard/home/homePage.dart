import 'package:flutter/material.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/data/home_itemds.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/data/story_data.dart'; // for StoryItem model (reuse)
import 'package:storyo/widgets/bottom_nav.dart';
import 'package:storyo/widgets/featured_card.dart';
import 'package:storyo/widgets/just_added_title.dart';
import 'package:storyo/widgets/search_bar.dart';
import 'package:storyo/widgets/section_header.dart';
import 'package:storyo/widgets/top_bar.dart';
import 'package:storyo/widgets/trending_card.dart';



class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _tabIndex = 0;

  final List<String> _genres = const ["All", "Sci-Fi", "Mystery", "Romance"];
  int _selectedGenre = 0;

  void _openPdf(HomePdfItem item) {
    // ✅ Reuse your StoryItem model for ReaderScreen
    final story = StoryItem(
      id: item.title,
      title: item.title,
      author: item.author,
      genre: "Home",
      coverAsset: item.coverAsset,
      pdfAsset: item.pdfAsset,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(item: story)),
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
              onBellTap: () {},
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  SearchBarWidget(
                    onChanged: (v) {},
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  FeaturedCard(
                    item: featuredItem,
                    onReadNow: () => _openPdf(featuredItem),
                    onBookmark: () {},
                  ),
                  const SizedBox(height: 18),

                  SectionHeader(
                    title: "Explore Genres",
                    actionText: "See all",
                    onAction: () {},
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_genres.length, (i) {
                        final selected = i == _selectedGenre;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: i == _genres.length - 1 ? 0 : 10),
                          child: ChoiceChip(
                            label: Text(_genres[i]),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedGenre = i),
                            labelStyle: TextStyle(
                              color: selected ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedColor: const Color(0xFF1E88FF),
                            backgroundColor: const Color(0xFF1A1A1A),
                            side:
                                BorderSide(color: Colors.white.withOpacity(0.06)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const TextOnlyHeader("Trending Now"),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trendingItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final item = trendingItems[i];
                        return TrendingCard(
                          rank: "${i + 1}",
                          item: item,
                          onTap: () => _openPdf(item),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),
                  const TextOnlyHeader("Just Added"),
                  const SizedBox(height: 10),

                  ...justAddedItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: JustAddedTile(
                          item: item,
                          tag: "Story",
                          onTap: () => _openPdf(item),
                        ),
                      )),

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
          if (i == 3) {
            Navigator.pushNamed(context, MyRoutes.profilePage);
            return;
          }
          if (i == 1) {
            Navigator.pushNamed(context, MyRoutes.explorePage);
            return;
          }
          setState(() => _tabIndex = i);
        },
      ),
    );
  }
}