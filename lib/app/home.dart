import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:vault_app/app/components/SearchBarComponents.dart';
import 'dart:math' as math;
import 'package:vault_app/app/navigation/custom_tab_bar.dart';
import 'package:vault_app/app/navigation/folder_tab_view.dart';
import 'package:vault_app/app/navigation/home_tab_view.dart';
import 'package:vault_app/app/navigation/side_menu.dart';
import 'package:vault_app/app/navigation/user_tab_view.dart';
import 'package:vault_app/app/on_boarding/onboarding_view.dart';
import 'package:vault_app/app/on_boarding/signin_view.dart';
import 'package:vault_app/app/theme.dart';

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

  late final List<Widget> _screens;

  // Aggiungi una chiave globale per la FolderTabView
  final GlobalKey<FolderTabViewState> _folderTabKey =
      GlobalKey<FolderTabViewState>();

  // Aggiungi una variabile per tracciare il tab corrente
  int _currentTabIndex = 0;

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  bool _logged = false;

  void updateLoggedStatus(bool status) {
    setState(() {
      _logged = status;
    });
  }

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine',
    );
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>('isOpen') as SMIBool;
    _menuBtn.value = true;
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    SystemChrome.setSystemUIOverlayStyle(
      _menuBtn.value ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
  }

  // Aggiungi questo metodo per gestire la ricerca
  void _handleSearch(String query) {
    // Se non siamo già nel tab delle cartelle (indice 1), cambia tab
    if (_currentTabIndex != 1) {
      setState(() {
        _currentTabIndex = 1;
        _tabBody = _screens[1];
      });

      // Aspetta un frame per assicurarsi che il widget sia costruito
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _folderTabKey.currentState?.performSearch(query);
      });
    } else {
      // Se siamo già nel tab delle cartelle, esegui direttamente la ricerca
      _folderTabKey.currentState?.performSearch(query);
    }
  }

  @override
  void initState() {
    // Usa la chiave globale per la FolderTabView
    _screens = [
      const HomeTabView(),
      FolderTabView(key: _folderTabKey),
      UserTabView(onLogin: updateLoggedStatus),
    ];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.linear),
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
          Positioned(
            child: Container(
              color:
                  _logged ? RiveAppTheme.background2 : RiveAppTheme.background,
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                          ((1 - _sidebarAnim.value) * -30) * math.pi / 180,
                        )
                        ..translate((1 - _sidebarAnim.value) * -300),
                  child: child,
                );
              },
              child: FadeTransition(
                opacity: _sidebarAnim,
                child: SideMenu(
                  onTabChange: (tabIndex) {
                    setState(() {
                      _currentTabIndex = tabIndex;
                      _tabBody = _screens[tabIndex];
                    });
                  },
                ),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 - _sidebarAnim.value * 0.1,
                  child: Transform.translate(
                    offset: Offset(_sidebarAnim.value * 265, 0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(
                              (_sidebarAnim.value * 30) * math.pi / 180,
                            ),
                      child: child,
                    ),
                  ),
                );
              },
              child:
                  _logged
                      ? _tabBody
                      : OnboardingView(onLogin: updateLoggedStatus),
            ),
          ),

          _logged
              ? RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _sidebarAnim,
                  builder: (context, child) {
                    return SafeArea(
                      child: Row(
                        children: [
                          SizedBox(width: _sidebarAnim.value * 216),
                          child!,
                        ],
                      ),
                    );
                  },
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
              )
              : SizedBox(),

          // Search bar modificata per gestire la ricerca
          _logged
              ? Positioned(
                top:
                    MediaQuery.of(context).padding.top +
                    MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.width * 0.05,
                child: AnimatedBuilder(
                  animation: _sidebarAnim,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 1, 0.0006)
                            ..rotateY(_sidebarAnim.value * math.pi / 4)
                            ..rotateZ(_sidebarAnim.value * math.pi / -20.33)
                            ..translate(
                              _sidebarAnim.value *
                                  MediaQuery.of(context).size.width *
                                  0.6,
                              _sidebarAnim.value *
                                  MediaQuery.of(context).size.height *
                                  0.08,
                              0,
                            ),
                      child: child!,
                    );
                  },
                  child: SearchBarComponents(
                    onSearch: _handleSearch,
                    onSearchPressed: () {
                      // Opzionale: gestisci il tap sulla search bar
                      // Ad esempio, potresti voler navigare al tab delle cartelle
                      if (_currentTabIndex != 1) {
                        setState(() {
                          _currentTabIndex = 1;
                          _tabBody = _screens[1];
                        });
                      }
                    },
                  ),
                ),
              )
              : SizedBox(),

          _logged
              ? IgnorePointer(
                ignoring: true,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _sidebarAnim,
                      builder: (context, child) {
                        return Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RiveAppTheme.background.withOpacity(0),
                                RiveAppTheme.background.withOpacity(
                                  1 - _sidebarAnim.value,
                                ),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
              : SizedBox(),
        ],
      ),
      bottomNavigationBar:
          _logged
              ? RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _sidebarAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _sidebarAnim.value * 300),
                      child: child!,
                    );
                  },
                  child: CustomTabBar(
                    onTabChange: (tabIndex) {
                      setState(() {
                        _currentTabIndex = tabIndex;
                        _tabBody = _screens[tabIndex];
                      });
                    },
                  ),
                ),
              )
              : null,
    );
  }
}
