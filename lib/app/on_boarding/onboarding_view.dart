import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late rive.RiveAnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _btnController = rive.OneShotAnimation("active", autoplay: false);
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

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
                  const Spacer(),
                  GestureDetector(
                    child: Container(
                      width: 236,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          rive.RiveAnimation.asset(
                            'assets/samples/ui/rive_app/rive/button.riv',
                            fit: BoxFit.cover,
                            controllers: [_btnController],
                          ),
                          Center(
                            child: Transform.translate(
                              offset: const Offset(4, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.arrow_forward_rounded),
                                  SizedBox(width: 4),
                                  Text(
                                    "Start Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _btnController.isActive = true;
                    },
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
