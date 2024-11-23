import 'package:ecoguard/pages/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
with SingleTickerProviderStateMixin{
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  
  Future.delayed(Duration(seconds: 2),() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => LoginPage(),
    ));
  });
  
  }
@override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
    overlays: SystemUiOverlay.values);
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color.fromARGB(248, 252, 249, 111), Color.fromARGB(255, 232, 212, 126)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          ),
        ),
     child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [
      Image.asset(
        'assets/logo.png',
        width: 400,
        height: 400,
      ),
     const Text(
      'EcoGuard',
       style: TextStyle(
      color: Color.fromARGB(255, 55, 122, 38),
      fontSize: 50,
      fontWeight: FontWeight.bold,
     ),
     ),
     const SizedBox(height: 10),
      if(defaultTargetPlatform == TargetPlatform.iOS)
        const CupertinoActivityIndicator(
          color: Colors.white,
          radius:20,
        ) 
        else
        const CircularProgressIndicator(
          color: Colors.white,
        ),
     const SizedBox(height: 15),
     ],
     ),
      )
    );
  }
}