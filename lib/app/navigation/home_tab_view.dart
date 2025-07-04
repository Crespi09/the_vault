import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/components/recentCard.dart';
import 'package:vault_app/app/components/vcard.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/models/recent_files.dart';
import 'package:vault_app/app/theme.dart';
import 'package:vault_app/services/auth_service.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<CourseModel> _courses = CourseModel.courses;
  final List<CourseModel> _recents = CourseModel.recents;

  // Aggiungi questa variabile per memorizzare i file recenti dalla API
  List<dynamic> _recentFilesFromApi = [];

  final Dio _dio = Dio();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchRecentFiles();
  }

  Future<void> _fetchRecentFiles() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated) {
        debugPrint('Utente non autenticato');
        return;
      }

      List<int> recentFileIds = RecentFile().getFiles();

      if (recentFileIds.isEmpty) {
        debugPrint('Nessun file recente');
        setState(() {
          _recentFilesFromApi = [];
        });
        return;
      }

      // Converti la lista di ID in una stringa separata da virgole
      String idsString = recentFileIds.join(',');

      final response = await _dio.get(
        'http://10.0.2.2:3000/file',
        queryParameters: {
          'ids': idsString, // "1,2,3,4,5"
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authService.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('Recent files IDs: $idsString');
      debugPrint('Response data: ${response.data}');

      // Aggiorna lo stato con i dati della risposta
      setState(() {
        _recentFilesFromApi = response.data ?? [];
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _recentFilesFromApi = [];
      });
    }
  }

  String _formatDate(String dateString) {
    // Implementa la formattazione della data qui
    return dateString;
  }

  String _getFileTypeImage(String fileType) {
    // Implementa la logica per ottenere l'immagine in base al tipo di file
    return 'assets/images/file_icon.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            decoration: BoxDecoration(
              color: RiveAppTheme.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const Text(
                      "Folders",
                      style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _courses
                              .map(
                                (course) => Padding(
                                  key: course.id,
                                  padding: const EdgeInsets.all(10),
                                  child: VCard(course: course),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Text(
                      "Recent Files",
                      style: TextStyle(fontSize: 22, fontFamily: 'Poppins'),
                    ),
                  ),
                  // Usa i dati dalla API invece di _recents
                  ...List.generate(_recentFilesFromApi.length, (index) {
                    final file = _recentFilesFromApi[index];
                    return Padding(
                      key: ValueKey(file['id']),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: RecenteCard(
                        section: CourseModel(
                          // id: ValueKey(file['id']),
                          title: file['fileName'].length > 15 ? '${file['fileName'].substring(0, 15)} ...' : file['fileName'],
                          caption:
                              'Modificato ${DateTime.parse(file!['updatedAt']).day}/${DateTime.parse(file!['updatedAt']).month}/${DateTime.parse(file!['updatedAt']).year}',
                          subtitle: file['fileType'] ?? '',
                          color: file['color'] ?? Colors.blue,
                          image: _getFileTypeImage(file['fileType']),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



      // return Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
      //       SizedBox(height: 16),
      //       Text(
      //         _searchQuery.isNotEmpty
      //             ? 'Nessun risultato trovato per "$_searchQuery"'
      //             : 'Nessun elemento disponibile',
      //         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      //         textAlign: TextAlign.center,
      //       ),
      //     ],
      //   ),
      // );