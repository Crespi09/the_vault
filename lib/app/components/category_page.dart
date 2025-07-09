import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/SearchBarComponents.dart';
import 'package:vault_app/app/components/fileCard.dart';
import 'package:vault_app/app/components/file_bin_card.dart';
import 'package:vault_app/app/components/folderCard.dart';
import 'package:vault_app/app/components/folder_bin_card.dart';
import 'package:vault_app/app/models/recent_folders.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/services/auth_service.dart';

class CategoryPage extends StatefulWidget {
  final String title;

  const CategoryPage({super.key, required this.title});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final Dio _dio = Dio();

  bool _isLoading = true;
  String? _errorMessage;
  List<VaultItem> _folders = [];
  List<VaultItem> _files = [];
  List<VaultItem> _filteredFolders = [];
  List<VaultItem> _filteredFiles = [];

  List<dynamic> _recentFoldersFromApi = [];
  Object queryPar = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      String endpoint;
      Map<String, dynamic>? queryParams;

      switch (widget.title.toLowerCase()) {
        case 'speciali':
          endpoint = 'http://100.84.178.101:3000/favorite';
          break;
        case 'cestino':
          endpoint = 'http://100.84.178.101:3000/bin';
          break;
        case 'recenti':
          endpoint = 'http://100.84.178.101:3000/item';
          List<int> recentFolderIds = RecentFolders().getFolders();

          if (recentFolderIds.isEmpty) {
            debugPrint('Nessun folder recente');
            setState(() {
              _folders = [];
              _files = [];
              _filteredFolders = [];
              _filteredFiles = [];
              _isLoading = false;
            });
            return;
          }
          String idsString = recentFolderIds.join(',');
          queryParams = {'ids': idsString};
          break;
        default:
          endpoint = 'http://100.84.178.101:3000/item';
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer ${authService.accessToken}'},
        ),
      );

      if (response.statusCode == 200) {
        List<VaultItem> folders = [];
        List<VaultItem> files = [];

        if (widget.title.toLowerCase() == 'recenti') {
          final responseData = response.data as List<dynamic>;

          for (var item in responseData) {
            folders.add(VaultItem.fromFolderJson(item));
          }
        } else {
          final responseData = response.data as Map<String, dynamic>;

          if (responseData['folders'] != null) {
            for (var folder in responseData['folders']) {
              folders.add(VaultItem.fromFolderJson(folder));
            }
          }

          if (responseData['files'] != null) {
            for (var file in responseData['files']) {
              files.add(VaultItem.fromFileJson(file));
            }
          }
        }

        setState(() {
          _folders = folders;
          _files = files;
          _filteredFolders = folders;
          _filteredFiles = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = 'Errore nel caricamento dei dati';
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFolders = _folders;
        _filteredFiles = _files;
      } else {
        final lowerQuery = query.toLowerCase();

        _filteredFolders =
            _folders.where((folder) {
              return folder.title.toLowerCase().contains(lowerQuery) ||
                  folder.subtitle.toLowerCase().contains(lowerQuery);
            }).toList();

        _filteredFiles =
            _files.where((file) {
              return file.title.toLowerCase().contains(lowerQuery) ||
                  file.subtitle.toLowerCase().contains(lowerQuery);
            }).toList();
      }
    });
  }

  void _onItemDeleted() {
    _loadItems();
  }

  // Combina folders e files per la visualizzazione
  List<VaultItem> get _filteredItems {
    return [..._filteredFolders, ..._filteredFiles];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: RiveAppTheme.background2,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 16,
                left: 5,
                right: 5,
              ),
              child: SearchBarComponents(onSearch: _onSearch),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadItems,
                              child: const Text('Riprova'),
                            ),
                          ],
                        ),
                      )
                      : _filteredItems.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun elemento trovato',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadItems,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child:
                                  item.fileId != null
                                      ? (widget.title.toLowerCase() == 'cestino'
                                          ? FileBinCard(
                                            section: item,
                                            onDeleted: _onItemDeleted,
                                          )
                                          : FileCard(
                                            section: item,
                                            onDeleted: _onItemDeleted,
                                          ))
                                      : (widget.title.toLowerCase() == 'cestino'
                                          ? FolderBinCard(
                                            section: item,
                                            onDeleted: _onItemDeleted,
                                          )
                                          : FolderCard(
                                            section: item,
                                            onDeleted: _onItemDeleted,
                                          )),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
