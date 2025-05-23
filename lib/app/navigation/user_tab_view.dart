import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class UserTabView extends StatefulWidget {
  const UserTabView({super.key});

  @override
  State<UserTabView> createState() => _UserTabViewState();
}

class _UserTabViewState extends State<UserTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Positioned(
            top: 120,
            left: MediaQuery.of(context).size.width / 4,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 30),
                    blurRadius: 30,
                  ),
                ],
                color: CupertinoColors.secondarySystemBackground,
                backgroundBlendMode: BlendMode.luminosity,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(Icons.person, size: 120),
            ),
          ),


          Positioned(
            top: 280,
            left: MediaQuery.of(context).size.width / 4,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 30),
                    blurRadius: 30,
                  ),
                ],
                color: const Color.fromARGB(255, 76, 204, 243),
                backgroundBlendMode: BlendMode.luminosity,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          Positioned(
            top: 320,
            left: MediaQuery.of(context).size.width / 2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.3),
                    offset: const Offset(0, 30),
                    blurRadius: 30,
                  ),
                ],
                color: const Color.fromARGB(255, 76, 204, 243),
                backgroundBlendMode: BlendMode.luminosity,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),





        ],
      ),
    );
  }
}
