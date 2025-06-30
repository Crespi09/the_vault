import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:rive/rive.dart' as rive;

// pages
import 'package:vault_app/app/on_boarding/signin_view.dart';
import 'package:vault_app/app/theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, this.onLogin});

  final Function(bool)? onLogin;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  AnimationController? _signInAnimController;

  late rive.RiveAnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _signInAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1, // di default impostato a 1
      vsync: this,
    );
    _btnController = rive.OneShotAnimation("active", autoplay: false);

    const springDesc = SpringDescription(mass: 0.1, stiffness: 40, damping: 5);

    _btnController.isActiveChanged.addListener(() {
      if (_btnController.isActive) {
        final springAnim = SpringSimulation(springDesc, 0, 1, 0);
        _signInAnimController?.animateWith(springAnim);
      }
    });
  }

  @override
  void dispose() {
    _signInAnimController?.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: const rive.RiveAnimation.asset(
              'assets/samples/ui/rive_app/rive/shapes.riv',
            ),
          ),
          AnimatedBuilder(
            animation: _signInAnimController!,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.translationValues(
                  0,
                  -60 * _signInAnimController!.value,
                  0,
                ),
                child: child!,
              );
            },
            child: SafeArea(
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
                    // const SizedBox(height: 65),
                    // Text(
                    //   "possibile descrizione / termini e condizione ...",
                    //   style: TextStyle(
                    //     color: Colors.black.withOpacity(0.7),
                    //     fontFamily: 'Inter',
                    //     fontSize: 13
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ),

          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _signInAnimController!,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Opacity(
                          opacity: 0.5 * _signInAnimController!.value,
                          child: Container(color: RiveAppTheme.shadow),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(
                        0,
                        -MediaQuery.of(context).size.height *
                            (1 - _signInAnimController!.value),
                      ),
                      child: SigninView(
                        closeModal: () {
                          if (mounted) {
                            _signInAnimController?.reverse();
                          }
                        },
                        onLogin: widget.onLogin,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
