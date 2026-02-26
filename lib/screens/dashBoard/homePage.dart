import 'package:flutter/material.dart';
import 'package:storyo/core/routes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _tabIndex = 0;

  final List<String> _genres = const ["All", "Sci-Fi", "Mystery", "Romance"];
  int _selectedGenre = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onAvatarTap: () {
                // Option A: go to profile tab
                setState(() => _tabIndex = 3);

                // Option B: if you have a Profile route later, use:
                // Navigator.pushNamed(context, MyRoutes.profileScreen);
              },
              onBellTap: () {},
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  _SearchBar(
                    onChanged: (v) {},
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),

                  _FeaturedCard(
                    onReadNow: () {},
                    onBookmark: () {},
                  ),
                  const SizedBox(height: 18),

                  _SectionHeader(
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
                          padding: EdgeInsets.only(right: i == _genres.length - 1 ? 0 : 10),
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
                            side: BorderSide(color: Colors.white.withOpacity(0.06)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _TextOnlyHeader("Trending Now"),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _TrendingCard(
                          rank: "7",
                          title: "Beyond the Horizon",
                          author: "Marcus Aurel",
                          minutes: "12 min",
                        ),
                        SizedBox(width: 12),
                        _TrendingCard(
                          rank: "2",
                          title: "Warped Reality",
                          author: "Sara K.",
                          minutes: "8 min",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _TextOnlyHeader("Just Added"),
                  const SizedBox(height: 10),

                  const _JustAddedTile(
                    title: "Silicon Souls",
                    author: "R.H. Miller",
                    tag: "Sci-Fi",
                    minutes: "10 MIN READ",
                  ),
                  const SizedBox(height: 10),
                  const _JustAddedTile(
                    title: "Midnight in Kyoto",
                    author: "Hana Sato",
                    tag: "Travel Story",
                    minutes: "15 MIN READ",
                  ),
                  const SizedBox(height: 90), // space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E88FF),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),

      bottomNavigationBar: _BottomNav(
        index: _tabIndex,
        onChanged: (i) {
          if (i == 3) {
            Navigator.pushNamed(context, MyRoutes.settingsScreen);
            return;
          }
          setState(() => _tabIndex = i);
        },
      ),
    );
  }
}

/* ---------------- UI widgets ---------------- */

class _TopBar extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final VoidCallback onBellTap;

  const _TopBar({required this.onAvatarTap, required this.onBellTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1E88FF),
              child: const Text(
                "S",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Storyo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onBellTap,
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  const _SearchBar({required this.onChanged, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              onTap: onTap,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search stories, authors, or genres…",
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final VoidCallback onReadNow;
  final VoidCallback onBookmark;

  const _FeaturedCard({required this.onReadNow, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage("assets/home/featured.jpg"), // put any image here
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.80),
              Colors.black.withOpacity(0.10),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "FEATURED STORY",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "The Echo of Silence",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "by Elena Vance • 15 min read",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReadNow,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("Read Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onBookmark,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(actionText, style: const TextStyle(color: Color(0xFF1E88FF), fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _TextOnlyHeader extends StatelessWidget {
  final String text;
  const _TextOnlyHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String rank;
  final String title;
  final String author;
  final String minutes;

  const _TrendingCard({
    required this.rank,
    required this.title,
    required this.author,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Stack(
        children: [
          // placeholder image area
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: const DecorationImage(
                image: AssetImage("assets/home/trending1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 58,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(rank, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("$author • $minutes", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _JustAddedTile extends StatelessWidget {
  final String title;
  final String author;
  final String tag;
  final String minutes;

  const _JustAddedTile({
    required this.title,
    required this.author,
    required this.tag,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.08),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.white38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("$author • $tag", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 6),
                Text(minutes, style: const TextStyle(color: Color(0xFF1E88FF), fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white38),
          )
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onChanged,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0B0B0B),
      selectedItemColor: const Color(0xFF1E88FF),
      unselectedItemColor: Colors.white38,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Library"),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded),label: "Settings",
),
      ],
    );
  }
}