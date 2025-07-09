import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/models/recent_files.dart';
import 'package:vault_app/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';

class RecenteCard extends StatelessWidget {
  RecenteCard({super.key, required this.section});

  final CourseModel section;
  final Dio _dio = Dio();

  void openFile(BuildContext context) async {
    RecentFile().addFileToList(section.fileId!);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);


      final response = await _dio.get(
        'http://10.0.2.2:3000/file/${section.fileId}',
        options: Options(
          headers: {'Authorization': 'Bearer ${authService.accessToken}'},
          responseType: ResponseType.bytes, // Recupera i bytes del file
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Salva il file nella directory temporanea
        final dir = await getTemporaryDirectory();

        // Determina estensione basata sul content-type restituito dall'API
        final contentType = response.headers.value('content-type');
        String extension = 'pdf'; // default

        if (contentType != null) {
          if (contentType.contains('pdf')) {
            extension = 'pdf';
          } else if (contentType.contains('jpeg')) {
            extension = 'jpg';
          } else if (contentType.contains('png')) {
            extension = 'png';
          } else if (contentType.contains('html')) {
            extension = 'html';
          } else if (contentType.contains('mp3') ||
              contentType.contains('mpeg')) {
            extension = 'mp3';
          } else if (contentType.contains('mp4')) {
            extension = 'mp4';
          }
        }

        final filePath = '${dir.path}/${section.fileId}.$extension';
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        // Apri il file con un'app esterna
        await OpenFile.open(filePath);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey();

    return Container(
      constraints: const BoxConstraints(maxHeight: 90),
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
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.caption,
                  style: const TextStyle(
                    fontSize: 14,
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
                ],
                elevation: 8.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ).then((value) {
                // Gestisci il valore selezionato
                if (value != null) {
                  switch (value) {
                    case 'open':
                      openFile(context);
                      break;
                    default:
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
