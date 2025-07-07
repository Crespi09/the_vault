import 'package:flutter/material.dart';

class RecentFile {
  // Singleton pattern
  static final RecentFile _instance = RecentFile._internal();
  factory RecentFile() => _instance;
  RecentFile._internal();

  List<int> recentFiles = [];
  static const int maxRecentFiles = 5;

  void addFileToList(int fileId) {
    // vado a vedere se il fileId è già contenuto
    // se si lo rimuovo e poi lo aggiungo

    if (recentFiles.contains(fileId)) {
      recentFiles.remove(fileId);
    }

    recentFiles.insert(0, fileId);

    if (recentFiles.length > maxRecentFiles) {
      int lastFile = recentFiles[recentFiles.length - 1];
      recentFiles.remove(lastFile);
    }

    debugPrint('RECENT FILES:');
    for (var fileId in recentFiles) {
      debugPrint(fileId.toString());
    }
  }

  List<int> getFiles() {
    return List.from(recentFiles);
  }

  void removeFileFromList(int fileId) {
    if (recentFiles.contains(fileId)) {
      recentFiles.remove(fileId);
      debugPrint('FILE REMOVED: $fileId');
      debugPrint('RECENT FILES:');
      for (var id in recentFiles) {
        debugPrint(id.toString());
      }
    } else {
      debugPrint('FILE NOT FOUND: $fileId');
    }
  }
}
