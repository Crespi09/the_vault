import 'package:flutter/material.dart';
import 'package:vault_app/app/components/recentCard.dart';
import 'package:vault_app/app/components/vcard.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/theme.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<CourseModel> _courses = CourseModel.courses;
  final List<CourseModel> _recents = CourseModel.recents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: RiveAppTheme.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const Text(
                      "Folders",
                      style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _courses
                              .map(
                                (course) => Padding(
                                  key: course.id,
                                  padding: const EdgeInsets.all(10),
                                  child: VCard(course: course),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Text(
                      "Recent Files",
                      style: TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                    ),
                  ),
                  ...List.generate(
                    _recents.length,
                    (index) => Padding(
                      key: _recents[index].id,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: RecenteCard(section: _recents[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
