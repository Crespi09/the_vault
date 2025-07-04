import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/edit_dialog.dart';
import 'package:vault_app/app/models/recent_files.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class FileCard extends StatelessWidget {
  const FileCard({super.key, required this.section, this.onDeleted});

  final VaultItem section;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    // Inseriamo la logica drag all'interno di LongPressDraggable.
    return LongPressDraggable<VaultItem>(
      data: section,
      // Se vuoi fornire un feedback personalizzato durante il drag
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: section.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 20),
                child: Icon(section.icon, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildCard(context)),
      // NOTA: LongPressDraggable attiva il drag dopo un long press (default ~500ms).
      // Per 2 secondi potresti dover implementare una soluzione custom.
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    GlobalKey key = GlobalKey();
    final Dio _dio = Dio();
    String? _errorMessage;

    void deleteFile() async {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        final response = await _dio.delete(
          'http://10.0.2.2:3000/item/${section.itemId}',
          options: Options(
            headers: {'Authorization': 'Bearer ${authService.accessToken}'},
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (onDeleted != null) {
            onDeleted!();
          }
        }
      } catch (e) {
        _errorMessage = 'Errore eliminazione File';
      }
    }

    void openFile() async {
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
        _errorMessage = 'Errore apertura File';
      }
    }

    void editFile() async {
      showDialog(
        context: context,
        builder:
            (context) => EditDialog(
              currentName: section.title,
              isFolder: false,
              onEdit: (newName) async {
                try {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );

                  final fileId = section.fileId;

                  final response = await _dio.put(
                    'http://10.0.2.2:3000/file/$fileId ',
                    data: {'name': newName},
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer ${authService.accessToken}',
                      },
                    ),
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 204) {
                    // lo uso per ricaricare
                    if (onDeleted != null) {
                      onDeleted!();
                    }
                  }

                  debugPrint('Nuovo nome: $newName');
                } catch (e) {
                  _errorMessage = 'Error Edit File';
                }
              },
            ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: section.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 20),
            child: Icon(section.icon, color: Colors.white),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  section.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: VerticalDivider(thickness: 2, width: 0),
          ),
          IconButton(
            key: key,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              RenderBox box =
                  key.currentContext?.findRenderObject() as RenderBox;
              Offset btnPressed = box.localToGlobal(Offset.zero);

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
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Center(
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
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
                          fontSize: 14,
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
                  borderRadius: BorderRadius.circular(5),
                ),
              ).then((value) {
                if (value != null) {
                  switch (value) {
                    case 'delete':
                      deleteFile();
                      break;
                    case 'open':
                      openFile();
                      break;
                    case 'edit':
                      editFile();
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
