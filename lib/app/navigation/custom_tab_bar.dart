// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:vault_app/app/models/tab_item.dart';
import 'package:vault_app/app/theme.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key, required this.onTabChange});

  final Function(int tableIndex) onTabChange;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  final List<TabItem> _icons = TabItem.tabItemList;

  int _selectedTab = 0;

  void _onRiveIconInit(Artboard artboard, index) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      _icons[index].stateMachine,
    );
    artboard.addController(controller!);

    _icons[index].status = controller.findInput<bool>("active") as SMIBool;
  }

  void onTabPress(int index) {
    if (_selectedTab != index) {
      setState(() {
        _selectedTab = index;
      });
      widget.onTabChange(index);

      _icons[index].status!.change(true);
      Future.delayed(const Duration(seconds: 1), () {
        _icons[index].status!.change(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0)],
          ),
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: RiveAppTheme.background2.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: RiveAppTheme.background2.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              TabItem icon = _icons[index];

              return Expanded(
                key: icon.id,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedOpacity(
                    opacity: _selectedTab == index ? 1 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 37,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4,
                            width: _selectedTab == index ? 20 : 0,
                            decoration: BoxDecoration(
                              color: RiveAppTheme.accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: RiveAnimation.asset(
                            'assets/samples/ui/rive_app/rive/icons.riv',
                            stateMachines: [icon.stateMachine],
                            artboard: icon.artboard,
                            onInit: (artboard) {
                              _onRiveIconInit(artboard, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    onTabPress(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
