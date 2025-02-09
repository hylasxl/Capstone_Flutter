import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncio_capstone/utils/time_utils.dart';

class FriendScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const FriendScreen({super.key, this.scrollController});

  @override
  FriendScreenState createState() => FriendScreenState();
}

class FriendScreenState extends State<FriendScreen> {
  final List<GetPendingListReturnSingleLine> _pendingRequests = [];
  bool _isLoading = true;
  String _requestCount = "";
  final List<String> _timeText = [];
  final List<bool> _loadingAvatars = [];
  int page = 1;
  bool _isFetchmore = false;
  final List<String> _resolveResultText = [];
  final List<bool> _isResolveShown = [];
  final List<int> _mutualFriends = [];

  @override
  void initState() {
    super.initState();
    _getRequests();
    _countRequest();
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    const double preloadOffset = 100;
    if (widget.scrollController != null &&
        widget.scrollController!.position.pixels >=
            widget.scrollController!.position.maxScrollExtent - preloadOffset) {
      if (!_isLoading && !_isFetchmore) {
        setState(() {
          _isFetchmore = true;
          page++;
        });
        _getRequests();
      }
    }
  }

  Future<void> _countRequest() async {
    LoginResponse? userData = await Helpers().getUserData();
    if (userData != null) {
      final CountFriendPendingRequest request = CountFriendPendingRequest(
        accountID: int.parse(userData.userID),
      );
      try {
        final response = await FriendService().countFriendPending(request);
        if (response.quantity > 0) {
          setState(() {
            _requestCount = response.quantity.toString();
          });
        } else {
          setState(() {
            _requestCount = "";
          });
        }
      } catch (e) {
        _requestCount = "";
        debugPrint("Error counting friend request: $e");
      }
    }
  }

  Future<void> _getRequests() async {
    LoginResponse? userData = await Helpers().getUserData();
    if (userData != null) {
      final GetPendingListRequest request = GetPendingListRequest(
        accountID: userData.userID,
        page: page,
      );
      try {
        final response = await FriendService().getPendingList(request);
        setState(() {
          _pendingRequests.addAll(response.data);
          _isLoading = false;
          _loadingAvatars.addAll(List<bool>.filled(response.data.length, true));
          _resolveResultText
              .addAll(List<String>.filled(response.data.length, ""));
          _isResolveShown
              .addAll(List<bool>.filled(response.data.length, false));
          _mutualFriends
              .addAll(response.data.map((e) => e.mutualFriends).toList());
        });
        _addTimeText();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("Error getting friend request list: $e");
      } finally {
        setState(() {
          _isFetchmore = false;
        });
      }
    }
  }

  Future<bool> _resolveRequest(String requestID, String action) async {
    LoginResponse? userData = await Helpers().getUserData();
    if (userData != null) {
      final request = ResolveFriendRequest(
        receiverAccountID: (userData.userID),
        requestID: requestID,
        action: action,
      );
      try {
        final response = await FriendService().resolveFriendRequest(request);
        return response.success;
      } catch (e) {
        debugPrint("Error resolving friend request: $e");
        return false;
      }
    }
    return false;
  }

  Future<void> _acceptRequest(String requestID) async {
    bool success = await _resolveRequest(requestID, "accept");
    if (success) {
      int index = _pendingRequests
          .indexWhere((element) => element.requestID == requestID);
      if (index == -1) return;
      setState(() {
        _isResolveShown[index] = true;
        _resolveResultText[index] = AppLocalizations.of(context)!.accepted;
      });
      _countRequest();
    }
  }

  Future<void> _rejectRequest(String requestID) async {
    bool success = await _resolveRequest(requestID, "reject");
    if (success) {
      int index = _pendingRequests
          .indexWhere((element) => element.requestID == requestID);
      setState(() {
        _isResolveShown[index] = true;
        _resolveResultText[index] = AppLocalizations.of(context)!.rejected;
      });
      _countRequest();
    }
  }

  void _addTimeText() {
    _timeText.clear();
    for (var request in _pendingRequests) {
      String txt =
          TimeUtils(timestamp: request.createdAt).convertToText(context);
      _timeText.add(txt);
    }
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    setState(() {
      _isLoading = true;
      _pendingRequests.clear();
      page = 1;
      _requestCount = "";
    });

    await Future.wait([
      _getRequests(),
      _countRequest(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onPageRefresh,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          slivers: [
            SliverAppBar(
                floating: false,
                pinned: true,
                title: Text(
                  AppLocalizations.of(context)!.friend,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: 22,
                    fontFamily: "SFProDisplay",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                bottom: PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    AppLocalizations.of(context)!.online,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onPressed: () async {
                                    LoginResponse? userData =
                                        await Helpers().getUserData();
                                    if (userData == null) return;
                                    Navigator.pushNamed(
                                        context, 'friendListScreen',
                                        arguments: {'userID': userData.userID});
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.yfr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontFamily: "SFProDisplay",
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.fr,
                          ),
                          if (!_isLoading && _requestCount.isNotEmpty)
                            TextSpan(
                              text: '  ',
                            ),
                          TextSpan(
                            text: _requestCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        LoginResponse? userData = await Helpers().getUserData();
                        if (userData == null) return;
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, 'friendRequestScreen',
                            arguments: {'userID': userData.userID.toString()});
                      },
                      child: Text(
                        AppLocalizations.of(context)!.sa,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _pendingRequests.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.noRequest),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = _pendingRequests[index];
                            return ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'profileScreen',
                                      arguments: {
                                        'userID': request.accountInfo.accountID
                                            .toString(),
                                        'isSelf': false
                                      });
                                },
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Skeletonizer(
                                    enabled: _loadingAvatars[index],
                                    child: ClipOval(
                                      child: Image.network(
                                        request.accountInfo.avatarURL,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              if (_loadingAvatars[index]) {
                                                setState(() {
                                                  _loadingAvatars[index] =
                                                      false;
                                                });
                                              }
                                            });
                                            return child;
                                          }
                                          return Container(
                                            color: Colors.grey[300],
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        request.accountInfo.displayName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _timeText.isNotEmpty
                                            ? _timeText[index]
                                            : "",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  if (_mutualFriends[index] > 0)
                                    Text(
                                      "${AppLocalizations.of(context)!.mutualFriends}: ${_mutualFriends[index]}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(0.3)),
                                    ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (!_isResolveShown[index] &&
                                          _resolveResultText[index]
                                              .isEmpty) ...[
                                        Expanded(
                                          child: SizedBox(
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _acceptRequest(
                                                    request.requestID);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  padding: EdgeInsets.all(0)),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .accept,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: SizedBox(
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _rejectRequest(
                                                    request.requestID);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.grey[300]!),
                                                backgroundColor:
                                                    Colors.grey[300],
                                                padding: EdgeInsets.all(0),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .reject,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] else
                                        Center(
                                          child:
                                              Text(_resolveResultText[index]),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _pendingRequests.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
