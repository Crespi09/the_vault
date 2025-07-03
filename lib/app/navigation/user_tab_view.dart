import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';
import 'package:vault_app/services/user_service.dart';

class UserTabView extends StatefulWidget {
  const UserTabView({super.key, this.onLogin});

  final Function(bool)? onLogin;

  @override
  State<UserTabView> createState() => _UserTabViewState();
}

class _UserTabViewState extends State<UserTabView> {
  final Dio _dio = Dio();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getItemsStats();
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      _userData = await UserService.getUser(authService.accessToken!);
    } catch (e) {
      debugPrint('Eccezione nel caricamento dati utente: $e');
      setState(() {
        _isLoading = false;
      });

      if (e is DioException && e.response?.statusCode == 401) {
        // Token scaduto, fai logout
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.logout();
        if (widget.onLogin != null) {
          widget.onLogin!(false);
        }
      }
    }
  }

  Future<void> _getItemsStats() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      final response = await _dio.get(
        'http://100.84.178.101:3000/users/items-stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = response.data;
          _isLoading = false;
        });
        debugPrint('Stats utente caricati: ${response.data}');
      } else {
        debugPrint(
          'Errore nel caricamento stats utente: ${response.statusCode}',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Eccezione nel caricamento stats utente: $e');
      setState(() {
        _isLoading = false;
      });

      if (e is DioException && e.response?.statusCode == 401) {
        // Token scaduto, fai logout
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.logout();
        if (widget.onLogin != null) {
          widget.onLogin!(false);
        }
      }
    }
  }

  void onLogoutPressed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();

    if (widget.onLogin != null) {
      widget.onLogin!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Column containing both containers
                  Column(
                    children: [
                      // First component - 35% of screen height
                      Container(
                        height: screenHeight * 0.34,
                        width: double.infinity,
                        color: RiveAppTheme.background2,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              _userData?['email'] ?? "Nome Utente",
                              style: TextStyle(
                                color: RiveAppTheme.background,
                                fontSize: 28,
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
                                left:
                                    MediaQuery.of(context).size.width * 0.10 -
                                    100,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: RiveAppTheme.background.withOpacity(0.3),
                                    //     offset: const Offset(0, 3),
                                    //     blurRadius: 5,
                                    //   ),
                                    //   BoxShadow(
                                    //     color: RiveAppTheme.background.withOpacity(0.3),
                                    //     offset: const Offset(0, 30),
                                    //     blurRadius: 30,
                                    //   ),
                                    // ],
                                    color: const Color(
                                      0xFF7850F0,
                                    ).withOpacity(0.6),
                                    // backgroundBlendMode: BlendMode.luminosity
                                    borderRadius: BorderRadius.circular(130),
                                    border: Border.all(
                                      color: RiveAppTheme.background2,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.description,
                                        size: 80,
                                        color: RiveAppTheme.background,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        child: Text(
                                          (_stats?['nFiles'] ?? 0).toString(),
                                          style: TextStyle(
                                            color: RiveAppTheme.background,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                top: screenHeight * 0.21 - 100,
                                left:
                                    MediaQuery.of(context).size.width * 0.80 -
                                    100,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF005FE7).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(120),
                                    border: Border.all(
                                      color: RiveAppTheme.background2,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      Icon(
                                        Icons.folder,
                                        size: 70,
                                        color: RiveAppTheme.background,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        child: Text(
                                          (_stats?['nFolder'] ?? 0).toString(),
                                          style: TextStyle(
                                            color: RiveAppTheme.background,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // share file btn
                              Positioned(
                                top: screenHeight * 0.54 - 100,
                                left:
                                    MediaQuery.of(context).size.width * 0.65 -
                                    100,
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
                                      height: 70,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: RiveAppTheme.background
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 3),
                                            blurRadius: 5,
                                          ),
                                          BoxShadow(
                                            color: RiveAppTheme.background
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 30),
                                            blurRadius: 30,
                                          ),
                                        ],
                                        color: Colors.white,
                                        backgroundBlendMode:
                                            BlendMode.luminosity,
                                        borderRadius: BorderRadius.circular(90),
                                        border: Border.all(
                                          color: RiveAppTheme.background2,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.group_add,
                                        size: 29,
                                        color: RiveAppTheme.background2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // logout btn
                              Positioned(
                                top: screenHeight * 0.54 - 100,
                                left:
                                    MediaQuery.of(context).size.width * 0.90 -
                                    100,

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
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(90),
                                        color: Colors.white,
                                        // Opzionale: aggiunta di un'ombra
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Color.fromARGB(
                                            255,
                                            185,
                                            27,
                                            27,
                                          ),
                                          width: 3,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            size: 29,
                                            color: Color.fromARGB(
                                              255,
                                              185,
                                              27,
                                              27,
                                            ),
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
                    top: screenHeight * 0.35 - 100,
                    left: MediaQuery.of(context).size.width / 4,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        color: RiveAppTheme.background2,
                        borderRadius: BorderRadius.circular(105),
                        border: Border.all(
                          color: RiveAppTheme.background,
                          width: 10,
                        ),
                      ),
                      child: Icon(Icons.person, size: 110, color: Colors.white),
                    ),
                  ),
                ],
              ),
    );
  }
}
