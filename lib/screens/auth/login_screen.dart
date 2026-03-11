import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/screens/auth/auth_service.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary, // 🔵 Dark Background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.heightBox,

                Image.asset("assets/logo/storyo.png", height: 150),

                10.heightBox,

                "Welcome Back!!!".text.color(AppColors.primary).xl2.bold.make(),

                30.heightBox,

                /// 🔹 EMAIL FIELD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _email,
                    style: const TextStyle(color: AppColors.primary),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.primary,
                      ),
                      labelText: "Enter Your Email",
                      labelStyle: const TextStyle(color: AppColors.primary),
                      hintText: "E-mail",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),

                15.heightBox,

                /// 🔹 PASSWORD FIELD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.primary),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.primary,
                      ),
                      labelText: "Enter Your Password",
                      labelStyle: const TextStyle(color: AppColors.primary),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),

                10.heightBox,

                /// 🔹 Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: "Forgot Password?".text
                      .color(Colors.white70)
                      .make()
                      .px16(),
                ),

                20.heightBox,

                /// 🔹 LOGIN BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: "Login".text
                              .color(AppColors.primary)
                              .bold
                              .lg
                              .make(),
                        ),
                      ).onInkTap(() async {
                        final user = await _auth.loginUserWithEmailAndPassword(
                          _email.text.trim(),
                          _password.text.trim(),
                        );

                        if (!context.mounted) return;

                        if (user != null) {
                          log("User Logged In!!");
                          Navigator.pushReplacementNamed(
                            context,
                            MyRoutes.onBoardingScreen,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login Failed")),
                          );
                        }
                      }),
                ),

                25.heightBox,

                /// 🔹 Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    "  Or  ".text.color(Colors.white70).make(),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ).px16(),

                25.heightBox,

                /// 🔹 Google Login
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/auth/google.png', height: 24),
                            10.widthBox,
                            "Login Using Google".text
                                .color(AppColors.primary)
                                .bold
                                .make(),
                          ],
                        ),
                      ).onInkTap(() async {
                        final user = await _auth.signInWithGoogle();

                        if (!context.mounted) return;

                        if (user != null) {
                          log("Google Login Success");
                          Navigator.pushReplacementNamed(
                            context,
                            MyRoutes.onBoardingScreen,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Google Login Failed"),
                            ),
                          );
                        }
                      }),
                ),

                20.heightBox,

                /// 🔹 Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Don't Have Account?".text.color(Colors.white70).make(),
                    5.widthBox,
                    "SignUp".text.color(AppColors.accent).bold.make().onInkTap(
                      () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/RegisterScreen",
                        );
                      },
                    ),
                  ],
                ),

                30.heightBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
