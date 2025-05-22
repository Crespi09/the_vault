import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserTabView extends StatefulWidget {
  const UserTabView({super.key});

  @override
  State<UserTabView> createState() => _UserTabViewState();
}

class _UserTabViewState extends State<UserTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'User',
        style: const TextStyle(fontSize: 28, color: Colors.white),
      ),
    );
  }
}
