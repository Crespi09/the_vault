import 'package:flutter/material.dart';
import 'package:vault_app/app/models/courses.dart';

class RecenteCard extends StatelessWidget {
  const RecenteCard({super.key, required this.section});

  final CourseModel section;

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey();

    return Container(
      constraints: const BoxConstraints(maxHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: section.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.caption,
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: VerticalDivider(thickness: 2, width: 0),
          ),

          // Image.asset(section.image),
          IconButton(
            key: key,
            icon: const Icon(
              Icons.more_vert, // Icona con 3 puntini verticali
              color: Colors.white,
            ),
            onPressed: () {
              // Azione da eseguire quando il pulsante viene premuto
              RenderBox box =
                  key.currentContext?.findRenderObject() as RenderBox;
              Offset btnPressed = box.localToGlobal(
                Offset.zero,
              ); //this is global position

              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  btnPressed.dx, // left
                  btnPressed.dy + 40, // top
                  MediaQuery.of(context).size.width -
                      (btnPressed.dx + 75), // right
                  MediaQuery.of(context).size.height -
                      (btnPressed.dy - 100), // bottom
                ),
                items: [
                  PopupMenuItem(
                    value: 'open',
                    child: Center(
                      child: Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move_to',
                    child: Center(
                      child: Text(
                        'Move To',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Center(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color.fromRGBO(179, 41, 41, 1),
                        ),
                      ),
                    ),
                  ),
                ],
                elevation: 8.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ).then((value) {
                // Gestisci il valore selezionato
                if (value != null) {}
              });
            },
          ),
        ],
      ),
    );
  }
}
