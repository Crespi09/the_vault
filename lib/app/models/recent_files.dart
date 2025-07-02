import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

class RecentFile {
  List<int> recentFiles = [];

  void addFileToList(int fileId){
    recentFiles.add(fileId);

    if(recentFiles.length > 5){
      int lastFile = recentFiles[recentFiles.length];
      recentFiles.remove(lastFile);
    }

  }


}
