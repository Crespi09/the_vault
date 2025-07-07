import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/add_item_button.dart';
import 'package:vault_app/app/components/fileCard.dart';
import 'package:vault_app/app/components/folderCard.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class FolderExplorer extends StatefulWidget {
  const FolderExplorer({
    Key? key,
    required this.folderId,
    required this.folderName,
  }) : super(key: key);
  final int folderId;
  final String folderName;

  @override
  _FolderExplorerState createState() => _FolderExplorerState();
}

class _FolderExplorerState extends State<FolderExplorer> {
  Object folder = {};
  List<dynamic> children = [];
  bool isLoading = false;
  String? errorMessage;
  final Dio _dio = Dio();

  List<VaultItem> _folders = [];
  List<VaultItem> _files = [];

  String folderName = '';

  // btn
  late ScrollController _scrollController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchItems();
  }

  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  Future<void> _fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String url = 'http://10.0.2.2:3000/item/${widget.folderId}';
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer ${authService.accessToken}'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<VaultItem> folders = [];
        List<VaultItem> files = [];

        folderName = data['item']['name'];

        if (data['children']['folders'] != null) {
          for (var folder in data['children']['folders']) {
            folders.add(VaultItem.fromFolderJson(folder));
          }
        }

        if (data['children']['files'] != null) {
          for (var file in data['children']['files']) {
            files.add(VaultItem.fromFileJson(file));
          }
        }

        setState(() {
          isLoading = false;
          _folders = folders;
          _files = files;
        });
      } else {
        setState(() {
          errorMessage =
              'Cartella non trovata (status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Widget _buildBreadcrumbs() {
    // Utilizza il nome della cartella padre presente in folder['item']['name']
    String folderName = widget.folderName;
    List<String> parts = folderName.split('/');
    return Wrap(
      children: List.generate(parts.length, (index) {
        String pathItem = folderName;
        // String path = parts.sublist(0, index + 1).join('/');
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // Assicurati di passare il folderId corretto; qui è stato mantenuto "widget.folderId" di esempio
                builder:
                    (_) => FolderExplorer(
                      folderId: widget.folderId,
                      folderName: widget.folderName,
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$pathItem >',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<VaultItem> displayItems = [..._folders, ..._files];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: _buildBreadcrumbs(),
        backgroundColor: RiveAppTheme.background2,
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
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          if (_folders.isNotEmpty) ...[
                            SliverPadding(
                              padding: const EdgeInsets.only(top: 15),
                              sliver: SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    10,
                                  ),
                                  child: Text(
                                    "Cartelle (${_folders.length})",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  key: _folders[index].id,
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    10,
                                    10,
                                  ),
                                  child: FolderCard(
                                    section: _folders[index],
                                    onDeleted: _fetchItems,
                                  ),
                                ),
                                childCount: _folders.length,
                              ),
                            ),
                          ],

                          if (_files.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  10,
                                ),
                                child: Text(
                                  "File (${_files.length})",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  key: _files[index].id,
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    10,
                                    10,
                                  ),
                                  child: FileCard(
                                    section: _files[index],
                                    onDeleted: _fetchItems,
                                  ),
                                ),
                                childCount: _files.length,
                              ),
                            ),
                          ],

                          SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                        ],
                      ),
            ),
          ),
          // Floating Action Menu
          AddItemButton(
            isVisible: true,
            onRefresh: _fetchItems,
            parentId: widget.folderId.toString(),
          ),
        ],
      ),
    );
  }
}
