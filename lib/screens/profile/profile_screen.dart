import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/screens/search/search_users_screen.dart';
import 'package:storyo/services/follow_service.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  List<StoryModel> stories = [];

  String name = "";
  String email = "";
  int _followerCount = 0;
  int _followingCount = 0;

  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      email = user.email ?? "";

      // Try getting extra user info from Firestore users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        name = (data['name'] ?? data['fullName'] ?? user.displayName ?? "")
            .toString();
        email = (data['email'] ?? user.email ?? "").toString();
      } else {
        name = user.displayName ?? "User";
      }

      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('stories')
            .where('authorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'published')
            .orderBy('createdAt', descending: true)
            .get(),
        _followService.getFollowerCount(user.uid),
        _followService.getFollowingCount(user.uid),
      ]);

      final storySnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final followerCount = results[1] as int;
      final followingCount = results[2] as int;

      final loadedStories = storySnap.docs
          .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      setState(() {
        stories = loadedStories;
        _followerCount = followerCount;
        _followingCount = followingCount;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = email.isNotEmpty && email.contains('@')
        ? email.split('@').first
        : name.toLowerCase().replaceAll(" ", "_");

    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack([
          // Top row
          HStack([
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ).p8().onInkTap(() => Navigator.pop(context)),
            const Spacer(),
            "Profile".text.white.bold.xl2.make(),
            const Spacer(),
            Icon(Icons.settings, color: Colors.white70).p8().onInkTap(() {
              Navigator.pushNamed(context, MyRoutes.settingsScreen);
            }),
          ]).px8().py4(),

          12.heightBox,

          // Avatar
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white.withOpacity(0.08),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.accent,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).centered(),

          16.heightBox,

          name.text.white.bold.xl3.make().centered(),
          6.heightBox,

          ("@$username")
              .text
              .color(AppColors.accent)
              .semiBold
              .lg
              .make()
              .centered(),

          if (email.isNotEmpty) ...[
            8.heightBox,
            email.text.color(Colors.white60).make().centered(),
          ],

          20.heightBox,

          // Stats row: followers | following | stories
          HStack([
            _statBox(_followerCount.toString(), "FOLLOWERS"),
            8.widthBox,
            _statBox(_followingCount.toString(), "FOLLOWING"),
            8.widthBox,
            _statBox(stories.length.toString(), "STORIES"),
          ]).px16(),

          12.heightBox,

          // Find People button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchUsersScreen(),
                ),
              ),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: HStack(
                  [
                    const Icon(Icons.person_search,
                        color: Colors.white70, size: 20),
                    8.widthBox,
                    "Find People".text.color(Colors.white70).semiBold.make(),
                  ],
                  alignment: MainAxisAlignment.center,
                ),
              ),
            ),
          ),

          20.heightBox,

          "My Stories".text.white.bold.xl2.make().px16(),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
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
        ]),
      ),

      bottomSheet: Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: HStack(
            [
              const Icon(Icons.add, color: Colors.white),
              10.widthBox,
              "Create Story".text.white.bold.xl.make(),
            ],
            alignment: MainAxisAlignment.center,
          ),
        ).onInkTap(() {
          Navigator.pushNamed(context, MyRoutes.createStoryPage);
        }),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: VStack([
          value.text.white.bold.xl2.make(),
          6.heightBox,
          label.text.color(Colors.white60).sm.make(),
        ], alignment: MainAxisAlignment.center),
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
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
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