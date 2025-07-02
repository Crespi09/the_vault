import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/folder_explorer.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/services/auth_service.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.section, this.onDeleted});

  final VaultItem section;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
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
                // Gestisci il valore selezionato
                if (value != null) {
                  switch (value) {
                    case 'delete':
                      deleteFile();
                      break;
                    case 'open':
                      if (section.itemId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    FolderExplorer(folderId: section.itemId!),
                          ),
                        );
                      } else {
                        // Gestisci il caso in cui itemId è null (ad esempio mostrando un dialogo di errore)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Folder ID mancante.')),
                        );
                      }
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
