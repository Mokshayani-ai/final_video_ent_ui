import 'package:flutter/material.dart';
import 'package:my_app/Screen/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mokshayani.ai",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFF15343E),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Aleo'),
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Aleo'),
        ),
      ),
      home: LoginPage(),
    );
  }
}

