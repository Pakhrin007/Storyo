import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/screens/reader/reader_screen.dart';
import 'package:storyo/services/follow_service.dart';

class OtherProfileScreen extends StatefulWidget {
  final String authorId;
  final String authorName;
  final String? authorEmail;

  const OtherProfileScreen({
    super.key,
    required this.authorId,
    required this.authorName,
    this.authorEmail,
  });

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FollowService _followService = FollowService();

  List<StoryModel> stories = [];
  bool loading = true;
  bool _followLoading = false;
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;

  final String _currentUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        _followService.isFollowing(widget.authorId),
        _followService.getFollowerCount(widget.authorId),
        _followService.getFollowingCount(widget.authorId),
        FirebaseFirestore.instance
            .collection('stories')
            .where('authorId', isEqualTo: widget.authorId)
            .where('status', isEqualTo: 'published')
            .orderBy('createdAt', descending: true)
            .get(),
      ]);

      setState(() {
        _isFollowing = results[0] as bool;
        _followerCount = results[1] as int;
        _followingCount = results[2] as int;
        stories = (results[3] as QuerySnapshot<Map<String, dynamic>>)
            .docs
            .map((doc) => StoryModel.fromFirestore(doc.data(), doc.id))
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar("Failed to load profile: $e", error: true),
      );
    }
  }

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    setState(() => _followLoading = true);

    try {
      if (_isFollowing) {
        await _followService.unfollowUser(targetUid: widget.authorId);
        setState(() {
          _isFollowing = false;
          _followerCount = (_followerCount - 1).clamp(0, _followerCount);
        });
      } else {
        await _followService.followUser(
          targetUid: widget.authorId,
          targetName: widget.authorName,
        );
        setState(() {
          _isFollowing = true;
          _followerCount += 1;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Action failed: $e", error: true));
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<void> _deleteStory(StoryModel story) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .delete();
      setState(() => stories.removeWhere((s) => s.id == story.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Story deleted successfully"));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar("Failed to delete: $e", error: true));
    }
  }

  void _showDeleteDialog(StoryModel story) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Story",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'libertin',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${story.title}"?',
          style: TextStyle(
              color: Colors.white.withOpacity(0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: Colors.white54)),
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

  SnackBar _snackBar(String msg, {bool error = false}) {
    return SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? Colors.redAccent.shade200 : const Color(0xFF1E88FF),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.authorEmail ?? "";
    final username = email.isNotEmpty && email.contains('@')
        ? email.split('@').first
        : widget.authorName.toLowerCase().replaceAll(" ", "_");
    final isOwnProfile = _currentUid == widget.authorId;

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0C0F),
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF1E88FF), strokeWidth: 2.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(
                        username, email, isOwnProfile),
                  ),
                  _buildStoriesHeader(),
                  stories.isEmpty
                      ? SliverFillRemaining(
                          child: _emptyState(),
                        )
                      : SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final story = stories[i];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: _StoryCard(
                                    story: story,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ReaderScreen(story: story),
                                      ),
                                    ),
                                    trailing: isOwnProfile
                                        ? PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert,
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                size: 20),
                                            color:
                                                const Color(0xFF1A1A22),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                _showDeleteDialog(story);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .redAccent)),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                );
                              },
                              childCount: stories.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(
      String username, String email, bool isOwnProfile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 92,
            height: 92,
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
                widget.authorName.isNotEmpty
                    ? widget.authorName[0].toUpperCase()
                    : "A",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'libertin',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.authorName,
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

          // Follow button
          if (!isOwnProfile)
            GestureDetector(
              onTap: _followLoading ? null : _toggleFollow,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isFollowing
                      ? Colors.white.withOpacity(0.07)
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                  border: _isFollowing
                      ? Border.all(
                          color: Colors.white.withOpacity(0.12))
                      : null,
                  boxShadow: _isFollowing
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: _followLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFollowing
                                  ? Icons.person_remove_outlined
                                  : Icons.person_add_outlined,
                              color: _isFollowing
                                  ? Colors.white60
                                  : Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isFollowing ? "Unfollow" : "Follow",
                              style: TextStyle(
                                color: _isFollowing
                                    ? Colors.white60
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                fontFamily: 'libertin',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

          const SizedBox(height: 24),
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
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
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

  SliverToBoxAdapter _buildStoriesHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88FF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Stories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'libertin',
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined,
              color: Colors.white12, size: 48),
          const SizedBox(height: 14),
          Text(
            "No published stories yet",
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
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
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
                        color: const Color(0xFF1E88FF).withOpacity(0.1),
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