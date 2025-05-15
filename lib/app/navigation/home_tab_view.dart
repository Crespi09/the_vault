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
                    padding: EdgeInsets.symmetric(horizontal: 20),
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
                      style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
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
          // Search bar posizionata in alto a destra
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Container(
              width: 300,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: RiveAppTheme.shadow.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: Icon(Icons.search),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        // Handle search input changes
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      // Clear the search field
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
