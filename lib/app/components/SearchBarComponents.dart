import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/theme.dart';

class SearchBarComponents extends StatefulWidget {
  const SearchBarComponents({super.key});

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final searchBarWidth = screenWidth * 0.7; // 70% della larghezza dello schermo
    final searchBarHeight = screenWidth * 0.09; // 9% della larghezza (per mantenere proporzioni)
    
    return SearchBar(
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
          },
        ),
      ],
      hintText: 'Search...',
      onChanged: (value) {
        // Handle search input changes
      },
      elevation: const MaterialStatePropertyAll<double>(3),
      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
      shape: MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      constraints: BoxConstraints(
        maxHeight: searchBarHeight,
        maxWidth: searchBarWidth,
        minHeight: 36, // Altezza minima per dispositivi molto piccoli
        minWidth: 200, // Larghezza minima
      ),
    );
  }
}
