import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:syncio_capstone/services/types.dart';

class FriendActionBottomSheet extends StatelessWidget {
  final bool isFollow;
  final int currentAccountID;
  final int profileAccountID;
  const FriendActionBottomSheet(
      {super.key,
      required this.isFollow,
      required this.currentAccountID,
      required this.profileAccountID});

  Future<void> _onFollowAction(String action, BuildContext context) async {
    final ResolveFriendFollowRequest request = ResolveFriendFollowRequest(
        fromAccountID: currentAccountID.toString(),
        toAccountID: profileAccountID.toString(),
        action: action);
    try {
      await FriendService().resolveFriendFollow(request);
      return;
    } catch (e) {
      throw Exception(e);
    } finally {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _onUnfriendAction(BuildContext context) async {
    final UnfriendRequest request = UnfriendRequest(
        fromAccountID: currentAccountID.toString(),
        toAccountID: profileAccountID.toString());
    try {
      await FriendService().unFriend(request);
      return;
    } catch (e) {
      throw Exception(e);
    } finally {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _onBlockAction(BuildContext context) async {
    final BlockRequest request = BlockRequest(
        fromAccountID: currentAccountID.toString(),
        toAccountID: profileAccountID.toString(),
        action: "block");

    try {
      await FriendService().resolveFriendBlock(request);
      return;
    } catch (e) {
      throw Exception(e);
    } finally {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Widget _actionItem(
      IconData icondata, String text, Future<void> Function() actionFn) {
    return GestureDetector(
      onTap: () async {
        await actionFn();
      },
      child: Row(
        children: [
          Icon(icondata),
          SizedBox(
            width: 15,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          _actionItem(Icons.person_remove_alt_1, "Unfriend",
              () => _onUnfriendAction(context)),
          SizedBox(
            height: 30,
          ),
          _actionItem(
              isFollow ? Icons.remove_circle : Icons.follow_the_signs,
              isFollow ? "Unfollow" : "Follow",
              () => _onFollowAction(isFollow ? "unfollow" : "follow", context)),
          SizedBox(
            height: 24,
          ),
          _actionItem(Icons.block, "Block", () => _onBlockAction(context)),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
