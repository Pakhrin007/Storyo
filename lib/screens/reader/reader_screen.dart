import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/models/comment_model.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/services/interaction_service.dart';

class ReaderScreen extends StatefulWidget {
  final StoryModel story;

  const ReaderScreen({super.key, required this.story});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final InteractionService _service = InteractionService();

  bool _liked = false;
  bool _likeLoading = false;
  int _likeCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInteractionState();
  }

  Future<void> _loadInteractionState() async {
    final results = await Future.wait([
      _service.isLiked(widget.story.id),
      _service.getLikeCount(widget.story.id),
      _service.getCommentCount(widget.story.id),
    ]);
    if (!mounted) return;
    setState(() {
      _liked = results[0] as bool;
      _likeCount = results[1] as int;
      _commentCount = results[2] as int;
    });
  }

  Future<void> _toggleLike() async {
    if (_likeLoading) return;
    final wasLiked = _liked;
    setState(() {
      _likeLoading = true;
      _liked = !wasLiked;
      _likeCount += wasLiked ? -1 : 1;
    });

    try {
      if (wasLiked) {
        await _service.unlikeStory(widget.story.id);
      } else {
        await _service.likeStory(
          storyId: widget.story.id,
          storyTitle: widget.story.title,
          storyCoverUrl: widget.story.coverUrl,
          storyAuthor: widget.story.author,
          storyGenre: widget.story.genre,
          storyPdfUrl: widget.story.pdfUrl,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _liked = wasLiked;
        _likeCount += wasLiked ? 1 : -1;
      });
    } finally {
      if (mounted) setState(() => _likeLoading = false);
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CommentsSheet(
        story: widget.story,
        service: _service,
        onCommentAdded: () {
          if (mounted) setState(() => _commentCount++);
        },
        onCommentDeleted: () {
          if (mounted) setState(() { if (_commentCount > 0) _commentCount--; });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          widget.story.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Like button
          GestureDetector(
            onTap: FirebaseAuth.instance.currentUser != null ? _toggleLike : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? Colors.redAccent : Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_likeCount',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          // Comment button
          GestureDetector(
            onTap: _openComments,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      color: Colors.white70, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    '$_commentCount',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SfPdfViewer.network(widget.story.pdfUrl),
    );
  }
}

// ── Comments Bottom Sheet ───────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final StoryModel story;
  final InteractionService service;
  final VoidCallback onCommentAdded;
  final VoidCallback onCommentDeleted;

  const _CommentsSheet({
    required this.story,
    required this.service,
    required this.onCommentAdded,
    required this.onCommentDeleted,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  final String _currentUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);

    try {
      await widget.service.addComment(
        storyId: widget.story.id,
        storyTitle: widget.story.title,
        text: text,
      );
      _controller.clear();
      widget.onCommentAdded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(CommentModel comment) async {
    try {
      await widget.service.deleteComment(
        storyId: widget.story.id,
        commentId: comment.id,
      );
      widget.onCommentDeleted();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _currentUid.isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Comment list
            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: widget.service.commentsStream(widget.story.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    itemCount: comments.length,
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      final isOwn = c.userId == _currentUid;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accent,
                          radius: 18,
                          child: Text(
                            c.userName.isNotEmpty
                                ? c.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          c.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          c.text,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        trailing: isOwn
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.white38, size: 20),
                                onPressed: () => _delete(c),
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Input row
            if (isLoggedIn)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write a comment…',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.07),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: _submit,
                            icon: const Icon(Icons.send_rounded,
                                color: AppColors.accent),
                          ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Sign in to leave a comment.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
          ],
        );
      },
    );
  }
}
