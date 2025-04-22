import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Center(
              child: OverflowBox(
                maxWidth: double.infinity,
                child: Transform.translate(
                  offset: const Offset(200, 100),
                  child: Image.asset(
                    'assets/samples/ui/rive_app/images/backgrounds/spline.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: const rive.RiveAnimation.asset(
              'assets/samples/ui/rive_app/rive/shapes.riv',
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 260,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: const Text(
                      "Save & Store your Data",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 60),
                    ),
                  ),
                  Text(
                    "Store your data in a safe way by using this app, uiiiiiiiiiii",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontFamily: "Inter",
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 236,
                    height: 64,
                    child: Stack(
                      children: [
                        rive.RiveAnimation.asset(
                          'assets/samples/ui/rive_app/rive/button.riv',
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
