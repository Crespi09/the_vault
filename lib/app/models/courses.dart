import 'package:flutter/material.dart';

class CourseModel {
  CourseModel({
    this.id,
    this.title = "",
    this.subtitle = "",
    this.caption = "",
    this.color = Colors.white,
    this.image = "",
  });

  UniqueKey? id = UniqueKey();
  String title, caption, image;
  String? subtitle;
  Color color;

  static List<CourseModel> courses = [
    CourseModel(
      title: "Speciali",
      subtitle: "Build and animate an IOS app from scratch",
      caption: "20 sections - 566 hours",
      color: const Color(0xFF7850F0),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
    CourseModel(
      title: "Recenti",
      subtitle: "Build and animate an IOS app from scratch",
      caption: "89 sections - 99 hours",
      color: const Color(0xFF6792FF),
      image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    ),
    CourseModel(
      title: "Cestino",
      subtitle:
          "Build and animate an IOS app from scratch aaaaaaaaaaaaaaaaaaaaaaa",
      caption: "2 sections - 33 hours",
      color: const Color(0xFF005FE7),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
  ];

  static List<CourseModel> recents = [
    CourseModel(
      title: 'File - 1',
      caption: 'Modificato il 15/06/2024',
      color: const Color(0xFF9CC5FF),
      image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    ),
    CourseModel(
      title: 'File - 2',
      caption: 'Modificato il 08/05/2025',
      color: const Color(0xFF6E6AE8),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
    CourseModel(
      title: 'File - 3',
      caption: 'Modificato il 18/10/2024',
      color: const Color(0xFF005FE7),
      image: 'assets/samples/ui/rive_app/images/topics/topic_2.png',
    ),
    CourseModel(
      title: 'File - 4',
      caption: 'Modificato il 09/02/2024',
      color: const Color(0xFFBBA6FF),
      image: 'assets/samples/ui/rive_app/images/topics/topic_1.png',
    ),
  ];
}
