import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:rive/rive.dart';
import 'dart:math' as math;
import 'package:vault_app/app/navigation/custom_tab_bar.dart';
import 'package:vault_app/app/navigation/home_tab_view.dart';
import 'package:vault_app/app/navigation/side_menu.dart';
import 'package:vault_app/app/theme.dart';

// TODO - da togliere, solo di test per le pagine
Widget commonTabScene(String tabName) {
  return Container(
    alignment: Alignment.center,
    child: Text(tabName, style: const TextStyle(fontSize: 28)),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController? _animationController;
  late Animation<double> _sidebarAnim;
  late SMIBool _menuBtn;
  Widget _tabBody = Container(color: RiveAppTheme.background);
  final List<Widget> _screens = [
    const HomeTabView(),
    commonTabScene('Search'),
    commonTabScene('Timer'),
    commonTabScene('Bell'),
    commonTabScene('User'),
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
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear, // tante animazioni
      ),
    );

    _tabBody = _screens.first;
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SideMenu(),
          AnimatedBuilder(
            animation: _sidebarAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_sidebarAnim.value * 265, 0),
                child: Transform(
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY((_sidebarAnim.value * 30) * math.pi / 180),
                  child: child,
                ),
              );
            },
            child: _tabBody,
          ),

          SafeArea(
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
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        onTabChange: (tabIndex) {
          setState(() {
            _tabBody = _screens[tabIndex];
          });
        },
      ),
    );
  }
}
