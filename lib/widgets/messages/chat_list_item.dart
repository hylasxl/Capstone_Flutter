import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatefulWidget {
  final int accountID;
  final int targetAccountID;
  final String displayName;
  final String avatarURL;
  final int lastMessageTimestamp;
  final String lastMessageContent;
  final int unreadMessageQuantity;
  final String chatId;

  const ChatListItem({
    super.key,
    required this.accountID,
    required this.targetAccountID,
    required this.displayName,
    required this.avatarURL,
    required this.lastMessageTimestamp,
    required this.lastMessageContent,
    required this.unreadMessageQuantity,
    required this.chatId,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  String _formatTimestamp(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('hh:mm a').format(date);
  }

  Future<void> _onNavigateDetailScreen(String chatId, int partnerId) async {
    await Navigator.pushNamed(context, 'messageDetailScreen', arguments: {
      'chatId': chatId,
      'partnerId': partnerId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: CachedNetworkImageProvider(widget.avatarURL),
        radius: 25,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimestamp(widget.lastMessageTimestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              widget.lastMessageContent
                  .substring(0, min(50, widget.lastMessageContent.length)),
              style: TextStyle(
                fontSize: 14,
                color: widget.unreadMessageQuantity > 0
                    ? Colors.black
                    : Colors.grey.shade600,
                fontWeight: widget.unreadMessageQuantity > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.unreadMessageQuantity > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.unreadMessageQuantity > 99
                    ? "99+"
                    : widget.unreadMessageQuantity.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        _onNavigateDetailScreen(
          widget.chatId,
          widget.targetAccountID,
        );
      },
    );
  }
}
