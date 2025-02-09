import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncio_capstone/utils/time_utils.dart';
import 'package:syncio_capstone/services/friend_service.dart';

class FriendRequestScreen extends StatefulWidget {
  final int userID;
  const FriendRequestScreen({super.key, required this.userID});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final List<GetPendingListReturnSingleLine> _pendingRequests = [];
  bool _isLoading = true;
  String _requestCount = "";
  int page = 1;
  final List<String> _timeText = [];
  final List<bool> _loadingAvatars = [];
  final List<String> _resolveResultText = [];
  final List<bool> _isResolveShown = [];
  final List<int> _mutualFriends = [];

  @override
  void initState() {
    super.initState();
    _getRequests();
    _countRequest();
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
        debugPrint(response.data.toString());
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "SFProDisplay"),
                  children: [
                TextSpan(text: AppLocalizations.of(context)!.fr),
                TextSpan(
                    text: " $_requestCount",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold))
              ])),
          titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "SFProDisplay",
          ),
        ),
        body: RefreshIndicator(
            onRefresh: _onPageRefresh,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _pendingRequests.isNotEmpty
                    ? Column(
                        children: [
                          Expanded(
                              child: ListView.builder(
                                  itemCount: _pendingRequests.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, 'profileScreen',
                                              arguments: {
                                                'userID':
                                                    _pendingRequests[index]
                                                        .accountInfo
                                                        .accountID
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
                                                _pendingRequests[index]
                                                    .accountInfo
                                                    .avatarURL,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (_loadingAvatars[
                                                          index]) {
                                                        setState(() {
                                                          _loadingAvatars[
                                                              index] = false;
                                                        });
                                                      }
                                                    });
                                                    return child;
                                                  }
                                                  return Container(
                                                    color: Colors.grey[300],
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _pendingRequests[index]
                                                    .accountInfo
                                                    .displayName,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                _timeText.isNotEmpty
                                                    ? _timeText[index]
                                                    : "",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontStyle:
                                                        FontStyle.italic),
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
                                                            _pendingRequests[
                                                                    index]
                                                                .requestID);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0)),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .accept,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                            _pendingRequests[
                                                                    index]
                                                                .requestID);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                            color: Colors
                                                                .grey[300]!),
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        padding:
                                                            EdgeInsets.all(0),
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .reject,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ] else
                                                Center(
                                                  child: Text(
                                                      _resolveResultText[
                                                          index]),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }))
                        ],
                      )
                    : Center(
                        child: Text(AppLocalizations.of(context)!.noRequest),
                      )));
  }
}
