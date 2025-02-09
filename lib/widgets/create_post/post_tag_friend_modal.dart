import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class TagFriendListBottomSheetContent extends StatefulWidget {
  final List<Map<int, String>> initTagFriends;
  final VoidCallback onCancel;

  const TagFriendListBottomSheetContent({
    super.key,
    required this.initTagFriends,
    required this.onCancel,
  });

  @override
  State<TagFriendListBottomSheetContent> createState() =>
      _TagFriendListBottomSheetContentState();
}

class _TagFriendListBottomSheetContentState
    extends State<TagFriendListBottomSheetContent>
    with TickerProviderStateMixin {
  List<Map<int, String>> selectedFriends = [];
  List<FriendInfo> friends = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late AnimationController _sizeAnimationController;

  @override
  void initState() {
    super.initState();
    selectedFriends = List.from(widget.initTagFriends);
    getListFriends();
    _sizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sizeAnimationController.dispose();
    super.dispose();
  }

  Future<void> getListFriends() async {
    final LoginResponse? userData = await Helpers().getUserData();
    if (userData == null) {
      return;
    }
    String userID = userData.userID;
    final GetDislayListFriend request = GetDislayListFriend(accountID: userID);

    try {
      final DisplayListFriendResponse response =
          await FriendService().getListFriend(request);
      if (!response.success) {
        setState(() {
          friends = [];
        });
        return;
      }
      setState(() {
        friends = response.infos!;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void toggleSelection(FriendInfo friend) {
    setState(() {
      int existingIndex = selectedFriends
          .indexWhere((element) => element.keys.first == friend.accountID);

      if (existingIndex != -1) {
        Map<int, String> removedFriend = selectedFriends[existingIndex];
        selectedFriends.removeAt(existingIndex);
        _listKey.currentState?.removeItem(existingIndex,
            (context, animation) => _buildItem(removedFriend, animation));
      } else {
        selectedFriends.add({friend.accountID: friend.displayName});
        _listKey.currentState?.insertItem(selectedFriends.length - 1);
      }
    });
    if (selectedFriends.isEmpty) {
      _sizeAnimationController.reverse();
    } else {
      _sizeAnimationController.forward();
    }
  }

  bool isSelected(FriendInfo friend) {
    return selectedFriends
        .any((element) => element.containsKey(friend.accountID));
  }

  Widget _buildItem(Map<int, String> friendMap, Animation<double> animation) {
    final friendID = friendMap.keys.first;
    FriendInfo? friendInfo;
    try {
      friendInfo = friends.firstWhere((f) => f.accountID == friendID);
    } catch (e) {
      return SizedBox.shrink();
    }

    int index = friends.indexWhere((e) => e.accountID == friendID);

    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(friendInfo.avatarURL),
                  radius: 25,
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      toggleSelection(friends[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 60,
              child: Text(
                friendInfo.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.tagFriends,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          selectedFriends.isNotEmpty
              ? Text(
                  AppLocalizations.of(context)!.selected,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              : SizedBox.shrink(),
          const SizedBox(
            height: 10,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selectedFriends.isNotEmpty
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 90),
                    child: AnimatedList(
                      key: _listKey,
                      scrollDirection: Axis.horizontal,
                      initialItemCount: selectedFriends.length,
                      itemBuilder: (context, index, animation) {
                        return _buildItem(
                            selectedFriends.reversed.toList()[index],
                            animation);
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Text(
            AppLocalizations.of(context)!.yourFriends,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: friends.isNotEmpty
                ? ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(friend.avatarURL),
                        ),
                        title: Text(
                          friend.displayName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Checkbox(
                          value: isSelected(friend),
                          onChanged: (isChecked) {
                            toggleSelection(friend);
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedFriends);
                },
                child: Text(AppLocalizations.of(context)!.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
