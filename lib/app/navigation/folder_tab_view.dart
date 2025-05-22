import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/components/fileCard.dart';
import 'package:vault_app/app/components/folderCard.dart';
import 'package:vault_app/app/components/recentCard.dart';
import 'package:vault_app/app/models/courses.dart';
import 'package:vault_app/app/models/vault_item.dart';

class FolderTabView extends StatefulWidget {
  const FolderTabView({super.key});

  @override
  State<FolderTabView> createState() => _FolderTabViewState();
}

class _FolderTabViewState extends State<FolderTabView> {
  final List<VaultItem> _folders = VaultItem.folders;
  final List<VaultItem> _files = VaultItem.files;

  bool _myVaultBtn = true;

  void onBtnPressed(bool selection) {
    setState(() {
      _myVaultBtn = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),

        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    pressedOpacity: 1,
                    onPressed: () => onBtnPressed(true),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _myVaultBtn
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Opacity(opacity: 0.6),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'My Vault',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    child: VerticalDivider(
                      thickness: 2,
                      width: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    pressedOpacity: 1,
                    onPressed: () => onBtnPressed(false),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            !_myVaultBtn
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Opacity(opacity: 0.6),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'Shared',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 15),
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Text(
                            "Cartelle",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          key: _folders[index].id,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: FolderCard(section: _folders[index]),
                        ),
                        childCount: _folders.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          "File",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          key: _files[index].id,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: FileCard(section: _files[index]),
                        ),
                        childCount: _files.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
