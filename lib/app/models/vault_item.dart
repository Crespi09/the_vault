import 'package:flutter/material.dart';

class VaultItem {
  VaultItem({
    this.id,
    this.title = "",
    this.subtitle = "",
    this.icon = Icons.folder,
    this.color = Colors.white,
    this.image = "",
  });

  UniqueKey? id = UniqueKey();
  String title, image;
  String subtitle;
  IconData icon;
  Color color;

  static List<VaultItem> folders = [
    VaultItem(
      title: "Folder Kirbi",
      subtitle: "Modificato il 09/02/2024",
      icon: Icons.folder,
      color: const Color(0xFF7850F0),
      image: 'assets/uploads/files/kirbi.png',
    ),
    VaultItem(
      title: "Folder Previ",
      subtitle: "Modificato il 18/10/2024",
      icon: Icons.folder,
      color: const Color(0xFF6792FF),
      image: 'assets/uploads/files/previ.png',
    ),
    VaultItem(
      title: "Folder Robot",
      subtitle: "Modificato il 08/05/2025",
      icon: Icons.folder,
      color: const Color(0xFF005FE7),
      image: 'assets/uploads/files/robot.png',
    ),
    VaultItem(
      title: "Folder Slurp",
      subtitle: "Modificato il 15/06/2024",
      icon: Icons.folder,
      color: const Color(0xFFBBA6FF),
      image: 'assets/uploads/files/slurp.png',
    ),
  ];

  static List<VaultItem> files = [
    VaultItem(
      title: "Foto Kirbi",
      subtitle: "Modificato il 09/02/2024",
      icon: Icons.file_open,
      color: const Color(0xFF7850F0),
      image: 'assets/uploads/files/kirbi.png',
    ),
    VaultItem(
      title: "Foto Previ",
      subtitle: "Modificato il 18/10/2024",
      icon: Icons.file_open,
      color: const Color(0xFF6792FF),
      image: 'assets/uploads/files/previ.png',
    ),
    VaultItem(
      title: "Foto Robot",
      subtitle: "Modificato il 08/05/2025",
      icon: Icons.file_open,
      color: const Color(0xFF005FE7),
      image: 'assets/uploads/files/robot.png',
    ),
    VaultItem(
      title: "Foto Slurp",
      subtitle: "Modificato il 15/06/2024",
      icon: Icons.file_open,
      color: const Color(0xFFBBA6FF),
      image: 'assets/uploads/files/slurp.png',
    ),
  ];
}
