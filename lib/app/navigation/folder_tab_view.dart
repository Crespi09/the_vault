import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/add_item_button.dart';
import 'package:vault_app/app/components/fileCard.dart';
import 'package:vault_app/app/components/folderCard.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class FolderTabView extends StatefulWidget {
  const FolderTabView({super.key});

  @override
  State<FolderTabView> createState() => FolderTabViewState();
}

class FolderTabViewState extends State<FolderTabView> {
  List<VaultItem> _folders = [];
  List<VaultItem> _files = [];
  List<VaultItem> _filteredFolders = [];
  List<VaultItem> _filteredFiles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  final Dio _dio = Dio();

  //btn
  bool _myVaultBtn = true;
  late ScrollController _scrollController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      String apiUrl =
          _myVaultBtn
              ? '${Env.apiBaseUrl}item/all?limit=50&offset=0'
              : '${Env.apiBaseUrl}shared/all?limit=5&offset=0';

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;

      List<VaultItem> folders = [];
      List<VaultItem> files = [];

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

      setState(() {
        _folders = folders;
        _files = files;
        _filteredFolders = folders;
        _filteredFiles = files;
        _isLoading = false;
      });

      if (_searchQuery.isNotEmpty) {
        _filterItems(_searchQuery);
      }

      debugPrint('Items ottenuti: $responseData');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore durante il caricamento: $e';
      });
      debugPrint('Errore durante il fetch degli items: $e');
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;

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

  void performSearch(String query) {
    _filterItems(query);
  }

  @override
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

  void onBtnPressed(bool selection) {
    if (_myVaultBtn != selection) {
      setState(() {
        _myVaultBtn = selection;
        _isLoading = true;
      });
      _fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
        child: Stack(
          children: [
            Column(
              children: [
                // Risultati di ricerca
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Risultati per: "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () {
                            _filterItems('');
                          },
                        ),
                      ],
                    ),
                  ),

                // Tab buttons
                if (_searchQuery.isEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 0,
                            top: 12,
                            bottom: 12,
                          ),
                          pressedOpacity: 0.7,
                          onPressed: () => onBtnPressed(true),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _myVaultBtn
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                AnimatedScale(
                                  duration: Duration(milliseconds: 200),
                                  scale: _myVaultBtn ? 1.1 : 1.0,
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Icon(
                                      Icons.folder,
                                      color:
                                          _myVaultBtn
                                              ? Colors.blue
                                              : Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color:
                                          _myVaultBtn
                                              ? Colors.blue
                                              : Colors.white,
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          _myVaultBtn
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                    child: Text('My Vault'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 0,
                          top: 12,
                          bottom: 12,
                        ),
                        child: Container(
                          height: 50,
                          child: VerticalDivider(
                            thickness: 2,
                            width: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(12),
                          pressedOpacity: 0.7,
                          onPressed: () => onBtnPressed(false),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  !_myVaultBtn
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                AnimatedScale(
                                  duration: Duration(milliseconds: 200),
                                  scale: !_myVaultBtn ? 1.1 : 1.0,
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Icon(
                                      Icons.share,
                                      color:
                                          !_myVaultBtn
                                              ? Colors.blue
                                              : Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color:
                                          !_myVaultBtn
                                              ? Colors.blue
                                              : Colors.white,
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          !_myVaultBtn
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                    child: Text('Shared'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],

                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0.3, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Menu
            AddItemButton(
              isVisible: _isVisible,
              onRefresh: _fetchItems,
              parentId:
                  null, // Qui puoi passare l'ID della cartella corrente se necessario
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      key: ValueKey('${_myVaultBtn}_${_searchQuery}'),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchItems,
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              )
              : _buildItemsList(),
    );
  }

  Widget _buildItemsList() {
    if (_filteredFolders.isEmpty && _filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nessun risultato trovato per "$_searchQuery"'
                  : 'Nessun elemento disponibile',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (_filteredFolders.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.only(top: 15),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  "Cartelle (${_filteredFolders.length})",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                key: _filteredFolders[index].id,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: FolderCard(
                  section: _filteredFolders[index],
                  onDeleted: _fetchItems,
                ),
              ),
              childCount: _filteredFolders.length,
            ),
          ),
        ],

        if (_filteredFiles.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "File (${_filteredFiles.length})",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                key: _filteredFiles[index].id,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: FileCard(
                  section: _filteredFiles[index],
                  onDeleted: _fetchItems,
                ),
              ),
              childCount: _filteredFiles.length,
            ),
          ),
        ],

        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
