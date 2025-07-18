import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:vault_app/app/models/menu_item.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.menu,
    this.selectedMenu = 'Home',
    this.onMenuPress,
  });

  final MenuItemModel menu;
  final String selectedMenu;
  final Function? onMenuPress;

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      menu.riveIcon.stateMachine,
    );
    artboard.addController(controller!);
    menu.riveIcon.status = controller.findInput<bool>('active') as SMIBool;
  }

  void onMenuPressed() {
    if (selectedMenu != menu.title) {
      onMenuPress!();
      menu.riveIcon.status!.change(true);
      Future.delayed(const Duration(seconds: 1), () {
        menu.riveIcon.status!.change(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: selectedMenu == menu.title ? 288 - 16 : 0,
          height: 56,
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        CupertinoButton(
          padding: const EdgeInsets.all(12),
          pressedOpacity: 1,
          onPressed: onMenuPressed,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Opacity(
                  opacity: 0.6,
                  child: RiveAnimation.asset(
                    'assets/samples/ui/rive_app/rive/icons.riv',
                    stateMachines: [menu.riveIcon.stateMachine],
                    artboard: menu.riveIcon.artboard,
                    onInit: _onMenuIconInit,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                menu.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
