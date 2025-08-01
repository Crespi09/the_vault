import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:vault_app/app/components/category_page.dart';
import 'package:vault_app/app/components/menu_row.dart';
import 'package:vault_app/app/models/menu_item.dart';
import 'package:vault_app/app/theme.dart';

import 'dart:math' show max;

import 'package:vault_app/services/auth_service.dart';
import 'package:vault_app/services/user_service.dart';

class SideMenu extends StatefulWidget {
  final Function(int)? onTabChange;
  final VoidCallback? onMenuClose;

  const SideMenu({super.key, this.onTabChange, this.onMenuClose});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _historyMenuIcons = MenuItemModel.menuItems2;
  final List<MenuItemModel> _themeMenuIcons = MenuItemModel.menuItems3;

  double storageUsed = 0;
  int totaleStorage = 500;
  final Dio _dio = Dio();

  String _selectedMenu = MenuItemModel.menuItems[0].title;
  bool _isDarkMode = false;

  Map<String, dynamic>? _userData;

  void onThemeRiveIconInit(artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      _themeMenuIcons[0].riveIcon.stateMachine,
    );
    artboard.addController(controller!);
    _themeMenuIcons[0].riveIcon.status =
        controller.findInput<bool>('active') as SMIBool;
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;

      switch (menu.title.toLowerCase()) {
        case 'home':
          widget.onTabChange?.call(0); // redirect a home
          widget.onMenuClose?.call(); // chiude il menu
          break;
        case 'files':
          widget.onTabChange?.call(1); // redirect a folder
          // widget.onMenuClose?.call();
          break;
        case 'speciali':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(title: menu.title),
            ),
          );
          break;
        case 'cestino':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(title: menu.title),
            ),
          );
          break;
        default:
      }
    });
  }

  void onThemeToggle(value) {
    setState(() {
      _isDarkMode = value;
    });
    _themeMenuIcons[0].riveIcon.status!.change(value);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getStorageUsed();
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      debugPrint('Token: ${authService.accessToken}');
      _userData = await UserService.getUser(authService.accessToken!);
      debugPrint('Dati utente ricevuti: $_userData');

      setState(() {});
    } catch (e) {
      debugPrint('Eccezione nel caricamento dati utente: $e');
      debugPrint('Tipo di errore: ${e.runtimeType}');
    }
  }

  Future<void> _getStorageUsed() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final response = await _dio.get(
        'http://10.0.2.2:3000/storage',
        options: Options(
          headers: {'Authorization': 'Bearer ${authService.accessToken}'},
        ),
      );

      debugPrint('STORAGEEEE');
      debugPrint(response.data['storage'].toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        double storageInBytes = response.data['storage'].toDouble();
        double storageInGB = storageInBytes / (1024 * 1024 * 1024);
        setState(() {
          storageUsed = double.parse(storageInGB.toStringAsFixed(2));
        });

        debugPrint(storageInBytes.toString());
        debugPrint(storageInGB.toString());
        debugPrint(storageUsed.toString());
      }
    } catch (e) {
      debugPrint('Eccezione nel caricamento total storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: max(0, MediaQuery.of(context).padding.bottom - 60),
      ),
      constraints: const BoxConstraints(maxWidth: 288),
      decoration: BoxDecoration(
        color: RiveAppTheme.background2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?['email'] ?? 'Nome Utente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userData?['createdAt'] != null
                          ? 'Since ${DateTime.parse(_userData!['createdAt']).day}/${DateTime.parse(_userData!['createdAt']).month}/${DateTime.parse(_userData!['createdAt']).year}'
                          : 'Since',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuButtonSection(
                    title: 'BROWSE',
                    selectedMenu: _selectedMenu,
                    menuIcons: _browseMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                  MenuButtonSection(
                    title: 'HISTORY',
                    selectedMenu: _selectedMenu,
                    menuIcons: _historyMenuIcons,
                    onMenuPress: onMenuPress,
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top:
                          screenHeight *
                          0.03,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Storage",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "$storageUsed / $totaleStorage GB",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: storageUsed,
                          backgroundColor: RiveAppTheme.background,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlue,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          minHeight: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Opacity(
                    opacity: 0.6,
                    child: RiveAnimation.asset(
                      'assets/samples/ui/rive_app/rive/icons.riv',
                      stateMachines: [_themeMenuIcons[0].riveIcon.stateMachine],
                      artboard: _themeMenuIcons[0].riveIcon.artboard,
                      onInit: onThemeRiveIconInit,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _themeMenuIcons[0].title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CupertinoSwitch(value: _isDarkMode, onChanged: onThemeToggle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButtonSection extends StatelessWidget {
  const MenuButtonSection({
    super.key,
    required this.title,
    required this.menuIcons,
    this.selectedMenu = 'Home',
    this.onMenuPress,
  });

  final String title;
  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 40,
            bottom: 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              for (var menu in menuIcons) ...[
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                MenuRow(
                  menu: menu,
                  selectedMenu: selectedMenu,
                  onMenuPress: () => onMenuPress!(menu),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
