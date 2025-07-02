import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vault_app/app/components/add_item_button.dart';

class FolderExplorer extends StatefulWidget {
  final int folderId;
  const FolderExplorer({Key? key, required this.folderId}) : super(key: key);

  @override
  _FolderExplorerState createState() => _FolderExplorerState();
}

class _FolderExplorerState extends State<FolderExplorer> {
  // Ora folder sarà una mappa contenente 'item' e 'children'
  Object folder = {};
  // Lista dei figli (sia cartelle che file)
  List<dynamic> children = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFolderItems();
  }

  Future<void> _fetchFolderItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      // Sostituisci l'URL con il tuo endpoint API
      final response =
          await dio.get('http://10.0.2.2:3000/folder/${widget.folderId}');


      if (response.statusCode == 200) {
        final data = response.data;
        // Estrai file e cartelle da "children"
        final List<dynamic> files = data['children']['files'] ?? [];
        final List<dynamic> folders = data['children']['folders'] ?? [];

        List<dynamic> childrenItems = [];
        // Per le cartelle, aggiungiamo un flag per identificarle
        for (var f in folders) {
          f['isFolder'] = true;
          childrenItems.add(f);
        }
        // Per i file, aggiungiamo un flag e usiamo fileName al posto di name
        for (var f in files) {
          f['isFolder'] = false;
          f['name'] = f['fileName'];
          childrenItems.add(f);
        }
        setState(() {
          folder = data;
          children = childrenItems;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Errore durante il caricamento dei dati';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildBreadcrumbs() {
    // Utilizza il nome della cartella padre presente in folder['item']['name']
    String folderName =
        (folder is Map && (folder as Map).containsKey('item') && (folder as Map)['item'] != null)
            ? (folder as Map)['item']['name']
            : '';
    List<String> parts = folderName.split('/');
    return Wrap(
      children: List.generate(parts.length, (index) {
        String pathItem = parts[index];
        String path = parts.sublist(0, index + 1).join('/');
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // Assicurati di passare il folderId corretto; qui è stato mantenuto "widget.folderId" di esempio
                builder: (_) => FolderExplorer(folderId: widget.folderId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$pathItem >',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildBreadcrumbs(),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : ListView.builder(
                          itemCount: children.length,
                          itemBuilder: (_, index) {
                            final item = children[index];
                            final bool isFolder = item['isFolder'] == true;
                            // Usa il colore in base al tipo (puoi eventualmente usare item['color'] se impostato)
                            final Color bgColor =
                                isFolder ? Colors.blueAccent : Colors.deepPurple;
                            final IconData iconData =
                                isFolder ? Icons.folder : Icons.insert_drive_file;
                            final String title = item['name'] ?? '';
                            final String subtitle =
                                (item['createdAt'] != null && item['createdAt'] is String)
                                    ? item['createdAt'].toString().split('T').first
                                    : '';
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(iconData, color: Colors.white, size: 28),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                    onPressed: () {
                                      // Eventuali azioni per ciascun elemento
                                    },
                                  ),
                                ],
                                
                              ),
                              
                            );
                          },
                        ),
            ),
          ),
          // Floating Action Menu
          AddItemButton(
            isVisible: true,
            onRefresh: _fetchFolderItems,
            parentId: widget.folderId.toString(),
          ),
        ],
      ),
    );
  }
}