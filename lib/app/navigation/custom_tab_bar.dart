// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:vault_app/app/models/tab_item.dart';
import 'package:vault_app/app/theme.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  final List<TabItem> _icons = TabItem.tabItemList;

  SMIBool? status;

  void _onRiveIconInit(Artboard artboard, index) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      _icons[index].stateMachine,
    );
    artboard.addController(controller!);

    _icons[index].status = controller.findInput<bool>("active") as SMIBool;
  }

  void onTabPress(int index) {
    _icons[index].status!.change(true);
    Future.delayed(const Duration(seconds: 1), () {
      _icons[index].status!.change(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0),
            ],
          ),
        ),
        child: Container(
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

              return CupertinoButton(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
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
                onPressed: () {
                  onTabPress(index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
