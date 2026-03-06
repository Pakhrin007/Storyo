import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/data/users_demo.dart';
import 'package:storyo/screens/profile/other_profile_screen.dart';
import 'package:storyo/screens/profile/profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String q = "";

  @override
  Widget build(BuildContext context) {
    final filtered = demoUsers.where((u) {
      if (q.isEmpty) return true;
      final s = q.toLowerCase();
      return u.fullName.toLowerCase().contains(s) ||
          u.username.toLowerCase().contains(s);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            // Top row (no appbar)
            HStack(
              [
                Icon(Icons.arrow_back_ios_new, color: Colors.white)
                    .p8()
                    .onInkTap(() => Navigator.pop(context)),
                6.widthBox,
                "Search Users".text.white.bold.xl2.make(),
              ],
            ).px8().py4(),

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
                      onChanged: (v) => setState(() => q = v.trim()),
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => 10.heightBox,
                itemBuilder: (context, i) {
                  final user = filtered[i];
                  return _userTile(user).onInkTap(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtherProfileScreen(user: user),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userTile(DemoUser user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: HStack(
        [
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(user.avatarAsset),
          ),
          12.widthBox,
          Expanded(
            child: VStack(
              [
                user.fullName.text.white.bold.lg.make(),
                4.heightBox,
                ("@" + user.username).text.color(Colors.white60).make(),
              ],
              crossAlignment: CrossAxisAlignment.start,
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        ],
      ),
    );
  }
}