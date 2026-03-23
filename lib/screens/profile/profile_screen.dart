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
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _deleteStory(StoryModel story) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .delete();
      setState(() => stories.removeWhere((s) => s.id == story.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar("Story deleted successfully"),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Failed to delete story: $e", error: true));
    }
  }

  SnackBar _snackBar(String msg, {bool error = false}) {
    return SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? Colors.redAccent.shade200 : const Color(0xFF1E88FF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showDeleteDialog(StoryModel story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Story",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'libertin',
                fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${story.title}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStory(story);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.redAccent)),
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'libertin',
                fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(_fullNameController, "Full Name"),
              const SizedBox(height: 14),
              _dialogField(_newPasswordController, "New Password",
                  obscure: true),
              const SizedBox(height: 14),
              _dialogField(_confirmPasswordController, "Confirm Password",
                  obscure: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _updateProfile,
            child: const Text("Save",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = _fullNameController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Full name cannot be empty", error: true));
      return;
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackBar("Password must be at least 6 characters", error: true));
        return;
      }
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snackBar("Passwords do not match", error: true));
        return;
      }
    }

    try {
      await user.updateDisplayName(newName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': newName,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (newPassword.isNotEmpty) await user.updatePassword(newPassword);

      if (!mounted) return;
      Navigator.pop(context);
      setState(() => name = newName);
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Profile updated successfully"));
      await _loadProfile();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'requires-recent-login'
          ? "Please log in again before changing your password."
          : e.message ?? "Profile update failed";
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(msg, error: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Profile update failed: $e", error: true));
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      email = user.email ?? "";

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        name =
            (data['name'] ?? data['fullName'] ?? user.displayName ?? "")
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
      setState(() {
        stories = storySnap.docs
            .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
            .toList();
        _followerCount = results[1] as int;
        _followingCount = results[2] as int;
        likedStories = results[3] as List<StoryModel>;
        userComments = results[4] as List<Map<String, dynamic>>;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Failed to load profile: $e", error: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0C0F),
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF1E88FF), strokeWidth: 2.5),
        ),
      );
    }

    final username = email.isNotEmpty && email.contains('@')
        ? email.split('@').first
        : name.toLowerCase().replaceAll(" ", "_");

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(child: _buildHeader(username)),
                ],
                body: Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _storiesTab(),
                          _likedTab(),
                          _commentsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildCreateButton(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'libertin',
              fontSize: 22,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: Colors.white.withOpacity(0.6), size: 22),
            onPressed: () async {
              setState(() => loading = true);
              await _loadProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 22),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, MyRoutes.loginScreen, (r) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'libertin',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'libertin',
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "@$username",
            style: const TextStyle(
              color: Color(0xFF1E88FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _statBox(_followerCount.toString(), "Followers"),
              const SizedBox(width: 10),
              _statBox(_followingCount.toString(), "Following"),
              const SizedBox(width: 10),
              _statBox(stories.length.toString(), "Stories"),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: "Edit Profile",
                  icon: Icons.edit_outlined,
                  primary: true,
                  onTap: _showEditProfileDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  label: "Find People",
                  icon: Icons.person_search_outlined,
                  primary: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SearchUsersScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'libertin',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: primary
              ? AppColors.accent
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: primary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: primary ? Colors.white : Colors.white60, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: primary ? Colors.white : Colors.white60,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white30,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.white.withOpacity(0.06),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        fontFamily: 'libertin',
      ),
      tabs: const [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, size: 15),
              SizedBox(width: 5),
              Text("Stories"),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline, size: 15),
              SizedBox(width: 5),
              Text("Liked"),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 15),
              SizedBox(width: 5),
              Text("Comments"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _storiesTab() {
    if (stories.isEmpty) return _emptyState("No published stories yet");
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final story = stories[i];
        return _StoryCard(
          story: story,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ReaderScreen(story: story))),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: Colors.white.withOpacity(0.5), size: 20),
            color: const Color(0xFF1A1A22),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreateStoryScreen(story: story)),
                );
                if (result == true) _loadProfile();
              } else if (value == 'delete') {
                _showDeleteDialog(story);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child:
                    Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _likedTab() {
    if (likedStories.isEmpty) return _emptyState("No liked stories yet");
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: likedStories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final story = likedStories[i];
        return _StoryCard(
          story: story,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ReaderScreen(story: story))),
          trailing: const Icon(Icons.favorite_rounded,
              color: Colors.redAccent, size: 18),
        );
      },
    );
  }

  Widget _commentsTab() {
    if (userComments.isEmpty) return _emptyState("No comments yet");
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: userComments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = userComments[i];
        final storyTitle = (c['storyTitle'] as String?) ?? 'Unknown Story';
        final text = (c['text'] as String?) ?? '';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_outlined,
                      color: Color(0xFF1E88FF), size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      storyTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E88FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined,
              color: Colors.white12, size: 48),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 14,
              fontFamily: 'libertin',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      color: const Color(0xFF0C0C0F),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: GestureDetector(
        onTap: () async {
          final result =
              await Navigator.pushNamed(context, MyRoutes.createStoryPage);
          if (result == true) {
            setState(() => loading = true);
            await _loadProfile();
          }
        },
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E88FF),
                const Color(0xFF1E88FF).withOpacity(0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88FF).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                "Create Story",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'libertin',
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final Widget? trailing;

  const _StoryCard(
      {required this.story, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18)),
              child: Container(
                width: 86,
                height: 116,
                color: Colors.white.withOpacity(0.04),
                child: story.coverUrl.isNotEmpty
                    ? Image.network(
                        story.coverUrl,
                        width: 86,
                        height: 116,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _coverFallback(),
                      )
                    : _coverFallback(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'libertin',
                            ),
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      story.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1E88FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF1E88FF)
                                .withOpacity(0.2)),
                      ),
                      child: Text(
                        story.genre,
                        style: const TextStyle(
                          color: Color(0xFF1E88FF),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback() {
    return Center(
      child: Icon(Icons.auto_stories_outlined,
          color: Colors.white.withOpacity(0.2), size: 28),
    );
  }
}