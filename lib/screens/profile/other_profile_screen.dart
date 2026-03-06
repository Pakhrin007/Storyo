import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/data/users_demo.dart';
import 'package:velocity_x/velocity_x.dart';

class OtherProfileScreen extends StatefulWidget {
  final DemoUser user;
  const OtherProfileScreen({super.key, required this.user});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            // top row (no appbar)
            HStack(
              [
                Icon(Icons.arrow_back_ios_new, color: Colors.white)
                    .p8()
                    .onInkTap(() => Navigator.pop(context)),
                6.widthBox,
                "Profile".text.white.bold.xl2.make(),
              ],
            ).px8().py4(),

            16.heightBox,

            // avatar
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white.withOpacity(0.08),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage(u.avatarAsset),
              ),
            ).centered(),

            14.heightBox,

            u.fullName.text.white.bold.xl4.make().centered(),
            6.heightBox,
            ("@" + u.username).text.color(AppColors.accent).semiBold.lg.make().centered(),

            12.heightBox,

            u.bio.text.color(Colors.white60).align(TextAlign.center).make().px24(),

            18.heightBox,

            // counts (NOT clickable)
            HStack(
              [
                _countBox(u.followers.toString(), "FOLLOWERS"),
                10.widthBox,
                _countBox(u.following.toString(), "FOLLOWING"),
                10.widthBox,
                _countBox(u.stories.toString(), "STORIES"),
              ],
            ).px16(),

            18.heightBox,

            // follow button only
            Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white.withOpacity(0.08) : AppColors.accent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isFollowing ? Colors.white.withOpacity(0.18) : Colors.transparent,
                ),
              ),
              child: (isFollowing ? "Following" : "Follow")
                  .text
                  .color(Colors.white)
                  .bold
                  .xl
                  .makeCentered(),
            ).px16().onInkTap(() {
              setState(() => isFollowing = !isFollowing);
            }),

            18.heightBox,

            // Public Stories section (UI only)
            "Stories".text.white.bold.xl2.make().px16(),
            12.heightBox,

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: const [
                  _StoryCard(
                    title: "The Silent Echoes",
                    subtitle: "A mystery novel exploring forgotten memories...",
                  ),
                  SizedBox(height: 12),
                  _StoryCard(
                    title: "Paper Airplanes",
                    subtitle: "Short stories about the fleeting nature of first love...",
                  ),
                  SizedBox(height: 12),
                  _StoryCard(
                    title: "The Last Constellation",
                    subtitle: "Sci-fi adventure where stars are fading from the sky...",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countBox(String value, String label) {
    return Expanded(
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: VStack(
          [
            value.text.white.bold.xl2.make(),
            6.heightBox,
            label.text.color(Colors.white60).sm.make(),
          ],
          alignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StoryCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: VStack(
        [
          title.text.white.bold.xl.make(),
          8.heightBox,
          subtitle.text.color(Colors.white60).make(),
        ],
        crossAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}