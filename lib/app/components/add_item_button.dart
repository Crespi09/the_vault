import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/create_folder_modal.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class AddItemButton extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onRefresh;
  final String? parentId;

  const AddItemButton({
    super.key,
    required this.isVisible,
    required this.onRefresh,
    this.parentId,
  });

  @override
  State<AddItemButton> createState() => _AddItemButtonState();
}

class _AddItemButtonState extends State<AddItemButton> {
  bool _openBtnSection = false;
  bool _createFolder = false;
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  Future<void> _addFolder(String name, String color, String? parentId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      final Map<String, dynamic> requestData = {'name': name, 'color': color};

      if (parentId != null && parentId.isNotEmpty) {
        requestData['parentId'] = parentId;
      } else {
        requestData['parentId'] = '';
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
        widget.onRefresh();
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

  Future<void> _uploadFromGallery({String? parentId}) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultipleMedia();

      if (pickedFiles.isEmpty) return;

      final XFile pickedFile = pickedFiles.first;
      final mimeType = lookupMimeType(pickedFile.path) ?? '';

      if (mimeType.startsWith('image/') || mimeType.startsWith('video/')) {
        debugPrint(
          'File selezionato: ${mimeType.startsWith('image/') ? 'Immagine' : 'Video'}',
        );
        await _performUpload(pickedFile, parentId);
      } else {
        debugPrint('Tipo di file non supportato: $mimeType');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tipo di file non supportato'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('Errore durante l\'upload dalla galleria: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento del file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFromCamera({String? parentId}) async {
    try {
      final String? mediaType = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Seleziona tipo di ripresa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Foto'),
                  onTap: () => Navigator.of(context).pop('image'),
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Video'),
                  onTap: () => Navigator.of(context).pop('video'),
                ),
              ],
            ),
          );
        },
      );

      if (mediaType == null) return;

      XFile? pickedFile;
      if (mediaType == 'image') {
        pickedFile = await _picker.pickImage(source: ImageSource.camera);
      } else {
        pickedFile = await _picker.pickVideo(source: ImageSource.camera);
      }

      if (pickedFile == null) return;

      await _performUpload(pickedFile, parentId);
    } catch (e) {
      debugPrint('Errore durante la ripresa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella ripresa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performUpload(XFile pickedFile, String? parentId) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 16),
                Text('Caricamento file in corso...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      final formData = FormData();
      final file = File(pickedFile.path);
      final mimeType =
          lookupMimeType(pickedFile.path) ?? 'application/octet-stream';

      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: pickedFile.name,
            contentType: DioMediaType.parse(mimeType),
          ),
        ),
      );

      if (parentId != null && parentId.isNotEmpty) {
        formData.fields.add(MapEntry('parentId', parentId));
      }

      final response = await _dio.post(
        'http://10.0.2.2:3000/file',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('File caricato con successo: ${response.data}');
        widget.onRefresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File "${pickedFile.name}" caricato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Errore nel caricamento: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      rethrow;
    }
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // bottone principale
        AnimatedPositioned(
          duration: Duration(milliseconds: 550),
          curve: Curves.easeInOut,
          bottom: widget.isVisible ? 140 : -100,
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

        // altri 3 bottoni
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
            bottom: widget.isVisible ? 230 : 90,
            right: 30,
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.folder,
                  label: 'Cartella',
                  onTap: () {
                    setState(() {
                      _openBtnSection = false;
                      _createFolder = true;
                    });
                  },
                ),
                SizedBox(height: 15),
                _buildActionButton(
                  icon: Icons.perm_media,
                  label: 'Media',
                  onTap: () {
                    setState(() {
                      _openBtnSection = false;
                    });
                    _uploadFromGallery(parentId: widget.parentId);
                  },
                ),
                SizedBox(height: 15),
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    setState(() {
                      _openBtnSection = false;
                    });
                    _uploadFromCamera(parentId: widget.parentId);
                  },
                ),
              ],
            ),
          ),
        ],

        // modal per folder
        if (_createFolder)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CreateFolderModal(
                  onCreateFolder: (name, color) {
                    setState(() {
                      _createFolder = false;
                    });
                    _addFolder(
                      name,
                      color.value
                          .toRadixString(16)
                          .padLeft(8, '0')
                          .substring(2),
                      widget.parentId,
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
    );
  }
}
