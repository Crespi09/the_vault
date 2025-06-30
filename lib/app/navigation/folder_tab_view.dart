import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/create_folder_modal.dart';
import 'package:vault_app/app/components/fileCard.dart';
import 'package:vault_app/app/components/folderCard.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/services/auth_service.dart';

class FolderTabView extends StatefulWidget {
  const FolderTabView({super.key});

  @override
  State<FolderTabView> createState() => _FolderTabViewState();
}

class _FolderTabViewState extends State<FolderTabView> {
  List<VaultItem> _folders = [];
  List<VaultItem> _files = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Dio _dio = Dio();

  //btn
  bool _myVaultBtn = true;
  late ScrollController _scrollController;
  bool _isVisible = true;
  bool _openBtnSection = false;
  bool _createFolder = false;

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

      // Scegli l'URL in base alla selezione del tab
      String apiUrl =
          _myVaultBtn
              ? 'http://10.0.2.2:3000/item/all?limit=50&offset=0'
              : 'http://10.0.2.2:3000/shared/all?limit=5&offset=0';

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
        _isLoading = false;
      });

      debugPrint('Items ottenuti: $responseData');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore durante il caricamento: $e';
      });
      debugPrint('Errore durante il fetch degli items: $e');
    }
  }

  Future<void> _addFolder(String name, String color, String? parentId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      // Prepara i dati della richiesta
      final Map<String, dynamic> requestData = {'name': name, 'color': color};

      // Aggiungi parentId solo se non è null e non è vuoto
      if (parentId != null && parentId.isNotEmpty) {
        requestData['parentId'] = parentId;
      }

      debugPrint('Dati richiesta: $requestData');

      final response = await _dio.post(
        'http://10.0.2.2:3000/item',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('Risposta server: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchItems();
        debugPrint('Cartella creata con successo');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cartella "$name" creata con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('Errore nella creazione: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Errore durante creazione folder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella creazione della cartella'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        _isLoading = true; // Mostra loading durante la transizione
      });
      // Ricarica i dati quando cambia la selezione
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
              ],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 550),
              curve: Curves.easeInOut,
              bottom: _isVisible ? 140 : -100,
              right: 30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: RiveAppTheme.background2.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: AnimatedRotation(
                    turns: _openBtnSection ? 0.125 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.add,
                      color: RiveAppTheme.backgroundDark,
                      size: 40,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _openBtnSection = !_openBtnSection;
                    });
                  },
                ),
              ),
            ),
            // Overlay con i 3 bottoni
            if (_openBtnSection) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _openBtnSection = false;
                    });
                  },
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                bottom: _isVisible ? 230 : 90,
                right: 30,
                child: Column(
                  children: [
                    _buildActionButton(
                      icon: Icons.folder,
                      label: 'Cartella',
                      onTap: () {
                        // Azione per creare cartella
                        setState(() {
                          _openBtnSection = false;
                        });
                        setState(() {
                          _createFolder = true;
                        });
                        debugPrint('Crea cartella');
                      },
                    ),
                    SizedBox(height: 15),
                    _buildActionButton(
                      icon: Icons.upload_file,
                      label: 'Upload',
                      onTap: () {
                        // Azione per upload file
                        setState(() {
                          _openBtnSection = false;
                        });
                        debugPrint('Upload file');
                      },
                    ),
                    SizedBox(height: 15),
                    _buildActionButton(
                      icon: Icons.camera_alt,
                      label: 'Foto',
                      onTap: () {
                        // Azione per scattare foto
                        setState(() {
                          _openBtnSection = false;
                        });
                        debugPrint('Scatta foto');
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_createFolder) ...[
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CreateFolderModal(
                      onCreateFolder: (name, color) {
                        debugPrint('Creazione cartella: $name, Colore: $color');
                        setState(() {
                          _createFolder = false;
                        });
                        _addFolder(
                          name,
                          color.value
                              .toRadixString(16)
                              .padLeft(8, '0')
                              .substring(2),
                          null,
                        );
                      },
                      onCancel: () {
                        setState(() {
                          _createFolder = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      key: ValueKey(_myVaultBtn), // Chiave per AnimatedSwitcher
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
              : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 15),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Text(
                          "Cartelle",
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: FolderCard(section: _folders[index]),
                      ),
                      childCount: _folders.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        "File",
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: FileCard(section: _files[index]),
                      ),
                      childCount: _files.length,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: RiveAppTheme.backgroundDark, size: 24)],
        ),
      ),
    );
  }
}
