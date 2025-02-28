import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/message_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/services/websocket_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'dart:async';
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

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<SingleAccountInfo> accounts = [];
  int searchPage = 1;
  final int searchPageSize = 10;
  bool isSearchHaveMore = true;
  Timer? _debounce;

  @override
  void initState() {
    _onInitData();
    _webSocketService.connect();
    _webSocketService.messageStream.listen(
      (message) {
        debugPrint("New WebSocket message: \${message.content}");
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
    searchController.dispose();
    _debounce?.cancel();
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

  void _toggleSearchBar() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        accounts.clear();
        searchPage = 1;
        isSearchHaveMore = true;
      }
    });
  }

  Future<void> _onSearch() async {
    final int? userID = await Helpers().getUserId();
    if (userID == null) return;
    if (searchController.text.isEmpty) return;
    final SearchAccountRequest request = SearchAccountRequest(
        requestAccountId: userID,
        queryString: searchController.text.trim(),
        page: searchPage,
        pageSize: searchPageSize);
    final response = await UserService().searchAccount(request);
    setState(() {
      if (response.accounts != null && response.accounts!.isNotEmpty) {
        for (var account in response.accounts!) {
          bool chatExists = chatList.any((chat) =>
              chat.participants.contains(userID) &&
              chat.participants.contains(account.accountID));

          bool accountAlreadyAdded =
              accounts.any((a) => a.accountID == account.accountID);
          bool isDisplayNameValid = account.displayName.trim().isNotEmpty;

          if (!chatExists && !accountAlreadyAdded && isDisplayNameValid) {
            accounts.add(account);
          }
        }
        searchPage++;
      } else {
        isSearchHaveMore = false;
      }
    });
  }

  Future<void> createChat(SingleAccountInfo account) async {
    final int? userID = await Helpers().getUserId();
    if (userID == null || account.accountID <= 0) return;

    final CreateNewChatRequest request = CreateNewChatRequest(
        firstAccountID: userID, secondAccountID: account.accountID);
    try {
      final response = await MessageService().createNewChat(request);
      if (response.success) {
        setState(() {
          chatList.insert(
              0,
              ChatList(
                  accountID: userID,
                  targetAccountID: account.accountID,
                  displayName: account.displayName,
                  avatarURL: account.avatarURL,
                  lastMessageTimestamp:
                      DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  lastMessageContent: "",
                  unreadMessageQuantity: 0,
                  page: 1,
                  pageSize: pageSize,
                  chatId: response.chatID,
                  participants: [userID, account.accountID]));
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
                'Create new chat successfully with ${account.displayName}'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      _toggleSearchBar();
    }
  }

  Future<void> deleteChat(String chatId, String displayName, int index) async {
    final DeleteChatRequest request = DeleteChatRequest(chatID: chatId);
    try {
      final response = await MessageService().deleteChat(request);
      if (response.success) {
        setState(() {
          chatList.removeAt(index);
        });

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Delete chat successfully with $displayName'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  void _showContextMenu(
      BuildContext context, int index, String chatId, String displayName) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    deleteChat(chatId, displayName, index);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
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
        actions: [
          IconButton(
            icon: Icon(!isSearching ? Icons.add : Icons.cancel,
                color: Theme.of(context).primaryColor),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isSearching)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => isSearching = false),
                child: SizedBox(
                  child: Center(
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Enter username...",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {
                                    setState(() {
                                      searchPage = 1;
                                      accounts.clear();
                                      isSearchHaveMore = true;
                                    });
                                    _onSearch();
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                _debounce = Timer(
                                    const Duration(milliseconds: 500), () {
                                  setState(() {
                                    searchPage = 1;
                                    accounts.clear();
                                    isSearchHaveMore = true;
                                  });
                                  _onSearch();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 300,
                              child: NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels ==
                                          scrollInfo.metrics.maxScrollExtent &&
                                      isSearchHaveMore) {
                                    _onSearch();
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  itemCount: accounts.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            accounts[index].avatarURL),
                                      ),
                                      title: Text(accounts[index].displayName),
                                      onTap: () {
                                        print(accounts[index].accountID);
                                        createChat(accounts[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onPageRefresh,
              child: ListView.builder(
                controller: widget.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: chatList.length + 1,
                itemBuilder: (context, index) {
                  if (index == chatList.length) {
                    return _buildLoadingIndicator();
                  }
                  return GestureDetector(
                    onLongPress: () {
                      _showContextMenu(context, index, chatList[index].chatId,
                          chatList[index].displayName);
                    },
                    child: ChatListItem(
                      accountID: chatList[index].accountID,
                      targetAccountID: chatList[index].targetAccountID,
                      displayName: chatList[index].displayName,
                      avatarURL: chatList[index].avatarURL,
                      lastMessageTimestamp:
                          chatList[index].lastMessageTimestamp,
                      lastMessageContent: chatList[index].lastMessageContent,
                      unreadMessageQuantity:
                          chatList[index].unreadMessageQuantity,
                      chatId: chatList[index].chatId,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox.shrink();
  }
}
