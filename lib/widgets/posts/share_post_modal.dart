import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/constants/constants.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/widgets/create_post/privacy_modal.dart';

class SharePostModal extends StatefulWidget {
  final int postID;
  const SharePostModal({super.key, required this.postID});

  @override
  State<SharePostModal> createState() => _SharePostModalState();
}

class _SharePostModalState extends State<SharePostModal> {
  bool isAvatarLoading = true;
  bool isDisable = true;

  String? userID;
  GetAccountInfoResponse? userData;

  String privacy = "public";
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserID();
  }

  Future<void> _initUserID() async {
    final LoginResponse? data = await Helpers().getUserData();
    if (data != null) {
      userID = data.userID;
      await _initUserData();
    }
  }

  Future<void> _initUserData() async {
    final GetAccountInfoRequest request =
        GetAccountInfoRequest(accountId: int.parse(userID!));
    try {
      final response = await UserService().getAccountInfo(request);
      setState(() {
        userData = response;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void _checkValidPost() {
    setState(() {
      isDisable =
          _textController.text.isEmpty || _textController.text.length <= 15;
    });
  }

  Future<void> _sharePost() async {
    if (userID != null) {
      final SharePostRequest request = SharePostRequest(
          accountID: userID!,
          content: _textController.text,
          isShared: true,
          originalPostID: widget.postID.toString(),
          privacyStatus: privacy,
          tagAccountIDs: []);
      try {
        final response = await PostService().sharePost(request);
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.sharePostSuccessfully} ID ${response.postID}'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ));
          Navigator.pop(context);
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.sharePost,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: isDisable
                      ? null
                      : () {
                          _sharePost();
                        },
                  child: Text(
                    AppLocalizations.of(context)!.post_verb,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    userData?.accountAvatar.avatarUrl ??
                        Constants.defaultAvatarURL,
                    height: 65,
                    width: 65,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        if (isAvatarLoading) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              isAvatarLoading = false;
                            });
                          });
                        }
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      if (isAvatarLoading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            isAvatarLoading = false;
                          });
                        });
                      }
                      return CircleAvatar(
                        radius: 32.5,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData != null
                            ? userData?.accountInfo.nameDisplayType ==
                                    "first_name_first"
                                ? '${userData?.accountInfo.firstName} ${userData?.accountInfo.lastName}'
                                : '${userData?.accountInfo.lastName} ${userData?.accountInfo.firstName}'
                            : "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showPrivacyBottomSheet(context, (privacyOption) {
                            setState(() {
                              privacy = privacyOption;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Helpers().getPrivacyIcon(privacy),
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              Helpers().getPrivacyText(context, privacy),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextField(
              maxLength: 1000,
              autocorrect: false,
              onChanged: (text) => _checkValidPost(),
              keyboardType: TextInputType.multiline,
              controller: _textController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.snt,
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: Colors.grey[300], fontStyle: FontStyle.italic),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}

void _showPrivacyBottomSheet(
    BuildContext context, ValueChanged<String> onPrivacySelected) async {
  final privacyOption = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return PrivacyBottomSheetContent();
    },
  );

  if (privacyOption != null) {
    onPrivacySelected(privacyOption);
  }
}
