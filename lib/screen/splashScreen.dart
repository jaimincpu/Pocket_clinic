import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Home_page/Home_Page.dart';
import '../login/LogChecker.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>    
                const LogChecker()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           Positioned.fill(
            child: Image.asset(
              'assets/Pocket_clinic_logo.png', // Path to your imageC:\Users\MR-NATURE\Desktop\ajay\assets\appImage\Task_Asignment_System.jpg
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.5, // Adjust opacity (0.0 to 1.0)
                child: Text(
                  'Pocket Clinic',
                  style: GoogleFonts.birthstoneBounce(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      color: Color.fromARGB(255, 147, 214, 200),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
