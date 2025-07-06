import 'dart:ffi';

import 'package:flutter/material.dart';

class VaultItem {
  VaultItem({
    this.id,
    this.itemId,
    this.fileId,
    this.title = "",
    this.subtitle = "",
    this.icon = Icons.folder,
    this.color = Colors.white,
    this.image = "",
    this.isFavourite = false,
  });

  UniqueKey? id;
  int? itemId;
  int? fileId;
  String title, image;
  String subtitle;
  IconData icon;
  Color color;
  bool isFavourite;

  // Factory per creare VaultItem da una mappa JSON
  factory VaultItem.fromFolderJson(Map<String, dynamic> json) {
    String name = json['name'] ?? '';

    if (name.length > 12) {
      name = '${name.substring(0, 12)} ...';
    }

    return VaultItem(
      // id: json['id'],
      itemId: json['id'],
      title: name,
      subtitle: _formattedData(json['createdAt']),
      icon: Icons.folder,
      color: _hexToColor(json['color'] ?? '#000000'),
      image: '',
      isFavourite: json['isFavourite'] ?? false,
    );
  }

  factory VaultItem.fromFileJson(Map<String, dynamic> json) {
    String name = json['fileName'] ?? '';

    if (name.length > 12) {
      name = '${name.substring(0, 12)} ...';
    }

    return VaultItem(
      // id: json['itemId'],
      fileId: json['id'],
      itemId: json['itemId'],
      title: name,
      subtitle: _formattedData(json['createdAt']),
      icon: Icons.description,
      color: const Color(0xFF7850F0),
      image: json['path'] ?? '',
      isFavourite: json['isFavourite'] ?? false,
    );
  }

  // Utility per convertire hex in Color
  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF' + hex;
    return Color(int.parse(hex, radix: 16));
  }

  static String _formattedData(String date) {
    if (date.isEmpty) {
      return '';
    }

    int tIndex = date.indexOf('T');
    if (tIndex != -1) {
      return date.substring(0, tIndex);
    }
    return date;
  }
}
