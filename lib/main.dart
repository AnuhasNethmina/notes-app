import 'package:flutter/material.dart';
import 'package:myapp/mainpage.dart';

void main() {
  runApp(const noteapp());
}

class noteapp extends StatelessWidget {
  const noteapp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
