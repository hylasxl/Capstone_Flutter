import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/types.dart';

class FriendListScreen extends StatefulWidget {
  final int userID;
  const FriendListScreen({super.key, required this.userID});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<FriendInfo> friendList = [];

  @override
  void initState() {
    _fetchFriendList();
    super.initState();
  }

  Future<void> _fetchFriendList() async {
    final GetDislayListFriend request =
        GetDislayListFriend(accountID: widget.userID.toString());
    try {
      final response = await FriendService().getListFriend(request);
      setState(() {
        friendList = response.infos?.toList() ?? [];
      });
    } catch (e) {
      throw Exception('Failed to fetch friend list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.yfr),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: friendList.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(friendList[index].displayName),
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'profileScreen',
                            arguments: {
                              'userID': friendList[index].accountID.toString(),
                              'isSelf': false
                            });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            NetworkImage(friendList[index].avatarURL),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
