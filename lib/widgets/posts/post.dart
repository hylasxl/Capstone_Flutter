import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/utils/time_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/widgets/posts/interation_bar.dart';

class Post extends StatefulWidget {
  final int index;
  final DisplayPost postToDisplay;
  const Post({required this.index, required this.postToDisplay, super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  int? userID;

  @override
  void initState() {
    getUserID();
    super.initState();
  }

  Future<void> getUserID() async {
    final userData = await Helpers().getUserData();
    if (userData != null) {
      setState(() {
        userID = int.parse(userData.userID);
      });
    } else {
      userID = null;
    }
  }

  Widget renderImage(
      int quantity, List<String> imageURLs, BuildContext context) {
    if (quantity == 0) return SizedBox.shrink();

    double screenWidth = MediaQuery.of(context).size.width;

    Widget buildImage(String url,
        {double width = double.infinity, double height = 300.0}) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Skeletonizer(
              child: Container(
                width: width,
                height: height,
                color: Colors.grey[100],
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error);
        },
      );
    }

    if (quantity == 1) {
      return SizedBox(
        width: screenWidth,
        height: 300,
        child: buildImage(imageURLs[0]),
      );
    }

    if (quantity == 2) {
      return SizedBox(
        width: screenWidth,
        height: 300,
        child: Row(
          children: [
            Expanded(child: buildImage(imageURLs[0], width: screenWidth / 2)),
            Expanded(child: buildImage(imageURLs[1], width: screenWidth / 2)),
          ],
        ),
      );
    }

    if (quantity == 3) {
      return SizedBox(
        width: screenWidth,
        height: 300,
        child: Column(
          children: [
            buildImage(imageURLs[0], width: screenWidth, height: 300 / 2),
            Row(
              children: [
                Expanded(
                    child: buildImage(imageURLs[1],
                        width: screenWidth / 2, height: 300 / 2)),
                Expanded(
                    child: buildImage(imageURLs[2],
                        width: screenWidth / 2, height: 300 / 2)),
              ],
            ),
          ],
        ),
      );
    }

    if (quantity >= 4) {
      return SizedBox(
        width: screenWidth,
        height: 300,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: buildImage(imageURLs[0],
                        width: screenWidth / 2, height: 300 / 2)),
                Expanded(
                    child: buildImage(imageURLs[1],
                        width: screenWidth / 2, height: 300 / 2)),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: buildImage(imageURLs[2],
                        width: screenWidth / 2, height: 300 / 2)),
                Expanded(
                    child: buildImage(imageURLs[3],
                        width: screenWidth / 2, height: 300 / 2)),
              ],
            ),
          ],
        ),
      );
    }

    return Container();
  }

  List<String> _getImageURLs(List<PostShareMediaDisplay> mediaList) {
    if (mediaList.isEmpty) return List.empty();
    List<String> result = [];
    for (var item in mediaList) {
      result.add(item.url);
    }
    return result;
  }

  List<String> _getTwoMostReact(List<PostReactionData> data) {
    final Map<String, int> reactionCounts = {};
    for (var reaction in data) {
      reactionCounts[reaction.reactionType] =
          (reactionCounts[reaction.reactionType] ?? 0) + 1;
    }

    final sortedReactions = reactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTwoReactions =
        sortedReactions.take(2).map((entry) => entry.key).toList();

    return topTwoReactions;
  }

  void onAvatarTap() {
    if (userID == null) return;
    Navigator.pushNamed(context, 'profileScreen', arguments: {
      'userID': widget.postToDisplay.account.accountID.toString(),
      'isSelf': checkIsSelf(),
    });
  }

  bool checkIsSelf() {
    return userID == widget.postToDisplay.account.accountID;
  }

  void _showContextMenu(BuildContext context, DisplayPost post) {
    showModalBottomSheet(
        context: context,
        builder: (buider) {
          return Wrap(
            children: [
              if (post.account.accountID == userID)
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text("Edit"),
                  onTap: () {},
                ),
              if (post.account.accountID == userID)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Delete"),
                  onTap: () {
                    _onPostDelete(post.postId);
                  },
                ),
              if (post.account.accountID != userID)
                ListTile(
                  leading: Icon(Icons.warning),
                  title: Text("Report"),
                  onTap: () {},
                ),
            ],
          );
        });
  }

  Future<void> _onPostDelete(int postID) async {
    final request = DeletePostRequest(postID: postID);
    try {
      final response = await PostService().deletePost(request);
      if (response.success!) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Post deleted"),
        ));
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
            width: double.infinity,
            child: Container(
              color: themeProvider.currentTheme == ThemeMode.light
                  ? Colors.grey[200]
                  : Colors.black45,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: onAvatarTap,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                widget.postToDisplay.account.avatarURL),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.postToDisplay.account.displayName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: TimeUtils(
                                                timestamp: widget
                                                    .postToDisplay.createdAt)
                                            .convertToText(context),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Helpers().getPrivacyIcon(
                                      widget.postToDisplay.privacyStatus),
                                  size: 16,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withOpacity(0.7),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showContextMenu(context, widget.postToDisplay),
                          child: Icon(Icons.more_vert),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.postToDisplay.content,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  renderImage(widget.postToDisplay.medias.length,
                      _getImageURLs(widget.postToDisplay.medias), context),
                  !(widget.postToDisplay.isShared &&
                          widget.postToDisplay.sharePostData.isPublished)
                      ? SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color:
                                  themeProvider.currentTheme == ThemeMode.light
                                      ? (Colors.grey[200] ?? Colors.grey)
                                      : (Colors.black45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: onAvatarTap,
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage: NetworkImage(
                                                      widget
                                                          .postToDisplay
                                                          .sharePostData
                                                          .account!
                                                          .avatarURL),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.postToDisplay.account
                                                        .displayName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: TimeUtils(
                                                                      timestamp: widget
                                                                          .postToDisplay
                                                                          .createdAt)
                                                                  .convertToText(
                                                                      context),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .color!
                                                                    .withOpacity(
                                                                        0.7),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color
                                                                  ?.withOpacity(
                                                                      0.7),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Icon(
                                                        Helpers().getPrivacyIcon(
                                                            widget
                                                                .postToDisplay
                                                                .sharePostData
                                                                .privacyStatus),
                                                        size: 16,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color
                                                            ?.withOpacity(0.7),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          widget.postToDisplay.sharePostData
                                              .content,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        renderImage(
                                            widget.postToDisplay.sharePostData
                                                .medias!.length,
                                            _getImageURLs(widget.postToDisplay
                                                .sharePostData.medias!),
                                            context)
                                      ]))
                            ],
                          )),
                ]),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.postToDisplay.reactions.totalQuantity > 0
                ? SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _getTwoMostReact(widget
                                          .postToDisplay.reactions.reactions!)
                                      .isNotEmpty
                                  ? Icon(
                                      Helpers().getReactIcon(
                                        _getTwoMostReact(widget.postToDisplay
                                            .reactions.reactions!)[0],
                                      ),
                                      color: Helpers().getReactColor(
                                        context,
                                        _getTwoMostReact(widget.postToDisplay
                                            .reactions.reactions!)[0],
                                      ),
                                    )
                                  : SizedBox(),
                              _getTwoMostReact(widget.postToDisplay.reactions
                                              .reactions!)
                                          .length ==
                                      2
                                  ? Icon(
                                      Helpers().getReactIcon(
                                        _getTwoMostReact(widget.postToDisplay
                                            .reactions.reactions!)[1],
                                      ),
                                      color: Helpers().getReactColor(
                                        context,
                                        _getTwoMostReact(widget.postToDisplay
                                            .reactions.reactions!)[1],
                                      ),
                                    )
                                  : SizedBox(),
                              widget.postToDisplay.reactions.totalQuantity > 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        widget.postToDisplay.reactions
                                            .totalQuantity
                                            .toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Row(
                            children: [
                              widget.postToDisplay.commentQuantity
                                          .totalQuantity >
                                      0
                                  ? Text(
                                      AppLocalizations.of(context)!.comment(
                                        widget.postToDisplay.commentQuantity
                                            .totalQuantity,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(width: 5),
                              widget.postToDisplay.shares.totalQuantity > 0
                                  ? Text(
                                      AppLocalizations.of(context)!.share(
                                        widget
                                            .postToDisplay.shares.totalQuantity,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          InteractionBar(
            selfInteractionType: widget.postToDisplay.interactionType,
            onReactPress: (String type) async {
              if (type != "remove") {
                setState(() {
                  widget.postToDisplay.interactionType = type;
                  widget.postToDisplay.reactions.reactions!.add(
                      PostReactionData(
                          reactionType: type,
                          account: widget.postToDisplay.account));
                  widget.postToDisplay.reactions.totalQuantity++;
                });
                if (userID != null) {
                  final ReactPostRequest request = ReactPostRequest(
                    postID: widget.postToDisplay.postId,
                    accountID: userID!,
                    reactType: type,
                  );
                  try {
                    final response = await PostService().reactPost(request);

                    if (response.success) {}
                  } catch (e) {
                    throw Exception(e);
                  }
                } else {
                  print("User ID is null, cannot proceed.");
                }
              } else {
                setState(() {
                  widget.postToDisplay.interactionType = "";
                  widget.postToDisplay.reactions.reactions!.removeWhere(
                      (item) =>
                          item.account.accountID ==
                          widget.postToDisplay.account.accountID);
                  widget.postToDisplay.reactions.totalQuantity--;
                });
                if (userID != null) {
                  final RemoveReactPostRequest request = RemoveReactPostRequest(
                      postID: widget.postToDisplay.postId, accountID: userID!);
                  try {
                    final response =
                        await PostService().removeReactPost(request);
                    if (response.success) {}
                  } catch (e) {
                    throw Exception(e);
                  }
                } else {
                  print("User ID is null, cannot proceed.");
                }
              }
            },
            parentType: "post",
            parentID: widget.postToDisplay.postId,
            isShared: widget.postToDisplay.isShared,
            privacy: widget.postToDisplay.privacyStatus,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
