import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncio_capstone/services/message_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/websocket_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MessageDetailScreen extends StatefulWidget {
  final String chatId;
  final int partnerId;
  const MessageDetailScreen(
      {super.key, required this.chatId, required this.partnerId});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  GetMessageHistoryResponse? response;
  final List<MessageData> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final WebSocketService _webSocketService = WebSocketService();

  int currentPage = 1;
  final int pageSize = 30;
  bool _isFetching = false;
  bool _isHavingMore = true;

  @override
  void initState() {
    _getMessages();
    _webSocketService.connect();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.maxScrollExtent + 50) {
        _getMessages();
      }
    });
    _webSocketService.messageStream.listen(
      (message) async {
        final int? currentAccountID = await Helpers().getUserId();
        if (currentAccountID == null) return;
        setState(() {
          if (message.senderID != widget.partnerId) return;

          _messages.insert(
              0,
              MessageData(
                senderID: widget.partnerId,
                receiverID: currentAccountID,
                content: message.content,
                timestamp: message.timestamp,
                isDeleted: false,
                isRecalled: false,
                isRead: false,
                createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
              ));
          _listKey.currentState?.insertItem(0);
        });
      },
      onError: (error) {
        debugPrint("WebSocket Stream Error: $error");
      },
      onDone: () {
        debugPrint("WebSocket Stream Closed");
      },
    );
    _markMessageAsRead();
    super.initState();
  }

  Future<void> _markMessageAsRead() async {
    final int? currentAccountID = await Helpers().getUserId();
    if (currentAccountID == null) return;
    final ReceiverMarkMessageAsRead request = ReceiverMarkMessageAsRead(
      chatID: widget.chatId,
      accountID: currentAccountID,
    );

    try {
      final ReceiverMarkMessageAsReadResponse response =
          await MessageService().receiverMarkMessageAsRead(request);
      if (response.success!) {
        debugPrint("Marked message as read");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _getMessages() async {
    if (_isFetching || !_isHavingMore) return;

    final int? currentAccountID = await Helpers().getUserId();
    if (currentAccountID == null) return;
    final GetMessageHistoryRequest request = GetMessageHistoryRequest(
      chatId: widget.chatId,
      page: currentPage,
      pageSize: pageSize,
      requestAccountID: currentAccountID,
    );

    setState(() => _isFetching = true);
    try {
      final GetMessageHistoryResponse response =
          await MessageService().getMessageHistory(request);
      if (response.messages == null || response.messages!.isEmpty) {
        setState(() => _isHavingMore = false);
        return;
      }

      for (var msg in response.messages!) {
        _messages.add(msg);
        _listKey.currentState?.insertItem(_messages.length - 1);
      }
      setState(() {
        currentPage++;
      });
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() => _isFetching = false);
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final int? currentAccountID = await Helpers().getUserId();
    if (currentAccountID == null) return;

    final ChatMessage chatMessage = ChatMessage(
      receiverID: widget.partnerId,
      senderID: currentAccountID,
      content: message,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    _webSocketService.sendMessage(chatMessage);
    _messageController.clear();

    setState(() {
      _messages.insert(
          0,
          MessageData(
            senderID: currentAccountID,
            receiverID: widget.partnerId,
            content: message,
            timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
            isDeleted: false,
            isRecalled: false,
            isRead: false,
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          ));
      _listKey.currentState?.insertItem(0);
    });
  }

  Widget _buildMessageItem(
      BuildContext context, int index, Animation<double> animation) {
    final message = _messages[index];
    final isSender = message.senderID != widget.partnerId;
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => _showContextMenu(context, message, index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: isSender ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _renderMessageText(message),
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _renderMessageText(MessageData msg) {
    if (msg.isDeleted!) return "This message has been deleted";
    if (msg.isRecalled!) return "This message has been recalled";
    return msg.content;
  }

  void _showContextMenu(BuildContext context, MessageData msg, int index) {
    if (msg.isDeleted! || msg.isRecalled!) return;
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: msg.content));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Message copied"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                if (msg.senderID != widget.partnerId &&
                    !msg.isDeleted! &&
                    !msg.isRecalled!)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () {
                      _onSendingActionMessage(msg, "delete");
                      setState(() {
                        _messages[index].isDeleted = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                if (msg.senderID != widget.partnerId &&
                    !msg.isDeleted! &&
                    !msg.isRecalled!)
                  ListTile(
                    leading: const Icon(Icons.reset_tv_outlined),
                    title: const Text('Recall'),
                    onTap: () {
                      _onSendingActionMessage(msg, "recall");
                      setState(() {
                        _messages[index].isRecalled = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ));
  }

  Future<bool> _onSendingActionMessage(MessageData msg, String action) async {
    final ActionMessageRequest request = ActionMessageRequest(
      senderID: msg.senderID,
      receiverID: msg.receiverID,
      timestamp: msg.timestamp,
      action: action,
    );
    try {
      final ActionMessageResponse response =
          await MessageService().actionMessage(request);
      return response.success ?? false;
    } catch (e) {
      throw Exception(e);
    }
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
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              key: _listKey,
              reverse: true,
              controller: _scrollController,
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                return _buildMessageItem(context, index, animation);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
