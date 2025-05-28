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
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      "Utente 1",
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
                              Text(
                                "52",
                                style: TextStyle(
                                  color: RiveAppTheme.background2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
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
                              Text(
                                "4",
                                style: TextStyle(
                                  color: RiveAppTheme.background2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
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
                    ],
                  ),
                ),
              ),
            ],
          ),

          // user profile icon -
          Positioned(
            top: screenHeight * 0.37 - 100,
            left: MediaQuery.of(context).size.width / 2 - 100,
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
