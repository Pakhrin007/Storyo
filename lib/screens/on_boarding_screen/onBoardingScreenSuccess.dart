import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:velocity_x/velocity_x.dart';

class Onboardingscreensuccess extends StatefulWidget {
  const Onboardingscreensuccess({super.key});

  @override
  State<Onboardingscreensuccess> createState() => _Onboardingscreen2successState();
}

class _Onboardingscreen2successState extends State<Onboardingscreensuccess>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward(); // start tick animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            25.heightBox,

            // ✅ Image
            Image.asset(
              "assets/onBoard/book.jpg",
              height: 260,
              fit: BoxFit.contain,
            ).centered(),

            30.heightBox,

            // ✅ Title
            "You're all set!"
                .text
                .white
                .bold
                .xl4
                .make()
                .centered(),

            12.heightBox,

            // ✅ Subtitle
            "Your library is ready. We've curated a\npersonalized feed just for you."
                .text
                .color(Colors.white60)
                .lg
                .align(TextAlign.center)
                .make()
                .px20(),

            30.heightBox,

            // ✅ Animated tick
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accent,
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ).centered(),

            const Spacer(),

            // ✅ Finish button
            Container(
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
              child: HStack(
                [
                  const Spacer(),
                  "Finish".text.white.bold.xl.make(),
                  10.widthBox,
                  const Icon(Icons.rocket_launch, color: Colors.white),
                  const Spacer(),
                ],
              ),
            ).px16().onInkTap(() {
              Navigator.pushReplacementNamed(context, MyRoutes.explorePage);
            }),

            16.heightBox,
          ],
        ),
      ),
    );
  }
}
