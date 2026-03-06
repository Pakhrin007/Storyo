import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            // Top row (back + title + settings)
            HStack(
              [
                Icon(Icons.arrow_back_ios_new, color: Colors.white)
                    .p8()
                    .onInkTap(() => Navigator.pop(context)),
                const Spacer(),
                "Profile".text.white.bold.xl2.make(),
                const Spacer(),
                Icon(Icons.settings, color: Colors.white70)
                    .p8()
                    .onInkTap(() {
                  Navigator.pushNamed(context, MyRoutes.settingsScreen);
                }),
              ],
            ).px8().py4(),

            10.heightBox,

            // Avatar
            ZStack(
              [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.deepPurple.withOpacity(0.25),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage("assets/logo/storyo.png"), // replace later
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ).centered(),

            16.heightBox,

            "Elena Rose".text.white.bold.xl4.make().centered(),
            6.heightBox,
            "@elenarose_writes"
                .text
                .color(Colors.deepPurpleAccent)
                .semiBold
                .lg
                .make()
                .centered(),
            12.heightBox,

            "Storyteller & Dreamer. Exploring the world\nthrough words and forgotten memories."
                .text
                .color(Colors.white60)
                .align(TextAlign.center)
                .make()
                .px24(),

            18.heightBox,

            // Edit profile button
            Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: "Edit Profile".text.white.bold.lg.makeCentered(),
            ).px16(),

            16.heightBox,

            // Stats
            HStack(
              [
                _statBox("1.2K", "FOLLOWERS"),
                10.widthBox,
                _statBox("450", "FOLLOWING"),
                10.widthBox,
                _statBox("18", "STORIES"),
              ],
            ).px16(),

            18.heightBox,

            // ✅ Only My Stories title (Reading list removed)
            "My Stories".text.white.bold.xl2.make().px16(),
            12.heightBox,

            // Stories list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  _storyCard(
                    date: "PUBLISHED JAN 12, 2024",
                    title: "The Silent Echoes",
                    subtitle:
                        "A mystery novel exploring the depths of forgotten childhood...",
                  ),
                  12.heightBox,
                  _storyCard(
                    date: "PUBLISHED NOV 28, 2023",
                    title: "Paper Airplanes",
                    subtitle:
                        "Short stories about the fleeting nature of first love and long...",
                  ),
                  12.heightBox,
                  _storyCard(
                    date: "PUBLISHED OCT 05, 2023",
                    title: "The Last Constellation",
                    subtitle:
                        "Sci-fi adventure set in a world where stars are fading from...",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Create story button (bottom)
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

  static Widget _statBox(String value, String label) {
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
        ),
      ),
    );
  }

  static Widget _storyCard({
    required String date,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: HStack(
        [
          Expanded(
            child: VStack(
              [
                date.text.color(Colors.white38).sm.make(),
                8.heightBox,
                title.text.white.bold.xl.make(),
                8.heightBox,
                subtitle.text.color(Colors.white60).make(),
              
              ],
              crossAlignment: CrossAxisAlignment.start,
            ),
          ),
          14.widthBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 86,
              width: 86,
              color: Colors.white.withOpacity(0.12),
              child: const Icon(Icons.image_outlined, color: Colors.white38),
            ),
          )
        ],
      ),
    );
  }

  static Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: HStack(
        [
          Icon(icon, color: Colors.white54, size: 16),
          6.widthBox,
          text.text.color(Colors.white70).make(),
        ],
        axisSize: MainAxisSize.min,
      ),
    );
  }
}