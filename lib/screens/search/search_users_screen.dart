import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/screens/profile/other_profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String _query = "";
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    setState(() {
      _query = trimmed;
      _loading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(200)
          .get();

      final lower = trimmed.toLowerCase();
      final results = snapshot.docs
          .where((doc) {
            // Exclude current user from results
            if (doc.id == _currentUid) return false;
            if (lower.isEmpty) return true;

            final data = doc.data();
            final name =
                (data['name'] ?? data['fullName'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final username = email.contains('@') ? email.split('@').first : '';
            return name.contains(lower) || username.contains(lower);
          })
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();

      setState(() {
        _users = results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Search failed: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load all users on open
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack([
          // Top row
          HStack([
            Icon(Icons.arrow_back_ios_new, color: Colors.white)
                .p8()
                .onInkTap(() => Navigator.pop(context)),
            6.widthBox,
            "Find People".text.white.bold.xl2.make(),
          ]).px8().py4(),

          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Row(
              children: [
                14.widthBox,
                const Icon(Icons.search, color: Colors.white38),
                10.widthBox,
                Expanded(
                  child: TextField(
                    onChanged: (v) => _search(v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search by name or username…",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                10.widthBox,
              ],
            ),
          ).px16().py12(),

          // Results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: (_query.isEmpty
                                ? "No users yet"
                                : "No results for \"$_query\"")
                            .text
                            .color(Colors.white60)
                            .lg
                            .make(),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => 10.heightBox,
                        itemBuilder: (context, i) {
                          final user = _users[i];
                          return _UserTile(user: user).onInkTap(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtherProfileScreen(
                                  authorId: user['uid'] as String,
                                  authorName: (user['name'] ??
                                          user['fullName'] ??
                                          'Unknown')
                                      .toString(),
                                  authorEmail:
                                      (user['email'] ?? '').toString(),
                                ),
                              ),
                            );
                          });
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name =
        (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final email = (user['email'] ?? '').toString();
    final username =
        email.contains('@') ? '@${email.split('@').first}' : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: HStack([
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accent,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        12.widthBox,
        Expanded(
          child: VStack([
            name.text.white.bold.lg.make(),
            if (username.isNotEmpty) ...[
              4.heightBox,
              username.text.color(Colors.white60).make(),
            ],
          ], crossAlignment: CrossAxisAlignment.start),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
      ]),
    );
  }
}
