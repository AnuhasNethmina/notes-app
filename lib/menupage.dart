
// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainpage.dart'; // Import MainPage
import 'notepage.dart'; // Import NotePage

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _pinController = TextEditingController();
  String _storedPin = '';

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  // Load the stored PIN from SharedPreferences
  Future<void> _loadStoredPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('userPin') ?? '';
    });
  }

  // Store the entered PIN in SharedPreferences
  Future<void> _storePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPin', pin);
    setState(() {
      _storedPin = pin;
    });
  }

  void _unlock() {
    if (_storedPin.isEmpty) {
      // If no PIN is stored, store the entered PIN as the new PIN
      if (_pinController.text.length == 4) {
        _storePin(_pinController.text);
        _navigateToNotePage();
      } else {
        _showErrorDialog('Please enter a 4-digit PIN to set.');
      }
    } else if (_pinController.text == _storedPin) {
      // If the stored PIN matches the entered PIN, navigate to NotePage
      _navigateToNotePage();
    } else {
      // Show an error message if the PIN is incorrect
      _showErrorDialog('Incorrect PIN. Please try again.');
    }
  }

  void _navigateToNotePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotePage()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purpleAccent, Colors.deepPurple],
              ),
            ),
          ),
          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Enter PIN" or "Set PIN" Text
              Center(
                child: Text(
                  _storedPin.isEmpty
                      ? 'Set your 4-digit PIN'
                      : 'Enter your 4-digit PIN to unlock',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // PIN Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter PIN',
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // Unlock Button
              ElevatedButton(
                onPressed: _unlock,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Unlock',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Exit Button
          Positioned(
            bottom: 40, // Position near the bottom of the screen
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to MainPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
