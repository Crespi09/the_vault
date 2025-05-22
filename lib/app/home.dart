import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:vault_app/app/components/SearchBarComponents.dart';
import 'dart:math' as math;
import 'package:vault_app/app/navigation/custom_tab_bar.dart';
import 'package:vault_app/app/navigation/folder_tab_view.dart';
import 'package:vault_app/app/navigation/home_tab_view.dart';
import 'package:vault_app/app/navigation/side_menu.dart';
import 'package:vault_app/app/navigation/user_tab_view.dart';
import 'package:vault_app/app/on_boarding/onboarding_view.dart';
import 'package:vault_app/app/theme.dart';

// TODO - da togliere, solo di test per le pagine
// Widget commonTabScene(String tabName) {
//   return Container(
//     alignment: Alignment.center,
//     child: Text(
//       tabName,
//       style: const TextStyle(fontSize: 28, color: Colors.white),
//     ),
//   );
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController? _animationController;
  // late AnimationController? _onBoardingAnimController;
  // late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;
  late SMIBool _menuBtn;
  Widget _tabBody = Container(color: RiveAppTheme.background);
  final List<Widget> _screens = [
    const HomeTabView(),
    const FolderTabView(),
    const UserTabView(),
    // commonTabScene('Search'),
    // commonTabScene('Timer'),
    // commonTabScene('Bell'),
    // commonTabScene('User'),
  ];

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine',
    );
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>('isOpen') as SMIBool;
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    // serve per cambiare il colore della barra sopra del telefono
    SystemChrome.setSystemUIOverlayStyle(
      _menuBtn.value ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );

    // _onBoardingAnimController = AnimationController(
    //   duration: const Duration(milliseconds: 350),
    //   upperBound: 1,
    //   vsync: this,
    // );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear, // tante animazioni
      ),
    );

    // _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(parent: _onBoardingAnimController!, curve: Curves.linear),
    // );

    _tabBody = _screens.first;
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    // _onBoardingAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(child: Container(color: RiveAppTheme.background2)),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                          ((1 - _sidebarAnim.value) * -30) * math.pi / 180,
                        )
                        ..translate((1 - _sidebarAnim.value) * -300),
                  child: child,
                );
              },
              child: FadeTransition(
                opacity: _sidebarAnim,
                child: const SideMenu(),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 - _sidebarAnim.value * 0.1,
                  child: Transform.translate(
                    offset: Offset(_sidebarAnim.value * 265, 0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(
                              (_sidebarAnim.value * 30) * math.pi / 180,
                            ),
                      child: child,
                    ),
                  ),
                );
              },
              child: _tabBody,
            ),
          ),

          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return SafeArea(
                  child: Row(
                    children: [
                      SizedBox(width: _sidebarAnim.value * 216),
                      child!,
                    ],
                  ),
                );
              },
              child: GestureDetector(
                onTap: onMenuPress,
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44 / 2),
                    boxShadow: [
                      BoxShadow(
                        color: RiveAppTheme.shadow.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: RiveAnimation.asset(
                    'assets/samples/ui/rive_app/rive/menu_button.riv',
                    stateMachines: const ['State Machine'],
                    animations: ['open', 'close'],
                    onInit: _onMenuIconInit,
                  ),
                ),
              ),
            ),
          ),

          // Search bar posizionata in alto a destra
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(
                          3,
                          1,
                          0.0006,
                        ) // Corrected from 1,2 to 3,2 for proper perspective
                        ..rotateY(
                          _sidebarAnim.value * math.pi / 4,
                        ) // 30 degrees = π/6 radians
                        ..rotateZ(_sidebarAnim.value * math.pi / -20.33)
                        ..translate(
                          _sidebarAnim.value * 240,
                          _sidebarAnim.value * 80,
                          0,
                        ),
                  child: child!,
                );
              },
              child: SearchBarComponents(),
            ),
          ),

          // SafeArea(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(30),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.5),
          //           blurRadius: 40,
          //           offset: const Offset(0, 40),
          //         ),
          //       ],
          //     ),
          //     child: OnboardingView(),
          //   ),
          // ),
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _sidebarAnim,
                  builder: (context, child) {
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            RiveAppTheme.background.withOpacity(0),
                            RiveAppTheme.background.withOpacity(
                              1 - _sidebarAnim.value,
                            ),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _sidebarAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _sidebarAnim.value * 300),
              child: child!,
            );
          },
          child: CustomTabBar(
            onTabChange: (tabIndex) {
              setState(() {
                _tabBody = _screens[tabIndex];
              });
            },
          ),
        ),
      ),
    );
  }
}
