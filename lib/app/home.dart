import 'package:flutter/material.dart';
import 'package:vault_app/app/navigation/custom_tab_bar.dart';
import 'package:vault_app/app/navigation/home_tab_view.dart';
import 'package:vault_app/app/theme.dart';

// TODO - da togliere, solo di test per le pagine
Widget commonTabScene(String tabName) {
  return Container(
    alignment: Alignment.center,
    child: Text(tabName, style: const TextStyle(fontSize: 28)),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _tabBody = Container(color: RiveAppTheme.background);
  final List<Widget> _screens = [
    const HomeTabView(),
    commonTabScene('Search'),
    commonTabScene('Timer'),
    commonTabScene('Bell'),
    commonTabScene('User'),
  ];

  @override
  void initState() {
    _tabBody = _screens.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _tabBody,
      bottomNavigationBar: CustomTabBar(
        onTabChange: (tabIndex) {
          setState(() {
            _tabBody = _screens[tabIndex];
          });
        },
      ),
    );
  }
}
