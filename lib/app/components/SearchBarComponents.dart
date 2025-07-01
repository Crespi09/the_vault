import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class SearchBarComponents extends StatefulWidget {
  final Function(String)? onSearch; // Callback per la ricerca
  final VoidCallback? onSearchPressed; // Callback per il tap sulla search bar

  const SearchBarComponents({super.key, this.onSearch, this.onSearchPressed});

  @override
  State<SearchBarComponents> createState() => _SearchbarState();
}

class _SearchbarState extends State<SearchBarComponents> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchText = _controller.text.trim();
    if (searchText.isNotEmpty) {
      widget.onSearch?.call(searchText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final searchBarWidth =
        screenWidth * 0.7; // 70% della larghezza dello schermo
    final searchBarHeight =
        screenWidth * 0.09; // 9% della larghezza (per mantenere proporzioni)

    return GestureDetector(
      onTap: widget.onSearchPressed,
      child: SearchBar(
        controller: _controller,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        leading: const Icon(Icons.search),
        trailing: [
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              _controller.clear();
              widget.onSearch?.call(''); // Reset della ricerca
            },
          ),
        ],
        hintText: 'Search...',
        onChanged: (value) {
          // Ricerca in tempo reale (opzionale)
          if (value.isEmpty) {
            widget.onSearch?.call('');
          }
        },
        onSubmitted: (value) {
          _performSearch();
        },
        elevation: const MaterialStatePropertyAll<double>(3),
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        shape: MaterialStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        constraints: BoxConstraints(
          maxHeight: searchBarHeight,
          maxWidth: searchBarWidth,
          minHeight: 36,
          minWidth: 200,
        ),
      ),
    );
  }
}
