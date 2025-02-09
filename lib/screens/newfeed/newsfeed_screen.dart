import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/widgets/controll_bar.dart';
import 'package:syncio_capstone/widgets/posts/display_post_list.dart';
import 'package:syncio_capstone/widgets/search_bar_mainscreen.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncio_capstone/widgets/create_post/post_modal_bottom.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsFeedScreen extends StatefulWidget {
  final ScrollController scrollController;
  const NewsFeedScreen({super.key, required this.scrollController});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String? userID;
  GetAccountInfoResponse? userData;
  bool isAvatarLoading = true;
  int currentPage = 1;
  int pageSize = 10;
  List<int> seenPostIds = [];

  List<DisplayPost> postToDisplay = [];
  int postFetched = 0;
  bool hasMorePost = true;
  bool isFetchingPost = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initUserID() async {
    final LoginResponse? data = await Helpers().getUserData();
    if (data != null) {
      setState(() {
        userID = data.userID;
      });
      _initUserData();
    } else {
      return;
    }
  }

  Future<void> _initUserData() async {
    final GetAccountInfoRequest request =
        GetAccountInfoRequest(accountId: int.parse(userID!));
    try {
      final GetAccountInfoResponse response =
          await UserService().getAccountInfo(request);
      userData = response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _initState() async {
    await _initUserID();
    await _initUserData();
    await _getNewFeed();
  }

  Future<void> _getNewFeed() async {
    if (userID == null || !hasMorePost || isFetchingPost) return;

    setState(() {
      isFetchingPost = true;
    });

    final GetNewsFeedRequest request = GetNewsFeedRequest(
      accountID: int.parse(userID!),
      page: currentPage,
      pageSize: pageSize,
      seenPostIds: seenPostIds,
    );

    try {
      final GetNewsFeedResponse response =
          await PostService().getNewsFeed(request);

      if (response.posts != null && response.posts!.isNotEmpty) {
        setState(() {
          seenPostIds.addAll(response.posts!.map((e) => e.postId));
          postToDisplay.addAll(response.posts!);
          postFetched += response.posts!.length;
          currentPage++;
        });
      } else {
        setState(() {
          hasMorePost = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                AppLocalizations.of(context)!.nothingToShow,
              )),
        );
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isFetchingPost = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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
              onImageLoaded: () {
                setState(() {
                  isAvatarLoading = false;
                });
              },
              onUserDataLoaded: (GetAccountInfoResponse? data) {
                setState(() {
                  userData = data;
                  isAvatarLoading = false;
                });
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      currentPage = 1;
      postToDisplay.clear();
      hasMorePost = true;
      seenPostIds.clear();
    });
    await _getNewFeed();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
            _getNewFeed();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: _ControllBarDelegate(),
              ),
              SliverAppBar(
                backgroundColor: themeProvider.currentTheme == ThemeMode.dark
                    ? Color(0xFF121212)
                    : Colors.white,
                expandedHeight: 66,
                floating: true,
                snap: true,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBarMainscreen(
                        onPostPress: () => _showBottomSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
              DisplayPostList(postToDisplay: postToDisplay),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControllBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => 70.0;
  @override
  double get minExtent => 70.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    bool isHideIcon = shrinkOffset > 25;
    double opacity = 1 - (shrinkOffset / maxExtent);
    return Opacity(
      opacity: opacity,
      child: ControllBar(hideSearchIcon: isHideIcon),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
