import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/edit_dialog.dart';
import 'package:vault_app/app/components/folder_explorer.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/models/recent_folders.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.section, this.onDeleted});

  final VaultItem section;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    // serve per il drag dell' elemento
    return LongPressDraggable<VaultItem>(
      data: section,
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
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildDragTarget(context),
      ),
      child: _buildDragTarget(context),
    );
  }

  Widget _buildDragTarget(BuildContext context) {
    GlobalKey key = GlobalKey();
    final Dio _dio = Dio();
    String? _errorMessage;

    void deleteFile() async {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        final response = await _dio.post(
          'http://10.0.2.2:3000/bin',
          data: {'itemId': (section.itemId).toString()},
          options: Options(
            headers: {'Authorization': 'Bearer ${authService.accessToken}'},
          ),
        );

        // final response = await _dio.delete(
        //   'http://10.0.2.2:3000/item/${section.itemId}',
        //   options: Options(
        //     headers: {'Authorization': 'Bearer ${authService.accessToken}'},
        //   ),
        // );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (onDeleted != null) {
            onDeleted!();
          }
        }
      } catch (e) {
        _errorMessage = 'Errore eliminazione File';
      }
    }

    void editFolder() async {
      showDialog(
        context: context,
        builder:
            (context) => EditDialog(
              currentName: section.title,
              isFolder: true,
              onEdit: (newName) async {
                try {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );

                  final itemId = section.itemId;

                  final response = await _dio.put(
                    'http://10.0.2.2:3000/item/$itemId',
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

    void favouriteBtnClicked(VaultItem file) async {
      if (file.isFavourite) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);

          final itemId = section.itemId;

          final response = await _dio.delete(
            'http://10.0.2.2:3000/favorite/$itemId ',
            options: Options(
              headers: {'Authorization': 'Bearer ${authService.accessToken}'},
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 204) {
            // lo uso per ricaricare
            if (onDeleted != null) {
              onDeleted!();
            }
          }
        } catch (e) {
          _errorMessage = 'Error Edit File';
        }
      } else {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);

          final response = await _dio.post(
            'http://10.0.2.2:3000/favorite',
            data: {'itemId': (section.itemId).toString()},
            options: Options(
              headers: {'Authorization': 'Bearer ${authService.accessToken}'},
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // lo uso per ricaricare
            if (onDeleted != null) {
              onDeleted!();
            }
          }
        } catch (e) {
          _errorMessage = 'Error Edit File $e';
        }
      }
    }

    // questo serve per rendere folderCard il target del drag and drop
    return DragTarget<VaultItem>(
      onWillAccept: (data) {
        return data != null && data.itemId != section.itemId;
      },
      onAccept: (data) async {
        // debug
        // debugPrint('DATA_ITEM_ID :');
        // debugPrint(data.itemId.toString());
        // debugPrint('IMPORTO IN : ');
        // debugPrint(section.itemId.toString());

        // if (data.fileId != null) {
        //   debugPrint('FILE_ID :');
        //   debugPrint(data.fileId.toString());
        // }

        try {
          final authService = Provider.of<AuthService>(context, listen: false);

          final response = await _dio.put(
            'http://10.0.2.2:3000/item/${data.itemId}',
            data: {'parentId': (section.itemId).toString()},
            options: Options(
              headers: {'Authorization': 'Bearer ${authService.accessToken}'},
            ),
          );
          if (response.statusCode == 200 || response.statusCode == 204) {
            // per aggiornare interfaccia
            if (onDeleted != null) {
              onDeleted!();
            }
          }
        } catch (e) {
          _errorMessage = 'Errore durante l\'aggiornamento del parentId';
        }
      },
      builder: (context, candidateData, rejectedData) {
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
              IconButton(
                icon: Icon(
                  section.isFavourite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  favouriteBtnClicked(section);
                },
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
                      btnPressed.dx,
                      btnPressed.dy + 40,
                      MediaQuery.of(context).size.width - (btnPressed.dx + 75),
                      MediaQuery.of(context).size.height -
                          (btnPressed.dy - 100),
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
                          if (section.itemId != null) {
                            RecentFolders().addFolderToList(section.itemId!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FolderExplorer(
                                      folderId: section.itemId!,
                                      folderName: section.title,
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Folder ID mancante.'),
                              ),
                            );
                          }
                          break;
                        case 'edit':
                          editFolder();
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
      },
    );
  }
}
