import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'homepage.dart'; // Import the home page

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate a loading delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background with Blur
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.yellow.withValues(alpha: 0.8),
                  Colors.blue.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 8.0, sigmaY: 8.0), // More subtle blur
              child: Container(
                color:
                    Colors.black.withValues(alpha: 0), // Transparent over blur
              ),
            ),
          ),

          // Content on top
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Image in a Circular Box
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150, // Adjust width of the logo
                    height: 150, // Adjust height of the logo
                  ),
                ),
                const SizedBox(
                    height: 30), // Space between logo and progress bar

                // Horizontal Progress Indicator with a sleek look
                SizedBox(
                  width: 200, // Adjust width of the progress bar
                  height: 5,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 43, 43, 43),
                    ), // Progress bar color
                  ),
                ),
                const SizedBox(height: 30), // Space below progress bar

                // "Loading..." text with improved typography
                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
