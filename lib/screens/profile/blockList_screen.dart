import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  List<SingleAccountInfo> blockAccounts = [];

  @override
  void initState() {
    _getBlockList();
    super.initState();
  }

  Future<void> _getBlockList() async {
    setState(() {
      blockAccounts.clear();
    });
    final int? userID = await Helpers().getUserId();
    if (userID == null) return;
    final request = GetBlockListInfoRequest(accountId: userID);
    try {
      final response = await FriendService().getBlockListInfo(request);
      if (response.success) {
        setState(() {
          blockAccounts.addAll(response.accounts);
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> toggleBlock(
      int targetAccountID, int index, String displayName) async {
    final int? userID = await Helpers().getUserId();
    if (userID == null) return;
    final request = BlockRequest(
        fromAccountID: userID.toString(),
        toAccountID: targetAccountID.toString(),
        action: "unblock");
    try {
      await FriendService().resolveFriendBlock(request);
      setState(() {
        blockAccounts.removeAt(index);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Unblock $displayName successfully'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text("Block List"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getBlockList,
          )
        ],
      ),
      body: blockAccounts.isEmpty
          ? Center(child: Text("No blocked accounts"))
          : RefreshIndicator(
              onRefresh: _getBlockList,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
                itemCount: blockAccounts.length,
                itemBuilder: (context, index) {
                  final account = blockAccounts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(account.avatarURL),
                    ),
                    title: Text(account.displayName),
                    trailing: ElevatedButton(
                      onPressed: () => toggleBlock(
                          account.accountID, index, account.displayName),
                      child: Text("Unblock"),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
