import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/models/vault_item.dart';
import 'package:vault_app/services/auth_service.dart';

class ShareFileModal extends StatefulWidget {
  const ShareFileModal({Key? key}) : super(key: key);

  @override
  _ShareFileModalState createState() => _ShareFileModalState();
}

class _ShareFileModalState extends State<ShareFileModal> {
  VaultItem? selectedItem;
  String email = '';

  List<VaultItem> _folders = [];
  List<VaultItem> _files = [];
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      final response = await _dio.get(
        'http://10.0.2.2:3000/item/all?limit=50&offset=0',
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
      });

      debugPrint('Items ottenuti: $responseData');
    } catch (e) {
      setState(() {
        debugPrint('Errore durante il caricamento: $e');
      });
      debugPrint('Errore durante il fetch degli items: $e');
    }
  }

  void onShareBtn(int id, String email) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      final response = await _dio.post(
        'http://10.0.2.2:3000/shared',
        data: {'item_id': id.toString(), 'shared_with': email},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {}
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Condividi File/Cartella',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<VaultItem>(
                decoration: const InputDecoration(
                  labelText: 'Seleziona Elemento',
                  border: OutlineInputBorder(),
                ),
                value: selectedItem,
                items: _buildDropdownItems(),
                onChanged: (VaultItem? value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Inserisci Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            onShareBtn(selectedItem!.itemId!, email);
            Navigator.of(context).pop();
          },
          child: const Text('Condividi'),
        ),
      ],
    );
  }

  List<DropdownMenuItem<VaultItem>> _buildDropdownItems() {
    List<DropdownMenuItem<VaultItem>> items = [];

    items.add(
      const DropdownMenuItem<VaultItem>(
        enabled: false,
        child: Text('Cartelle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
    items.addAll(
      _folders.map(
        (folder) => DropdownMenuItem<VaultItem>(
          value: folder,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(folder.title),
          ),
        ),
      ),
    );

    items.add(
      const DropdownMenuItem<VaultItem>(
        enabled: false,
        child: Text('File', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
    items.addAll(
      _files.map(
        (file) => DropdownMenuItem<VaultItem>(
          value: file,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(file.title),
          ),
        ),
      ),
    );

    return items;
  }
}
