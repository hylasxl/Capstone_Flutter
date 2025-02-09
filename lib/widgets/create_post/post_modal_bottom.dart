import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncio_capstone/services/post_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/constants/constants.dart';
import './post_later_modal.dart';
import './privacy_modal.dart';
import './post_tag_friend_modal.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class ModalBottomSheetContent extends StatefulWidget {
  final GetAccountInfoResponse? userData;
  final VoidCallback onImageLoaded;
  final ValueChanged<GetAccountInfoResponse?> onUserDataLoaded;

  const ModalBottomSheetContent({
    super.key,
    required this.userData,
    required this.onImageLoaded,
    required this.onUserDataLoaded,
  });

  @override
  ModalBottomSheetContentState createState() => ModalBottomSheetContentState();
}

class ModalBottomSheetContentState extends State<ModalBottomSheetContent> {
  bool isAvatarLoading = true;
  bool isPublishLater = false;
  bool isPostingLoading = false;
  final bool _isShowMore = false;
  bool isDisable = true;

  String privacy = "public";
  DateTime? selectedDateTime;

  ImagePicker? _picker;
  final List<XFile> _imageList = [];
  final List<MultiMediaMessage> _mediaMessage = [];

  TextEditingController? _textController;
  List<Map<int, String>> tagFriends = [];
  String tagFriendText = "";

