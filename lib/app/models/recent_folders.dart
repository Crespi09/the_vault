import 'package:flutter/material.dart';

class RecentFolders {
  static final RecentFolders _instance = RecentFolders._internal();
  factory RecentFolders() => _instance;
  RecentFolders._internal();

  List<int> recentFolders = [];
  static const int maxRecentFolders = 3;

  void addFolderToList(int itemId) {
    if (recentFolders.contains(itemId)) {
      recentFolders.remove(itemId);
    }

    recentFolders.insert(0, itemId);

    if (recentFolders.length > maxRecentFolders) {
      int lastFolder = recentFolders[recentFolders.length - 1];
      recentFolders.remove(lastFolder);
    }

    debugPrint('RECENT FOLDERS:');
    for (var itemId in recentFolders) {
      debugPrint(itemId.toString());
    }
  }

  List<int> getFolders() {
    return List.from(recentFolders);
  }

  void removeFolderFromList(int itemId) {
    if (recentFolders.contains(itemId)) {
      recentFolders.remove(itemId);
      debugPrint('FOLDER REMOVED: $itemId');
      debugPrint('RECENT FOLDERS:');
      for (var id in recentFolders) {
        debugPrint(id.toString());
      }
    } else {
      debugPrint('FOLDER NOT FOUND: $itemId');
    }
  }
}
