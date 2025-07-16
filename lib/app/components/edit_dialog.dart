import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class EditDialog extends StatefulWidget {
  final String currentName;
  final bool isFolder;
  final Function(String newName) onEdit;

  const EditDialog({
    Key? key,
    required this.currentName,
    required this.onEdit,
    this.isFolder = false,
  }) : super(key: key);

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    String newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() {
        _errorMessage = 'Il nome non può essere vuoto.';
      });
      return;
    }
    widget.onEdit(newName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.isFolder ? 'Modifica Cartella' : 'Modifica File';
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Nuovo nome',
          errorText: _errorMessage,
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Salva')),
      ],
    );
  }
}

class Folder {
  final String id;
  final String name;

  Folder({required this.id, required this.name});
}

class MoveToDialog extends StatefulWidget {
  final List<Folder> folders;
  final Function(Folder selectedFolder) onMove;

  const MoveToDialog({Key? key, required this.folders, required this.onMove})
    : super(key: key);

  @override
  _MoveToDialogState createState() => _MoveToDialogState();
}

class _MoveToDialogState extends State<MoveToDialog> {
  Folder? _selectedFolder;

  @override
  void initState() {
    super.initState();
    if (widget.folders.isNotEmpty) {
      _selectedFolder = widget.folders.first;
    }
  }

  void _submit() {
    if (_selectedFolder != null) {
      widget.onMove(_selectedFolder!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blueGrey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Sposta in'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.folders.length,
          itemBuilder: (context, index) {
            final folder = widget.folders[index];
            return RadioListTile<Folder>(
              title: Text(folder.name),
              value: folder,
              groupValue: _selectedFolder,
              onChanged: (Folder? value) {
                setState(() {
                  _selectedFolder = value;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Sposta')),
      ],
    );
  }
}