  @override
  void initState() {
    _textController = TextEditingController();
    selectedDateTime = null;
    super.initState();
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  String _getTagFriendString() {
    if (tagFriends.isEmpty) return "";

    final firstValue = tagFriends.first.values.first;
    final secondValue = tagFriends[1].values.first;

    switch (tagFriends.length) {
      case 1:
        return " -${AppLocalizations.of(context)!.tagaperson(firstValue)}";
      case 2:
        return " -${AppLocalizations.of(context)!.tag2person(firstValue, secondValue)}";
      default:
        return " -${AppLocalizations.of(context)!.tagmultiple(firstValue, tagFriends.length - 1)}";
    }
  }

  String _formatDate(DateTime date) {
    String locale = Localizations.localeOf(context).toString();
    int hour = date.hour;
    int minute = date.minute;
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');

    if (locale.startsWith("en")) {
      String day = _getEnglishOrdinal(date.day);
      String month = DateFormat.MMMM('en-US').format(date);
      return '${AppLocalizations.of(context)!.formatDate(day, month, date.year.toString())} $formattedHour:$formattedMinute';
    } else {
      return '${AppLocalizations.of(context)!.formatDate(date.day.toString(), date.month.toString(), date.year.toString())} $formattedHour:$formattedMinute';
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

  void _checkValidPost() {
    if ((_textController!.text.isNotEmpty &&
            _textController!.text.length > 15) ||
        _mediaMessage.isNotEmpty) {
      setState(() {
        isDisable = false;
      });
      return;
    }
    setState(() {
      isDisable = true;
    });
  }

  Future<void> _handleCreatePost() async {
    List<String> tagsAccountIDs = [];
    for (var map in tagFriends) {
      for (var key in map.keys) {
        tagsAccountIDs.add(key.toString());
      }
    }
    final CreatePostRequest request = CreatePostRequest(
      accountID: widget.userData!.accountId.toString(),
      content: _textController!.text.trim(),
      privacyStatus: privacy,
      isPublishedLater: isPublishLater,
      publishedLaterTimestamp: selectedDateTime == null
          ? null
          : selectedDateTime!.millisecondsSinceEpoch ~/ 1000,
      tagAccountIDs: tagsAccountIDs,
      medias: _mediaMessage,
    );
    try {
      setState(() {
        isPostingLoading = true;
      });
      FormData formData = await request.toFormData();
      final response = await PostService().createPost(formData);
      if (response.postID.isNotEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content:
                Text(AppLocalizations.of(context)!.postCreatedSuccessfully),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error when creating post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error when creating post'),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception(e);
    } finally {
      setState(() {
        isPostingLoading = false;
      });
    }
  }

  void _pickImage() async {
    final List<XFile> images = await _picker!.pickMultiImage();
    setState(() {
      _imageList.clear();
      _mediaMessage.clear();
    });
    if (images.isNotEmpty) {
      _imageList.clear();
      _imageList.addAll(images.take(10));
      _convertXFileListToRequestMessage();
    } else {
      setState(() {
        _mediaMessage.clear();
      });
    }
    _checkValidPost();
  }

  void _convertXFileListToRequestMessage() {
    if (_imageList.isEmpty) {
      setState(() {
        _mediaMessage.clear();
      });
      return;
    }

    List<MultiMediaMessage> messages = [];
    for (var item in _imageList) {
      File tFile = File(item.path);
      MultiMediaMessage tempMess = MultiMediaMessage(
          type: "picture", uploadStatus: "uploaded", content: "", media: tFile);
      messages.add(tempMess);
    }

    setState(() {
      _mediaMessage.clear();
      _mediaMessage.addAll(messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userData != null && isAvatarLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onUserDataLoaded(widget.userData);
      });
    }

    int imageCount = _imageList.length;
    List<XFile> displayImages =
        _isShowMore ? _imageList : _imageList.take(4).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.syt,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 50,
                      width: 90,
                      child: ElevatedButton(
                        onPressed: isPostingLoading || isDisable
                            ? null
                            : _handleCreatePost,
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor: isDisable
                                ? Colors.grey
                                : Theme.of(context).primaryColor),
                        child: !isPostingLoading
                            ? Text(AppLocalizations.of(context)!.post_verb)
                            : CircularProgressIndicator(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        widget.userData?.accountAvatar.avatarUrl ??
                            Constants.defaultAvatarURL,
                        height: 65,
                        width: 65,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            if (isAvatarLoading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                widget.onImageLoaded();
                              });
                            }
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Text(
                            widget.userData?.accountInfo.nameDisplayType ==
                                    "first_name_first"
                                ? '${widget.userData?.accountInfo.firstName ?? ''} ${widget.userData?.accountInfo.lastName ?? ''} $tagFriendText'
                                : '${widget.userData?.accountInfo.lastName ?? ''} ${widget.userData?.accountInfo.firstName ?? ''} $tagFriendText',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showPrivacyBottomSheet(context,
                                    (privacyOption) {
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
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
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
                            SizedBox(width: 5),
                            if (!isPublishLater)
                              ElevatedButton(
                                onPressed: () {
                                  _showPostLaterBottomSheet(
                                    context,
                                    (onDateTimeSelected) => setState(() {
                                      selectedDateTime = onDateTimeSelected;
                                      isPublishLater =
                                          onDateTimeSelected != null;
                                    }),
                                    selectedDateTime,
                                    isPublishLater,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !isPublishLater
                                      ? Theme.of(context)
                                          .scaffoldBackgroundColor
                                      : Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  side: BorderSide(
                                    color: !isPublishLater
                                        ? Theme.of(context).primaryColor
                                        : Colors.green,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      color: !isPublishLater
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .primaryTextTheme
                                              .bodyLarge!
                                              .color,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      !isPublishLater
                                          ? AppLocalizations.of(context)!
                                              .publishLate
                                          : _formatDate(selectedDateTime!),
                                      style: TextStyle(
                                        color: !isPublishLater
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .primaryTextTheme
                                                .bodyLarge!
                                                .color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: !isPublishLater
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .primaryTextTheme
                                              .bodyLarge!
                                              .color,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (isPublishLater)
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showPostLaterBottomSheet(
                                    context,
                                    (onDateTimeSelected) => setState(() {
                                      selectedDateTime = onDateTimeSelected;
                                      isPublishLater =
                                          onDateTimeSelected != null;
                                    }),
                                    selectedDateTime,
                                    isPublishLater,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !isPublishLater
                                      ? Theme.of(context)
                                          .scaffoldBackgroundColor
                                      : Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  side: BorderSide(
                                    color: !isPublishLater
                                        ? Theme.of(context).primaryColor
                                        : Colors.green,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      color: !isPublishLater
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .primaryTextTheme
                                              .bodyLarge!
                                              .color,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      !isPublishLater
                                          ? AppLocalizations.of(context)!
                                              .publishLate
                                          : _formatDate(selectedDateTime!),
                                      style: TextStyle(
                                        color: !isPublishLater
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .primaryTextTheme
                                                .bodyLarge!
                                                .color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: !isPublishLater
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .primaryTextTheme
                                              .bodyLarge!
                                              .color,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    )
                  ],
                ),
                TextField(
                  maxLength: 1000,
                  autocorrect: false,
                  onChanged: (text) {
                    _checkValidPost();
                  },
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
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200.0,
                            childAspectRatio: 1,
                          ),
                          itemCount: displayImages.length,
                          itemBuilder: (context, index) {
                            if (index == 3 && imageCount > 4) {
                              return Stack(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Image.file(
                                      File(displayImages[3].path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: SizedBox(
                                      child: Center(
                                        child: Text(
                                          "+${imageCount - 4}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Image.file(
                                File(displayImages[index].path),
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 3,
          left: 10,
          right: 0,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo,
                  color: Colors.green,
                ),
                title: Text(AppLocalizations.of(context)!.photos),
                onTap: () {
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.people_alt_sharp,
                  color: Colors.blue[600],
                ),
                title: Text(AppLocalizations.of(context)!.tagFriends),
                onTap: () {
                  _showTagFriendList(context, (onTagListChanged) {
                    setState(() {
                      tagFriends = onTagListChanged;
                      tagFriendText = _getTagFriendString();
                    });
                  }, tagFriends);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showPostLaterBottomSheet(
    BuildContext context,
    ValueChanged<DateTime?> onDateTimeSelected,
    DateTime? initialDateTime,
    bool isPublishLater) async {
  DateTime? selectedDateTime = await showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return PostLaterBottomSheetContent(
        isPublishLater: isPublishLater,
        selectedDateTime: initialDateTime,
        onCancel: () {
          Navigator.pop(context, null);
        },
      );
    },
  );

  onDateTimeSelected(selectedDateTime);
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

void _showTagFriendList(
    BuildContext context,
    ValueChanged<List<Map<int, String>>> onTagListChanged,
    List<Map<int, String>> initListTag) async {
  final tagList = await showModalBottomSheet<List<Map<int, String>>>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: true,
    builder: (BuildContext context) {
      return TagFriendListBottomSheetContent(
        initTagFriends: initListTag,
        onCancel: () {
          Navigator.pop(context, null);
        },
      );
    },
  );

  if (tagList == null) {
    onTagListChanged([]);
  } else {
    onTagListChanged(tagList);
  }
}
