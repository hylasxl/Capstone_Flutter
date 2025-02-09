import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncio_capstone/services/message_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/websocket_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/widgets/messages/chat_list_item.dart';

class MessageScreen extends StatefulWidget {
  final ScrollController scrollController;
  const MessageScreen({super.key, required this.scrollController});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int currentPage = 1;
  final int pageSize = 10;
  List<ChatList> chatList = [];
  bool isFetching = false;
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    _onInitData();
    _webSocketService.connect();
    _webSocketService.messageStream.listen(
      (message) {
        debugPrint("New WebSocket message: ${message.content}");
        setState(() {
          _onPageRefresh();
        });
      },
      onError: (error) {
        debugPrint("WebSocket Stream Error: $error");
      },
      onDone: () {
        debugPrint("WebSocket Stream Closed");
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onInitData() async {
    setState(() {
      currentPage = 1;
      chatList.clear();
    });

    await _onGetChatList();
  }

  Future<void> _onGetChatList() async {
    if (isFetching) return;
    setState(() => isFetching = true);

    final currentAccountID = await Helpers().getUserId();
    if (currentAccountID == null) {
      setState(() => isFetching = false);
      return;
    }

    final request = GetChatListRequest(
      accountID: currentAccountID,
      page: currentPage,
      pageSize: pageSize,
    );

    try {
      final response = await MessageService().getChatList(request);
      if (response != null && response.isNotEmpty) {
        setState(() {
          chatList.addAll(response);
          currentPage++;
        });
      }
    } catch (e) {
      print("Error fetching chat list: $e");
    } finally {
      setState(() => isFetching = false);
    }
  }

  Future<void> _onPageRefresh() async {
    await _onInitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          AppLocalizations.of(context)!.messages,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "SFProDisplay",
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onPageRefresh,
        child: ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: chatList.length + 1,
          itemBuilder: (context, index) {
            if (index == chatList.length) {
              return _buildLoadingIndicator();
            }
            return ChatListItem(
              accountID: chatList[index].accountID,
              targetAccountID: chatList[index].targetAccountID,
              displayName: chatList[index].displayName,
              avatarURL: chatList[index].avatarURL,
              lastMessageTimestamp: chatList[index].lastMessageTimestamp,
              lastMessageContent: chatList[index].lastMessageContent,
              unreadMessageQuantity: chatList[index].unreadMessageQuantity,
              chatId: chatList[index].chatId,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox.shrink();
  }
}
