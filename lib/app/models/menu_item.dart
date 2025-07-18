import 'package:flutter/material.dart';
import 'package:vault_app/app/models/tab_item.dart';

class MenuItemModel {
  MenuItemModel({this.id, this.title = "", required this.riveIcon});

  UniqueKey? id = UniqueKey();
  String title;
  TabItem riveIcon;

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: 'Home',
      riveIcon: TabItem(stateMachine: 'HOME_interactivity', artboard: 'HOME'),
    ),
    MenuItemModel(
      title: 'Files',
      riveIcon: TabItem(
        stateMachine: 'SEARCH_Interactivity',
        artboard: 'SEARCH',
      ),
    ),
    MenuItemModel(
      title: 'Speciali',
      riveIcon: TabItem(
        stateMachine: 'STAR_Interactivity',
        artboard: 'LIKE/STAR',
      ),
    ),
    // MenuItemModel(title: 'Bin', riveIcon: TabItem(stateMachine: 'TIMER_Interactivity', artboard: 'TIMER')),
    // MenuItemModel(title: 'Settings', riveIcon: TabItem(stateMachine: 'SETTINGS_Interactivity', artboard: 'SETTINGS')),
  ];

  static List<MenuItemModel> menuItems2 = [
    MenuItemModel(
      title: 'Cestino',
      riveIcon: TabItem(stateMachine: 'TIMER_Interactivity', artboard: 'TIMER'),
    ),
    MenuItemModel(
      title: 'Settings',
      riveIcon: TabItem(
        stateMachine: 'SETTINGS_Interactivity',
        artboard: 'SETTINGS',
      ),
    ),
  ];

  static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: 'Dark Mode',
      riveIcon: TabItem(
        stateMachine: 'RELOAD_Interactivity',
        artboard: 'REFRESH/RELOAD',
      ),
    ),
  ];
}
