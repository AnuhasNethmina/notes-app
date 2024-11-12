import 'package:flutter/material.dart';
import 'package:myapp/menupage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Set a timer for 3 seconds and then navigate to MenuPage
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpeg'), // Background image
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        child: const Column(
          children: [
            Spacer(flex: 25), // Adjust this to move content further down
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Simple Note',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(232, 216, 83, 21),
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20), // Space between text and button
                  Text(
                    'Redirecting to Menu...',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: 4), // Adjust this to move the button further down
          ],
        ),
      ),
    );
  }
}
