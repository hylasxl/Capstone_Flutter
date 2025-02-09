import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class CommentSection extends StatefulWidget {
  final int postID;
  const CommentSection({required this.postID, super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  int? userID;

  final int pageSize = 10;
  int currentPage = 1;

  List<Comment> listComment = [];
  List<GetAccountInfoResponse> accountInfo = [];

  TextEditingController cmtCtrl = TextEditingController();
  FocusNode cmtFNode = FocusNode();

  Set<int> collapsedComments = {};

  bool isFetchingMore = false;
  bool isMoreData = true;
  bool isFetchingComment = false;

  bool isSendIconDisable = true;
  bool isSendingComment = false;

  bool isReplyComment = false;
  int? replyCommentID;
  int? replyCommentLevel;
  String? repliedName;

  @override
  void initState() {
    super.initState();
    getUserID();
    _fetchComments();
  }

  void onCommentTextChange(String value) {
    final txt = value;
    setState(() {
      if (txt.trim() == "") {
        isReplyComment = false;
        replyCommentID = null;
        replyCommentLevel = null;
        isSendIconDisable = true;
      } else {
        isSendIconDisable = false;
      }
    });
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

  Future<void> _fetchComments() async {
    if (!isMoreData || isFetchingComment) return;
    setState(() {
      isFetchingComment = true;
    });

    if (currentPage != 1) {
      setState(() {
        isFetchingMore = true;
      });
    }

    final request = GetPostCommentRequest(
      postID: widget.postID,
      page: currentPage,
      pageSize: pageSize,
    );

    try {
      final response = await PostService().getPostComment(request);
      if (response.success) {
        if (response.comments == null || response.comments!.isEmpty) {
          setState(() {
            isMoreData = false;
          });
        } else {
          setState(() {
            listComment.addAll(response.comments!);
            currentPage++;
            for (final comment in response.comments!) {
              collapsedComments.add(comment.commentId);
              _addCommentAndRepliesToCollapsed(comment);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    } finally {
      setState(() {
        isFetchingComment = false;
        isFetchingMore = false;
      });
    }
  }

  void _addCommentAndRepliesToCollapsed(Comment? comment) {
    if (comment == null) return;

    collapsedComments.remove(comment.commentId);

    if (comment.replies != null) {
      for (final reply in comment.replies!) {
        _addCommentAndRepliesToCollapsed(reply);
      }
    }
  }

  void _onReplyButtonPress(
      int commentID, int commentLevel, String replyDisplayName) {
    setState(() {
      replyCommentID = commentID;
      replyCommentLevel = commentLevel;
      isReplyComment = true;
      repliedName = '@$replyDisplayName ';
    });
    cmtFNode.requestFocus();
    cmtCtrl.clear();
    cmtCtrl.text = '@$replyDisplayName ';
  }

  void _onCommentSend() {
    if (userID == null) return;
    if (isReplyComment) {
      _onReplyComment(userID!);
    } else {
      _onSendingComment(userID!);
    }
    ;
  }

  Future<void> _onReplyComment(int userID) async {
    if (replyCommentID == null || replyCommentLevel == null) return;

    final ReplyCommentRequest request = ReplyCommentRequest(
      accountID: userID,
      content: cmtCtrl.text,
      originalCommentID: replyCommentID!,
      postID: widget.postID,
    );

    try {
      setState(() {
        isSendingComment = true;
      });

      final response = await PostService().replyComment(request);

      if (response.success) {
        Comment newReply = Comment(
          commentId: response.commentID,
          accountId: userID,
          content: cmtCtrl.text,
          isEdited: false,
          level: replyCommentLevel! + 1,
          replies: [],
        );

        setState(() {
          Comment? parentComment =
              findCommentById(listComment, replyCommentID!, replyCommentLevel!);

          if (parentComment != null) {
            parentComment.replies ??= [];
            parentComment.replies!.add(newReply);
            collapsedComments.remove(replyCommentID);
          }
        });
      }
    } catch (e) {
      debugPrint('Error replying to comment: $e');
    } finally {
      setState(() {
        isReplyComment = false;
        replyCommentID = null;
        replyCommentLevel = null;
        isSendingComment = false;
        cmtCtrl.clear();
        cmtFNode.unfocus();
      });
    }
  }

  Future<void> _onSendingComment(int userID) async {
    final CommentPostRequest request = CommentPostRequest(
        accountID: userID, postID: widget.postID, content: cmtCtrl.text);
    try {
      setState(() {
        isSendingComment = true;
      });
      final response = await PostService().commentPost(request);
      if (response.success) {
        listComment.insert(
            0,
            Comment(
                commentId: response.commentID,
                accountId: userID,
                content: cmtCtrl.text,
                isEdited: false,
                level: 1));
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      cmtFNode.unfocus();
      setState(() {
        isSendingComment = false;
        cmtCtrl.clear();
      });
    }
  }

  Comment? findCommentById(
      List<Comment> comments, int targetCommentID, int targetLevel) {
    for (var comment in comments) {
      if (comment.commentId == targetCommentID &&
          comment.level == targetLevel) {
        return comment;
      }

      if (comment.replies!.isNotEmpty) {
        Comment? nestedComment =
            findCommentById(comment.replies!, targetCommentID, targetLevel);
        if (nestedComment != null) {
          return nestedComment;
        }
      }
    }
    return null;
  }

  int findCommentPosition(
      List<Comment> comments, int targetCommentID, int targetLevel,
      [int currentIndex = 0]) {
    for (var i = 0; i < comments.length; i++) {
      var comment = comments[i];
      if (comment.commentId == targetCommentID &&
          comment.level == targetLevel) {
        return currentIndex + i;
      }

      if (comment.replies!.isNotEmpty) {
        int nestedPosition = findCommentPosition(comment.replies!,
            targetCommentID, targetLevel, currentIndex + i + 1);
        if (nestedPosition != -1) {
          return nestedPosition;
        }
      }
    }
    return -1;
  }

  void insertCommentAtPosition(List<Comment> comments, int targetCommentID,
      int targetLevel, Comment newComment) {
    int position = findCommentPosition(comments, targetCommentID, targetLevel);

    if (position != -1) {
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].commentId == targetCommentID &&
            comments[i].level == targetLevel) {
          setState(() {
            listComment[i].replies!.add(newComment);
          });
          comments[i].replies!.add(newComment);
          return;
        }
      }
    } else {}
  }

  Widget _buildComment(Comment comment, {int indentLevel = 0}) {
    final isCollapsed = collapsedComments.contains(comment.commentId);

    return FutureBuilder<GetAccountInfoResponse?>(
      future: _getAccountInfo(comment.accountId),
      builder: (context, snapshot) {
        final accountInfo = snapshot.data;
        return Padding(
          padding: EdgeInsets.only(left: indentLevel * 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (indentLevel > 0)
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: accountInfo != null
                            ? CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                  accountInfo.accountAvatar.avatarUrl,
                                ),
                                onBackgroundImageError: (_, __) {
                                  debugPrint(
                                      "Error loading avatar for ${comment.commentId}");
                                },
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                          accountInfo != null
                              ? accountInfo.accountInfo.nameDisplayType ==
                                      "first_name_first"
                                  ? '${accountInfo.accountInfo.firstName} ${accountInfo.accountInfo.lastName}'
                                  : '${accountInfo.accountInfo.lastName} ${accountInfo.accountInfo.firstName}'
                              : 'Loading...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comment.content),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (comment.replies != null && comment.replies!.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (collapsedComments.contains(comment.commentId)) {
                            collapsedComments.remove(comment.commentId);
                          } else {
                            collapsedComments.add(comment.commentId);
                          }
                        });
                      },
                      child: Text(
                        collapsedComments.contains(comment.commentId)
                            ? AppLocalizations.of(context)!.showReplies
                            : AppLocalizations.of(context)!.hideReplies,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      String name = accountInfo!.accountInfo.nameDisplayType ==
                              "first_name_first"
                          ? '${accountInfo.accountInfo.firstName} ${accountInfo.accountInfo.lastName}'
                          : '${accountInfo.accountInfo.lastName} ${accountInfo.accountInfo.firstName}';
                      _onReplyButtonPress(
                          comment.commentId, comment.level, name);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.reply,
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              if (!isCollapsed && comment.replies != null)
                ...comment.replies!.map(
                  (reply) => _buildComment(reply, indentLevel: indentLevel + 1),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<GetAccountInfoResponse?> _getAccountInfo(int accountId) async {
    final index = accountInfo.indexWhere((item) => item.accountId == accountId);
    if (index != -1) {
      return accountInfo[index];
    }

    final request = GetAccountInfoRequest(accountId: accountId);
    try {
      final response = await UserService().getAccountInfo(request);
      setState(() {
        accountInfo.add(response);
      });
      return response;
    } catch (e) {
      debugPrint('Error fetching account info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      _fetchComments();
                      return true;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: listComment.length,
                    itemBuilder: (context, index) {
                      return AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _buildComment(listComment[index]),
                      );
                    },
                  ),
                ),
              ),
              isFetchingMore == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 330,
                      child: TextField(
                        focusNode: cmtFNode,
                        maxLines: 3,
                        minLines: 1,
                        onChanged: (String value) {
                          onCommentTextChange(value);
                        },
                        controller: cmtCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          hintText: AppLocalizations.of(context)!.typeAComment,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isSendIconDisable || isSendingComment) return;
                        _onCommentSend();
                      },
                      child: isSendingComment
                          ? CircularProgressIndicator()
                          : Icon(
                              Icons.send,
                              size: 35,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
