import 'package:flutter/material.dart';
import 'package:syncio_capstone/constants/constants.dart';
import 'package:syncio_capstone/services/friend_service.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/widgets/posts/display_post_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/widgets/create_post/post_modal_bottom.dart';
import 'package:syncio_capstone/widgets/profile/friend_action_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final int userID;
  final bool isSelf;

  const ProfileScreen({
    super.key,
    required this.userID,
    this.isSelf = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GetAccountInfoResponse? userData;
  GetProfileInfoResponse? profileData;
  String? currentUserID;
  String userDisplayName = "";

  List<DisplayPost> postToDisplay = [];
  List<DisplayPost> postBuffer = [];
  int currentPostPageIndex = 1;
  int defaultPostPageSize = 15;
  int postsFetched = 0;
  bool hasMorePost = true;
  bool _isFetchingPost = false;

  bool isRequestSent = false;
  bool isReceivedRequest = false;

  String addContent = "";

  int friendsCount = 0;

  int? requestID;
  bool isFriend = false;
  bool isBlock = false;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _initUserID();
    if (currentUserID != null) {
      await _checkIsBlocked();
      await _getProfileInfo();
      await _getWallPostList();
      await _countFriends();
      await _getSelfPendingListRequest();
      await _checkExistingRequest();
      await _checkSelfExistingRequest();
    }
  }

  Future<void> _checkExistingRequest() async {
    final request = CheckExistingFriendRequestRequest(
        fromAccountID: int.parse(currentUserID!), toAccountID: widget.userID);
    try {
      final response =
          await FriendService().checkExistingFriendRequest(request);
      if (response.isExisting!) {
        setState(() {
          isRequestSent = true;
          addContent = AppLocalizations.of(context)!.cancelRequest;
          requestID = response.requestID;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _checkSelfExistingRequest() async {
    final request = CheckExistingFriendRequestRequest(
        toAccountID: int.parse(currentUserID!), fromAccountID: widget.userID);
    try {
      final response =
          await FriendService().checkExistingFriendRequest(request);
      if (response.isExisting!) {
        setState(() {
          isRequestSent = true;
          requestID = response.requestID;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _getSelfPendingListRequest() async {
    if (widget.isSelf) return;
    final LoginResponse? data = await Helpers().getUserData();
    if (data == null) {
      return;
    }
    final GetPendingListRequest request = GetPendingListRequest(
      accountID: data.userID,
      page: 1,
    );
    try {
      final GetPendingListResponse response =
          await FriendService().getPendingList(request);
      for (var i = 0; i < response.data.length; i++) {
        if (response.data[i].accountInfo.accountID == widget.userID) {
          setState(() {
            isReceivedRequest = true;
            requestID = int.tryParse(response.data[i].requestID);
          });
          break;
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> _resolveRequest(String requestID, String action) async {
    try {
      final userData = await Helpers().getUserData();
      if (userData == null) return false;

      final request = ResolveFriendRequest(
        receiverAccountID: userData.userID,
        requestID: requestID,
        action: action,
      );

      final response = await FriendService().resolveFriendRequest(request);
      if (response.success) {
        setState(() {
          isFriend = (action == "accept");
          isReceivedRequest = false;
        });
        return true;
      }
    } catch (e) {
      debugPrint("Error resolving friend request: $e");
    }
    return false;
  }

  Future<void> _getWallPostList() async {
    if (_isFetchingPost || !hasMorePost) return;
    setState(() {
      _isFetchingPost = true;
    });
    final LoginResponse? data = await Helpers().getUserData();
    GetWallPostListRequest request = GetWallPostListRequest(
        targetAccountId: widget.userID,
        requestAccountId: int.parse(data!.userID),
        page: currentPostPageIndex,
        pageSize: defaultPostPageSize);
    try {
      GetWallPostListResponse response =
          await PostService().getWallPostList(request);
      setState(() {
        if (response.posts != null && response.posts!.isNotEmpty) {
          if (postToDisplay.isEmpty) {
            postToDisplay.addAll(response.posts!.take(10));
            postBuffer.addAll(response.posts!.skip(10).take(5));
          } else {
            postToDisplay.addAll(response.posts!);
            postBuffer.addAll(response.posts!.take(5));
          }
          currentPostPageIndex++;
        } else {
          hasMorePost = false;
        }
      });
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        _isFetchingPost = false;
      });
    }
  }

  Future<void> _initUserID() async {
    final LoginResponse? data = await Helpers().getUserData();
    if (data != null) {
      setState(() {
        currentUserID = data.userID;
      });
      _initUserData();
    } else {
      return;
    }
  }

  Future<void> _initUserData() async {
    final GetAccountInfoRequest request =
        GetAccountInfoRequest(accountId: int.parse(widget.userID.toString()));
    try {
      final GetAccountInfoResponse response =
          await UserService().getAccountInfo(request);
      setState(() {
        userData = response;
        userDisplayName = Helpers().getDisplayName(
            userData!.accountInfo.firstName,
            userData!.accountInfo.lastName,
            userData!.accountInfo.nameDisplayType);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _getProfileInfo() async {
    if (currentUserID == null) {
      return;
    }
    final GetProfileInfoRequest request = GetProfileInfoRequest(
        targetAccountID: widget.userID,
        requestAccountID: int.parse(currentUserID!));
    try {
      final GetProfileInfoResponse response =
          await UserService().getProfileInfo(request);
      setState(() {
        profileData = response;
        if (!widget.isSelf && !profileData!.isFriend) {
          addContent = AppLocalizations.of(context)!.addFriend;
        }
        isFriend = profileData!.isFriend;
        isRequestSent = profileData!.isFriend;
        isBlocked = profileData!.isBlocked;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _checkIsBlocked() async {
    final CheckIsBlockRequest request = CheckIsBlockRequest(
        toAccountID: int.parse(currentUserID!), fromAccountID: widget.userID);
    try {
      final CheckIsBlockResponse response =
          await FriendService().checkIsBlock(request);
      if (response.isBlock!) {
        setState(() {
          isBlock = true;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _countFriends() async {
    final GetDislayListFriend request =
        GetDislayListFriend(accountID: widget.userID.toString());
    try {
      final DisplayListFriendResponse response =
          await FriendService().getListFriend(request);
      if (response.infos == null) {
        return;
      }
      setState(() {
        friendsCount = response.infos!.length;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentUserID == null) {
      _initializeProfile();
    }
  }

  String _formatDate(DateTime date) {
    String locale = Localizations.localeOf(context).toString();

    if (locale.startsWith("en")) {
      String day = _getEnglishOrdinal(date.day);
      String month = DateFormat.MMMM('en-US').format(date);
      return AppLocalizations.of(context)!
          .formatDate(day, month, date.year.toString())
          .toString();
    } else {
      return AppLocalizations.of(context)!
          .formatDate(
            date.day.toString(),
            date.month.toString(),
            date.year.toString(),
          )
          .toString();
    }
  }

  String _getEnglishOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return "${day}th";
    }
    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ModalBottomSheetContent(
              userData: userData,
              onImageLoaded: () {},
              onUserDataLoaded: (GetAccountInfoResponse? data) {
                setState(() {
                  userData = data;
                });
              },
            );
          },
        );
      },
    );
  }

  bool _canShowDateOfBirth() {
    return (widget.isSelf ||
            (profileData!.privacyIndices.dateOfBirth == "public") ||
            (profileData!.privacyIndices.dateOfBirth == "friend_only" &&
                profileData!.isFriend)) &&
        profileData!.accountInfo.dateOfBirth != -62135596800;
  }

  bool _canShowEmail() {
    return (widget.isSelf ||
            (profileData!.privacyIndices.email == "public") ||
            (profileData!.privacyIndices.email == "friend_only" &&
                profileData!.isFriend)) &&
        profileData!.accountInfo.email.isNotEmpty;
  }

  bool _canShowPhoneNumber() {
    return (widget.isSelf ||
            (profileData!.privacyIndices.phoneNumber == "public") ||
            (profileData!.privacyIndices.phoneNumber == "friend_only" &&
                profileData!.isFriend)) &&
        profileData!.accountInfo.phoneNumber.isNotEmpty;
  }

  Widget _buildSelfActions(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () => _showBottomSheet(context),
              child: Text(
                AppLocalizations.of(context)!.syt,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'editDataScreen', arguments: {
                  'dislayName': userDisplayName,
                  'accountInfo': userData!.accountInfo,
                  'accountAvatar': profileData!.accountAvatar,
                  'privacy': profileData!.privacyIndices
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
              ),
              child: Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onUnfriendAction() async {
    if (profileData == null || !isFriend || currentUserID == null) return;

    final UnfriendRequest request = UnfriendRequest(
        fromAccountID: currentUserID!, toAccountID: widget.userID.toString());

    try {
      final response = await FriendService().unFriend(request);
      if (!response.success!) return;
      _onPageRefresh();
    } catch (e) {
      throw Exception(e);
    } finally {}
  }

  Widget _buildIsFriendButton(BuildContext context) {
    return SizedBox(
        child: Row(
      children: [
        SizedBox(
            width: 390,
            height: 50,
            child: GestureDetector(
              onLongPress: () {
                _showFriendActionBottomSheet(context, (bool value) {
                  if (value) {
                    _onPageRefresh();
                  }
                });
              },
              onTap: _onUnfriendAction,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_remove_alt_1,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Unfriend",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            )),
      ],
    ));
  }

  void _showFriendActionBottomSheet(
      BuildContext context, ValueChanged<bool> isChangeValue) async {
    if (profileData == null) return;
    final CheckIsFollowResponse response = await FriendService().checkIsFollow(
        CheckIsFollowRequest(
            fromAccountID: int.parse(currentUserID!),
            toAccountID: widget.userID));
    if (response.isFollow == null) return;
    if (!context.mounted) return;
    final bool? result = await showModalBottomSheet<bool>(
        context: context,
        builder: (BuildContext context) {
          if (currentUserID == null) return SizedBox.shrink();
          return FriendActionBottomSheet(
            isFollow: response.isFollow!,
            currentAccountID: int.parse(currentUserID!),
            profileAccountID: widget.userID,
          );
        });
    if (result != null) {
      isChangeValue(result);
    }
  }

  Widget _buildFriendActions(BuildContext context) {
    return Row(
      children: [
        if (!isFriend && isReceivedRequest) _buildAcceptRejectActions(context),
        if (!isFriend && !isReceivedRequest)
          _buildSendOrCancelRequestAction(context),
        if (isFriend) _buildIsFriendButton(context)
      ],
    );
  }

  Widget _buildAcceptRejectActions(BuildContext context) {
    final CheckExistingFriendRequestRequest request =
        CheckExistingFriendRequestRequest(
            fromAccountID: widget.userID,
            toAccountID: int.parse(currentUserID!));
    try {
      FriendService().checkExistingFriendRequest(request).then((value) {
        if (value.isExisting!) {
          setState(() {
            requestID = value.requestID;
          });
        }
      });
    } catch (e) {
      throw Exception(e);
    }

    return SizedBox(
      width: 390,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFriendButton(
            AppLocalizations.of(context)!.accept,
            () => _resolveRequest(requestID!.toString(), "accept"),
          ),
          _buildFriendButton(
            AppLocalizations.of(context)!.reject,
            () => _resolveRequest(requestID!.toString(), "reject"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFriendRequest(BuildContext context) async {
    if (currentUserID == null) return;
    final SendFriendRequest request = SendFriendRequest(
      fromAccountID: currentUserID!,
      toAccountID: widget.userID.toString(),
    );
    try {
      final SendFriendResponse response =
          await FriendService().sendFriendRequest(request);
      if (!response.success!) {
        return;
      } else {
        print(response.requestID);
        setState(() {
          isRequestSent = true;
          addContent = AppLocalizations.of(context)!.cancelRequest;
          requestID = response.requestID;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _cancelFriendRequest(BuildContext context) async {
    if (requestID == null || currentUserID == null) return;
    final request = RecallRequest(
        requestID: requestID!.toString(), senderAccountID: currentUserID!);
    try {
      print(requestID);
      final RecallResponse response =
          await FriendService().recallFriendRequest(request);
      if (response.success!) {
        setState(() {
          isRequestSent = false;
          addContent = AppLocalizations.of(context)!.addFriend;
          requestID = null;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Widget _buildSendOrCancelRequestAction(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: ElevatedButton(
              onPressed: () async {
                if (currentUserID == null) return;
                final ResolveFriendFollowRequest request =
                    ResolveFriendFollowRequest(
                        fromAccountID: currentUserID!,
                        toAccountID: widget.userID.toString(),
                        action:
                            profileData!.isFollowed ? "unfollow" : "follow");
                try {
                  final response =
                      await FriendService().resolveFriendFollow(request);
                  if (response.success!) {
                    setState(() {
                      profileData!.isFollowed = !profileData!.isFollowed;
                    });
                  }
                } catch (e) {
                  throw Exception(e);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    profileData!.isFollowed
                        ? Icons.remove
                        : Icons.arrow_circle_right,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    profileData!.isFollowed ? "Unfollow" : "Follow",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
        ),
        SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: () async {
              if (!isRequestSent) {
                await _sendFriendRequest(context);
              } else {
                await _cancelFriendRequest(context);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(!isRequestSent ? Icons.send : Icons.close,
                    color: Colors.white),
                SizedBox(width: 5),
                Text(
                  addContent,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 160,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _onPageRefresh() async {
    setState(() {
      postToDisplay = [];
      postBuffer = [];
      currentPostPageIndex = 1;
      defaultPostPageSize = 15;
      postsFetched = 0;
      hasMorePost = true;
      _isFetchingPost = false;
      friendsCount = 0;
    });

    _initializeProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(userDisplayName),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onPageRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification &&
                scrollNotification.metrics.pixels ==
                    scrollNotification.metrics.maxScrollExtent) {
              if (postBuffer.isNotEmpty) {
                setState(() {
                  postToDisplay.addAll(postBuffer.take(5));
                  postBuffer.removeRange(0, postBuffer.length);
                });
              } else if (postBuffer.isEmpty) {
                _getWallPostList();
              }
            }
            return false;
          },
          child: isBlock || isBlocked
              ? Center(
                  child: Text("This account is blocked"),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: profileData != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          Constants.defaultAvatarURL),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 135,
                                  left: 40,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(
                                        profileData!.accountAvatar.avatarUrl,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 210,
                                  left: 170,
                                  child: Text(
                                    userDisplayName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 0,
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 70, bottom: 20),
                        child: profileData != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userData!.accountInfo.bio,
                                      style: TextStyle(fontSize: 16)),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .friendsCount(friendsCount),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  // Date of Birth
                                  if (_canShowDateOfBirth())
                                    Row(
                                      children: [
                                        Icon(Icons.cake),
                                        SizedBox(width: 5),
                                        Text(
                                          _formatDate(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              profileData!
                                                      .accountInfo.dateOfBirth *
                                                  1000,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  // Email
                                  if (_canShowEmail())
                                    Row(
                                      children: [
                                        Icon(Icons.mail),
                                        SizedBox(width: 5),
                                        Text(
                                          profileData!.accountInfo.email,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  // Phone Number
                                  if (_canShowPhoneNumber())
                                    Row(
                                      children: [
                                        Icon(Icons.phone),
                                        SizedBox(width: 5),
                                        Text(
                                          profileData!.accountInfo.phoneNumber,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 20),
                                  if (widget.isSelf)
                                    _buildSelfActions(context)
                                  else
                                    _buildFriendActions(context),
                                ],
                              )
                            : SizedBox(
                                height: 0,
                              ),
                      ),
                    ),
                    // Posts
                    DisplayPostList(postToDisplay: postToDisplay),
                  ],
                ),
        ),
      ),
    );
  }
}
