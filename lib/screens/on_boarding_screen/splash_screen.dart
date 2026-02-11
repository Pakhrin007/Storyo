import 'dart:async';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/screens/auth/login_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: VStack(
        [
          const Spacer(),

          // 🔹 Logo
          Image.asset(
            'assets/logo/storyo.png',
            height: 120,
          ).centered(),

          20.heightBox,

          // 🔹 App Title
          "Storyo"
              .text
              .color(AppColors.primary)
              .xl4
              .bold
              .letterSpacing(1.2)
              .make()
              .centered(),

          10.heightBox,

          // 🔹 Subtitle
          "Capture your stories beautifully"
              .text
              .color(AppColors.primary)
              
              .lg
              .make()
              .centered(),

          40.heightBox,

          // 🔹 Loader
          const CircularProgressIndicator(
            color:AppColors.primary,
            strokeWidth: 3,
          ).centered(),

          const Spacer(),
        ],
        crossAlignment: CrossAxisAlignment.center,
      ).p16(),
    );
  }
}
