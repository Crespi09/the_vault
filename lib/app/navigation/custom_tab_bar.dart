import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:vault_app/app/theme.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  SMIBool? status;

  void _onRiveIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "CHAT_Interactivity",
    );
    artboard.addController(controller!);

    status = controller.findInput<bool>("active") as SMIBool;
  }

  void onTabPress() {
    status!.change(true);
    Future.delayed(const Duration(seconds: 1), () {
      status!.change(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
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
          child: CupertinoButton(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 36,
              width: 36,
              child: RiveAnimation.asset(
                'assets/samples/ui/rive_app/rive/icons.riv',
                stateMachines: ["CHAT_Interactivity"],
                artboard: "CHAT",
                onInit: _onRiveIconInit,
              ),
            ),
            onPressed: onTabPress,
          ),
        ),
      ),
    );
  }
}
