import 'package:flutter/material.dart';
import 'package:vault_app/app/home.dart';
import 'package:vault_app/app/on_boarding/onboarding_view.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, ),
      home: HomePage(),
    );
  }
}
