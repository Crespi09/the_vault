import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class CreateFolderModal extends StatefulWidget {
  final Function(String name, Color color) onCreateFolder;
  final VoidCallback onCancel;

  const CreateFolderModal({
    Key? key,
    required this.onCreateFolder,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CreateFolderModal> createState() => _CreateFolderModalState();
}

class _CreateFolderModalState extends State<CreateFolderModal> {
  final TextEditingController _folderNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  final List<Color> _colorPalette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          _buildNameInput(),
          SizedBox(height: 24),
          _buildColorSelector(),
          SizedBox(height: 32),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Nuova Cartella',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: RiveAppTheme.backgroundDark,
          ),
        ),
        IconButton(
          onPressed: widget.onCancel,
          icon: Icon(Icons.close, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome cartella',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RiveAppTheme.backgroundDark,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _folderNameController,
          decoration: InputDecoration(
            hintText: 'Inserisci il nome della cartella',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colore cartella',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RiveAppTheme.backgroundDark,
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _colorPalette.map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:
            isSelected
                ? Icon(Icons.check, color: Colors.white, size: 24)
                : null,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Annulla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _createFolder,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Crea',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createFolder() {
    if (_folderNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci un nome per la cartella'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onCreateFolder(_folderNameController.text.trim(), _selectedColor);
  }
}
