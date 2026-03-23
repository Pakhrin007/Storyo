import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/screens/auth/auth_service.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondary,

        body: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                15.heightBox,
                Center(
                  child: Image.asset("assets/logo/storyo.png", height: 200),
                ),
                10.heightBox,
                Center(
                  child: "Create Your Account".text
                      .color(AppColors.primary)
                      .textStyle(
                        TextStyle(
                          fontFamily: "libertin",
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .make(),
                ),
                25.heightBox,
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    controller: _name,
                    style: TextStyle(color: AppColors.primary),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: AppColors.primary),
                      labelText: "Enter Your FullName",
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: 'libertin',
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                      hintText: 'FullName',
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.05),
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: 'libertin',
                        fontWeight: FontWeight.w500,
                      ),
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
                12.heightBox,
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
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
                12.heightBox,

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.primary),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
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

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Material(
                      // color: MyTheme.primaryColor,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        child: AnimatedContainer(
                          duration: Duration(),
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: "SignUp".text
                              .color(AppColors.primary)
                              .textStyle(
                                TextStyle(
                                  fontFamily: 'libertin',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.38,
                                ),
                              )
                              .make()
                              .onInkTap(() async {
                                final user = await _auth
                                    .createUserWithEmailAndPassword(
                                      _email.text.trim(),
                                      _password.text.trim(),
                                    );

                                if (user != null) {
                                  // Save user profile to Firestore so other users can find them
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .set({
                                        'uid': user.uid,
                                        'name': user.displayName ?? '',
                                        'fullName': user.displayName ?? '',
                                        'email': user.email ?? '',
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));

                                  log("User Created Successfully!");
                                  if (!context.mounted) return;
                                  Navigator.pushReplacementNamed(
                                    context,
                                    MyRoutes.onBoardingScreen,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Signup Failed"),
                                    ),
                                  );
                                }
                              }),
                        ),
                      ),
                    ),
                  ),
                ),

                15.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Already Have Account?".text
                        .color(AppColors.primary)
                        .textStyle(
                          TextStyle(fontSize: 16, fontFamily: 'libertin'),
                        )
                        .make(),
                    "Login".text
                        .color(Colors.blue)
                        .textStyle(
                          TextStyle(fontSize: 16, fontFamily: 'libertin'),
                        )
                        .make()
                        .px(5)
                        .onInkTap(() {
                          Navigator.pushReplacementNamed(
                            context,
                            "/LoginScreen",
                          );
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
