import 'package:flutter/material.dart';
import 'package:narad/welcome_screen.dart';

void main() {
  runApp(Narad());
}

class Narad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      //home: ARMapScreen(),
    );
  }
}
