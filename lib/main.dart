import 'package:ecoguard/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecoguard/pages/login.dart';
import 'package:ecoguard/pages/home.dart';
import 'package:ecoguard/pages/profile.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecoguard App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splashscreen',
      routes: {
        '/splashscreen': (context) => SplashScreen(),
        '/home': (context) => LoginPage(),
        '/landingpage': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
