import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/screens/search/search_users_screen.dart';
import 'package:storyo/screens/story/create_story_screen.dart';
import 'package:storyo/services/follow_service.dart';
import 'package:storyo/services/interaction_service.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  List<StoryModel> stories = [];
  List<StoryModel> likedStories = [];
  List<Map<String, dynamic>> userComments = [];

  String name = "";
  String email = "";
  int _followerCount = 0;
  int _followingCount = 0;

  late final TabController _tabController;

  final FollowService _followService = FollowService();
  final InteractionService _interactionService = InteractionService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  

  Future<void> _deleteStory(StoryModel story) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .delete();

      setState(() {
        stories.removeWhere((s) => s.id == story.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story deleted successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete story: $e")));
    }
  }

  void _showDeleteDialog(StoryModel story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Delete Story",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${story.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStory(story);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    _fullNameController.text = name;
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Edit Profile",
            
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "New Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () async {
                await _updateProfile();
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final newName = _fullNameController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Full name cannot be empty")),
      );
      return;
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password must be at least 6 characters"),
          ),
        );
        return;
      }

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }
    }

    try {
      // Update Firebase Auth display name
      await user.updateDisplayName(newName);

      // Update Firestore users collection
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': newName,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update password only if entered
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      if (!mounted) return;

      Navigator.pop(context);

      setState(() {
        name = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      await _loadProfile();
    } on FirebaseAuthException catch (e) {
      String message = "Profile update failed";

      if (e.code == 'requires-recent-login') {
        message =
            "For security, please log in again before changing your password.";
      } else {
        message = e.message ?? message;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile update failed: $e")));
    }
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
        _interactionService.getLikedStories(user.uid),
        _interactionService.getUserComments(user.uid),
      ]);

      final storySnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final followerCount = results[1] as int;
      final followingCount = results[2] as int;
      final liked = results[3] as List<StoryModel>;
      final comments = results[4] as List<Map<String, dynamic>>;

      final loadedStories = storySnap.docs
          .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      setState(() {
        stories = loadedStories;
        _followerCount = followerCount;
        _followingCount = followingCount;
        likedStories = liked;
        userComments = comments;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load profile: $e")));
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
        child: Column(
          children: [
            // Top row
            HStack([
              Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ).p8().onInkTap(() => Navigator.pop(context)),
              const Spacer(),
              "Profile".text.white.bold.xl2.make(),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.refresh, color: Colors.white70).p8().onInkTap(
                    () async {
                      setState(() {
                        loading = true;
                      });
                      await _loadProfile();
                    },
                  ),
                  Icon(Icons.logout, color: Colors.redAccent).p8().onInkTap(
                    () async {
                      await FirebaseAuth.instance.signOut();

                      if (!context.mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        MyRoutes.loginScreen,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
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

            ("@$username").text
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
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showEditProfileDialog,
                child: Container(
                  height: 42,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: HStack([
                    const Icon(Icons.edit, color: Colors.white, size: 20),
                    15.widthBox,
                    "Edit Profile".text.white.semiBold.make(),
                  ], alignment: MainAxisAlignment.center),
                ),
              ),
            ),
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
                  MaterialPageRoute(builder: (_) => const SearchUsersScreen()),
                ),
                child: Container(
                  height: 52,
                  width: 190,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: HStack([
                    const Icon(
                      Icons.person_search,
                      color: Colors.white70,
                      size: 20,
                    ),
                    8.widthBox,
                    "Find People".text.color(Colors.white70).semiBold.make(),
                  ], alignment: MainAxisAlignment.center),
                ),
              ),
            ),

            16.heightBox,

            

            // Activity tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              indicatorColor: AppColors.accent,
              dividerColor: Colors.white12,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 16),
                      const SizedBox(width: 4),
                      const Text("Stories"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_outline, size: 16),
                      const SizedBox(width: 4),
                      const Text("Liked"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16),
                      const SizedBox(width: 4),
                      const Text("Comments"),
                    ],
                  ),
                ),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 1: My Stories ──────────────────────────────────
                  stories.isEmpty
                      ? Center(
                          child: "No published stories yet".text
                              .color(Colors.white60)
                              .lg
                              .make(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
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
                                      builder: (_) =>
                                          ReaderScreen(story: story),
                                    ),
                                  );
                                },
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white70,
                                  ),
                                  // color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CreateStoryScreen(story: story),
                                        ),
                                      );

                                      if (result == true) {
                                        _loadProfile();
                                      }
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(story);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  // ── Tab 2: Liked Stories ───────────────────────────────
                  likedStories.isEmpty
                      ? Center(
                          child: "No liked stories yet".text
                              .color(Colors.white60)
                              .lg
                              .make(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                          itemCount: likedStories.length,
                          itemBuilder: (context, index) {
                            final story = likedStories[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StoryCard(
                                story: story,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReaderScreen(story: story),
                                    ),
                                  );
                                },
                                trailing: const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),

                  // ── Tab 3: My Comments ─────────────────────────────────
                  userComments.isEmpty
                      ? Center(
                          child: "No comments yet".text
                              .color(Colors.white60)
                              .lg
                              .make(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                          itemCount: userComments.length,
                          itemBuilder: (context, index) {
                            final c = userComments[index];
                            final storyTitle =
                                (c['storyTitle'] as String?) ?? 'Unknown Story';
                            final text = (c['text'] as String?) ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.menu_book_outlined,
                                        color: AppColors.accent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          storyTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child:
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: HStack([
                const Icon(Icons.add, color: Colors.white),
                10.widthBox,
                "Create Story".text.white.bold.xl.make(),
              ], alignment: MainAxisAlignment.center),
            ).onInkTap(() async {
              final result = await Navigator.pushNamed(
                context,
                MyRoutes.createStoryPage,
              );

              if (result == true) {
                setState(() {
                  loading = true;
                });
                await _loadProfile();
              }
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
        child: VStack(
          [
            value.text.white.bold.xl2.make(),
            6.heightBox,
            label.text.color(Colors.white60).sm.make(),
          ],
          alignment: MainAxisAlignment.center,
          crossAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final Widget? trailing;

  const _StoryCard({required this.story, required this.onTap, this.trailing});

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
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            child: Image.network(
              story.coverUrl,
              width: 90,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 90,
                  height: 120,
                  color: Colors.white,
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: VStack([
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                6.heightBox,
                Text(
                  story.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                6.heightBox,
                Text(
                  "Genre: ${story.genre}",
                  style: const TextStyle(color: Colors.white),
                ),
              ], crossAlignment: CrossAxisAlignment.start),
            ),
          ),
        ],
      ),
    ).onInkTap(onTap);
  }
}
