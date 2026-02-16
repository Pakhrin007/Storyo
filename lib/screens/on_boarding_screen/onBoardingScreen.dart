import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:velocity_x/velocity_x.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final List<String> topics = [
    "Short Stories",
    "Audiobooks",
    "Deep Dives",
    "Daily News",
    "Classics",
    "Sci-Fi",
    "Biography",
    "Poetry",
    "Self-Improvement",
    "Technology",
    "Philosophy",
  ];

  final Set<String> selected = {"Short Stories", "Deep Dives", "Biography"};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack([
          // Top Row (no AppBar)
          HStack([
            const Spacer(),
            "Choose Your Reading Preferences".text
                .color(AppColors.accent)
                .semiBold
                .textStyle(TextStyle(fontFamily: 'libertin'))
                .xl
                .make(),
            const Spacer(),
          ]).px12().py8(),

          // Illustration
          Image.asset(
            "assets/onBoard/book.jpg",
            height: 240,
            fit: BoxFit.contain,
          ).centered(),

          24.heightBox,

          "Personalize your feed".text.textStyle(TextStyle(fontFamily: 'libertin')).white.bold.xl4.make().px20().centered(),
          10.heightBox,

          "Choose 3 or more topics to help us\n tailor your reading experience."
              .text
              .color(Colors.white60)
              .lg
              .align(TextAlign.center).textStyle(TextStyle(fontFamily: 'libertin'))
              .make()
              .px20()
              .centered(),

          22.heightBox,

          // Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: topics.map((t) => _topicChip(t)).toList(),
          ).px16(),

          const Spacer(),

          // Continue button
          _primaryButton(
            text: "Continue",
            icon: Icons.arrow_forward,
            onTap: () {
              Navigator.pushNamed(context, MyRoutes.onBoardingScreenSuccess);
            },
          ).px16(),

          16.heightBox,
        ]),
      ),
    );
  }

  

  Widget _topicChip(String text) {
    final isSelected = selected.contains(text);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: HStack(
        [
          if (isSelected)
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ).pOnly(right: 6),
          text.text.color(Colors.white).semiBold.lg.make(),
        ],
        alignment: MainAxisAlignment.center,
        axisSize: MainAxisSize.min,
      ),
    ).onInkTap(() {
      setState(() {
        if (isSelected) {
          selected.remove(text);
        } else {
          selected.add(text);
        }
      });
    });
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: HStack([
        const Spacer(),
        text.text.textStyle(TextStyle(fontFamily: 'libertin')).white.bold.xl.make(),
        10.widthBox,

        Icon(icon, color: Colors.white),
        const Spacer(),
      ], alignment: MainAxisAlignment.center),
    ).onInkTap(onTap);
  }
}
