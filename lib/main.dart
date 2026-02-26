import 'package:flutter/material.dart';
import 'package:storyo/core/routes.dart';
import 'package:storyo/screens/auth/login_screen.dart';
import 'package:storyo/screens/auth/register_screen.dart';
import 'package:storyo/screens/dashBoard/homePage.dart';
import 'package:storyo/screens/explore/explore_screen.dart';
import 'package:storyo/screens/on_boarding_screen/onBoardingScreen.dart';
import 'package:storyo/screens/on_boarding_screen/onBoardingScreenSuccess.dart';
import 'package:storyo/screens/on_boarding_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:MyRoutes.splashScreen ,
      routes: {
        MyRoutes.splashScreen:(context)=>Splashscreen(),
        MyRoutes.loginScreen:(context)=>LoginScreen(),
        MyRoutes.registerScreen:(context)=>RegisterScreen(),
        MyRoutes.homePage:(context)=>Homepage(),
        MyRoutes.onBoardingScreen:(context)=>Onboardingscreen(),
        MyRoutes.onBoardingScreenSuccess:(context)=>Onboardingscreensuccess(),
        MyRoutes.explorePage:(context)=>ExploreScreen(),
      },
     
    );
  }
}
