import 'package:flutter/material.dart';

class CourseModel {
  CourseModel({
    this.id,
    this.itemId,
    this.fileId,
    this.title = "",
    this.subtitle = "",
    this.caption = "",
    this.color = Colors.white,
    this.image = "",
  });

  UniqueKey? id = UniqueKey();
  int? itemId;
  int? fileId;
  String title, caption, image;
  String? subtitle;
  Color color;

  static List<CourseModel> courses = [
    CourseModel(
      title: "Speciali",
      subtitle: "Contenuti salvati nei preferiti",
      caption: "",
      color: const Color(0xFF7850F0),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
    CourseModel(
      title: "Recenti",
      subtitle: "Ultimi folder visualizzati o modificati",
      caption: "",
      color: const Color(0xFF6792FF),
      image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    ),
    CourseModel(
      title: "Cestino",
      subtitle: "Contenuti eliminati di recente",
      caption: "",
      color: const Color(0xFF005FE7),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
  ];

  static List<CourseModel> recents = [
    // CourseModel(*+
    //   title: 'File - 1',
    //   caption: 'Modificato il 15/06/2024',
    //   color: const Color(0xFF9CC5FF),
    //   image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    // ),
    // CourseModel(
    //   title: 'File - 2',
    //   caption: 'Modificato il 08/05/2025',
    //   color: const Color(0xFF6E6AE8),
    //   image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    // ),    //   title: 'File - 3',
    //   caption: 'Modificato il 18/10/2024',
    //   color: const Color(0xFF005FE7),
    //   image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    // ),
    // CourseModel(
    //   title: 'File - 4',
    //   caption: 'Modificato il 09/02/2024',
    //   color: const Color(0xFFBBA6FF),
    //   image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    // ),
  ];
}
