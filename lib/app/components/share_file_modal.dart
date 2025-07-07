import 'package:flutter/material.dart';
import 'package:vault_app/app/models/vault_item.dart';

class ShareFileModal extends StatefulWidget {
  const ShareFileModal({Key? key}) : super(key: key);

  @override
  _ShareFileModalState createState() => _ShareFileModalState();
}

class _ShareFileModalState extends State<ShareFileModal> {
  VaultItem? selectedItem;
  String email = '';

  final List<VaultItem> folders = [
    VaultItem(itemId: 1, title: 'Folder 1'),
    VaultItem(itemId: 2, title: 'Folder 2'),
  ];

  final List<VaultItem> files = [
    VaultItem(fileId: 10, itemId: 10, title: 'File 1'),
    VaultItem(fileId: 11, itemId: 11, title: 'File 2'),
  ];

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
            // Azione per condividere: utilizza selectedItem e email
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
      folders.map(
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
      files.map(
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
