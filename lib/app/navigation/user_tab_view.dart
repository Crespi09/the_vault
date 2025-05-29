import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class UserTabView extends StatefulWidget {
  const UserTabView({super.key});

  @override
  State<UserTabView> createState() => _UserTabViewState();
}

class _UserTabViewState extends State<UserTabView> {
  void onLogoutPressed() {}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      // Use Stack as the root widget to allow overlapping
      child: Stack(
        children: [
          // Column containing both containers
          Column(
            children: [
              // First component - 35% of screen height
              Container(
                height: screenHeight * 0.35,
                width: double.infinity,
                color: RiveAppTheme.background2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Nome Utente",
                      style: TextStyle(
                        color: RiveAppTheme.background,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              // Second component - 60% of screen height
              Container(
                height: screenHeight * 0.6,
                width: double.infinity,
                color: RiveAppTheme.background,
                child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        top: screenHeight * 0.27 - 100,
                        left: MediaQuery.of(context).size.width * 0.40 - 100,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: RiveAppTheme.background.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                color: RiveAppTheme.background.withOpacity(0.3),
                                offset: const Offset(0, 30),
                                blurRadius: 30,
                              ),
                            ],
                            color: Colors.white,
                            backgroundBlendMode: BlendMode.luminosity,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: RiveAppTheme.background2,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Text(
                                  "52",
                                  style: TextStyle(
                                    color: RiveAppTheme.background2,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.description,
                                size: 37,
                                color: RiveAppTheme.background2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: screenHeight * 0.27 - 100,
                        left: MediaQuery.of(context).size.width * 0.90 - 100,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: RiveAppTheme.background.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                color: RiveAppTheme.background.withOpacity(0.3),
                                offset: const Offset(0, 30),
                                blurRadius: 30,
                              ),
                            ],
                            color: Colors.white,
                            backgroundBlendMode: BlendMode.luminosity,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: RiveAppTheme.background2,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Text(
                                  "4",
                                  style: TextStyle(
                                    color: RiveAppTheme.background2,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.folder,
                                size: 37,
                                color: RiveAppTheme.background2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: screenHeight * 0.38 - 100,
                        // Centrare orizzontalmente il bottone
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CupertinoButton(
                            pressedOpacity: 1,
                            onPressed: onLogoutPressed,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: RiveAppTheme.background.withOpacity(
                                      0.3,
                                    ),
                                    offset: const Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: RiveAppTheme.background.withOpacity(
                                      0.3,
                                    ),
                                    offset: const Offset(0, 30),
                                    blurRadius: 30,
                                  ),
                                ],
                                color: Colors.white,
                                backgroundBlendMode: BlendMode.luminosity,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: RiveAppTheme.background2,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.group_add,
                                size: 37,
                                color: RiveAppTheme.background2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // logout btn
                      Positioned(
                        top: screenHeight * 0.55 - 100,
                        // Centrare orizzontalmente il bottone
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CupertinoButton(
                            pressedOpacity: 1,
                            onPressed: onLogoutPressed,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: Container(
                              width: 70,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                                // Opzionale: aggiunta di un'ombra
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   'LOGOUT',
                                  //   style: const TextStyle(
                                  //     color: Color.fromARGB(255, 185, 27, 27),
                                  //     fontFamily: 'Inter',
                                  //     fontWeight: FontWeight.w600,
                                  //     fontSize: 17,
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 8),
                                  Icon(
                                    Icons.logout,
                                    size: 25,
                                    color: Color.fromARGB(255, 185, 27, 27),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // user profile icon -
          Positioned(
            top: screenHeight * 0.37 - 100,
            left: MediaQuery.of(context).size.width / 4,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: RiveAppTheme.background2,
                borderRadius: BorderRadius.circular(105),
                border: Border.all(color: RiveAppTheme.background, width: 10),
              ),
              child: Icon(Icons.person, size: 110, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
