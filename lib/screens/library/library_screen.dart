import 'package:flutter/material.dart';
import 'package:storyo/core/routes.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0;

  final List<Map<String, String>> allStories = const [
    {
      "title": "The Midnight Library",
      "author": "Matt Haig",
      "time": "Last read 2 hours ago",
    },
    {
      "title": "The Alchemist",
      "author": "Paulo Coelho",
      "time": "Last read yesterday",
    },
    {
      "title": "Normal People",
      "author": "Sally Rooney",
      "time": "Last read 3 days ago",
    },
    {
      "title": "Deep Work",
      "author": "Cal Newport",
      "time": "Last read Dec 12",
    },
  ];

  final List<Map<String, String>> favoriteStories = const [
    {
      "title": "The Silent Patient",
      "author": "Alex Michaelides",
      "time": "Added to favorites",
    },
    {
      "title": "Atomic Habits",
      "author": "James Clear",
      "time": "Added to favorites",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0 ? allStories : favoriteStories;

    return Scaffold(
      backgroundColor: Colors.black,
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
          'Library',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TopTabButton(
                    title: "All Stories",
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 24),
                  _TopTabButton(
                    title: "Favorites",
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search, color: Colors.white38, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search your library...",
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _selectedTab == 0 ? "Continue Reading" : "Favorites",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _selectedTab == 0 ? "SORT BY RECENT" : "SORT BY NAME",
                    style: const TextStyle(
                      color: Color(0xFF1E88FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: currentList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = currentList[index];
                  return _LibraryBookTile(
                    title: item["title"] ?? "",
                    author: item["author"] ?? "",
                    timeText: item["time"] ?? "",
                    colorIndex: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _LibraryBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, MyRoutes.homePage);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, MyRoutes.explorePage);
          } else if (index == 2) {
            // already here
          } else if (index == 3) {
            Navigator.pushNamed(context, MyRoutes.settingsScreen);
          }
        },
      ),
    );
  }
}

class _TopTabButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TopTabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? const Color(0xFF1E88FF) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2.5,
            width: 70,
            color: selected ? const Color(0xFF1E88FF) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _LibraryBookTile extends StatelessWidget {
  final String title;
  final String author;
  final String timeText;
  final int colorIndex;

  const _LibraryBookTile({
    required this.title,
    required this.author,
    required this.timeText,
    required this.colorIndex,
  });

  Color _coverColor() {
    const colors = [
      Color(0xFFE8DDC7),
      Color(0xFFD9D7C8),
      Color(0xFF2F7F73),
      Color(0xFFD7CCAF),
    ];
    return colors[colorIndex % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 76,
          height: 102,
          decoration: BoxDecoration(
            color: _coverColor(),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 42,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                author,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.watch_later_outlined,
                    color: Colors.white38,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: 22,
        ),
      ],
    );
  }
}

class _LibraryBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LibraryBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0B0B0B),
      selectedItemColor: const Color(0xFF1E88FF),
      unselectedItemColor: Colors.white38,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: "Library",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: "Settings",
        ),
      ],
    );
  }
}