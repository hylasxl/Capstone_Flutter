import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';

class EditDataScreen extends StatefulWidget {
  final String dislayName;
  final AccountInfo accountInfo;
  final AccountAvatar accountAvatar;
  final PrivacyIndices privacy;

  const EditDataScreen(
      {super.key,
      required this.dislayName,
      required this.accountInfo,
      required this.accountAvatar,
      required this.privacy});

  @override
  State<EditDataScreen> createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  XFile? avatarImage;
  bool isImageChanged = false;
  bool isConfirmImageChanged = false;
  bool isChanging = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        avatarImage = pickedFile;
        isImageChanged = true;
      });
    } else {
      if (!mounted) return;
      avatarImage = null;
      isImageChanged = false;
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

  Future<void> _changeAvatar() async {
    final userData = await Helpers().getUserData();
    if (userData?.userID == null) {
      return;
    }

    if (avatarImage != null) {
      setState(() {
        isChanging = true;
      });

      String? avatar = await _getAvatarBase64();
      if (avatar == null) {
        setState(() {
          isChanging = false;
        });
        return;
      }

      try {
        await UserService().changeAvatar(ChangeAvatarRequest(
          accountID: int.parse(userData!.userID),
          avatar: avatar,
        ));
        setState(() {
          isChanging = false;
          isImageChanged = false;
        });
      } catch (e) {
        setState(() {
          isChanging = false;
        });
        print('Failed to change avatar: $e');
      }
    }
  }

  Future<String?> _getAvatarBase64() async {
    if (avatarImage != null) {
      File imageFile = File(avatarImage!.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(widget.dislayName),
          titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "SFProDisplay",
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: Column(
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: ClipOval(
                        child: avatarImage != null
                            ? Image.file(
                                File(avatarImage!.path),
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.accountAvatar.avatarUrl,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.person,
                                  size: 180,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isImageChanged
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: isChanging
                                  ? null // Disable while saving
                                  : () async {
                                      await _changeAvatar();
                                    },
                              child: isChanging
                                  ? CircularProgressIndicator(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    )
                                  : Text(AppLocalizations.of(context)!.save),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (isChanging) return;
                                setState(() {
                                  avatarImage = null;
                                  isImageChanged = false;
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        )
                      : SizedBox.shrink(), // Hide buttons if no changes
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(widget.dislayName),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName':
                              AppLocalizations.of(context)!.displayName,
                          'dataType': 'displayName',
                          'initialValue': widget.dislayName,
                        });
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.em,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("\u2022"),
                      Icon(
                        Helpers().getPrivacyIcon(widget.privacy.email),
                        size: 18,
                      ),
                    ],
                  ),
                  subtitle: Text(widget.accountInfo.email),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName': AppLocalizations.of(context)!.em,
                          'dataType': 'email',
                          'initialValue': widget.accountInfo.email,
                          'privacyStatus': widget.privacy.email,
                        });
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.phoneNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("\u2022"),
                      Icon(Helpers().getPrivacyIcon(widget.privacy.phoneNumber),
                          size: 18),
                    ],
                  ),
                  subtitle: Text(widget.accountInfo.phoneNumber),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName':
                              AppLocalizations.of(context)!.phoneNumber,
                          'dataType': 'phone',
                          'initialValue': widget.accountInfo.phoneNumber,
                          'privacyStatus': widget.privacy.phoneNumber,
                        });
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.gd,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("\u2022"),
                      Icon(Helpers().getPrivacyIcon(widget.privacy.gender),
                          size: 18),
                    ],
                  ),
                  subtitle: Text(
                      toBeginningOfSentenceCase(widget.accountInfo.gender)),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName': AppLocalizations.of(context)!.gd,
                          'dataType': 'gender',
                          'initialValue': widget.accountInfo.gender,
                          'privacyStatus': widget.privacy.gender,
                        });
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.bd,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("\u2022"),
                      Icon(Helpers().getPrivacyIcon(widget.privacy.dateOfBirth),
                          size: 18),
                    ],
                  ),
                  subtitle: Text(_formatDate(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.accountInfo.dateOfBirth * 1000))),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName': AppLocalizations.of(context)!.bd,
                          'dataType': 'birthday',
                          'initialValue':
                              widget.accountInfo.dateOfBirth.toString(),
                          'privacyStatus': widget.privacy.dateOfBirth,
                        });
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.materialStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("\u2022"),
                      Icon(
                        Helpers().getPrivacyIcon(widget.privacy.materialStatus),
                        size: 18,
                      ),
                    ],
                  ),
                  subtitle: Text(Helpers().getMaterialStatus(
                      widget.accountInfo.materialStatus, context)),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.pushNamed(context, 'editDetailScreen',
                        arguments: {
                          'screenName':
                              AppLocalizations.of(context)!.materialStatus,
                          'dataType': 'material_status',
                          'initialValue': widget.accountInfo.materialStatus,
                          'privacyStatus': widget.privacy.materialStatus,
                        });
                  },
                ),
                ListTile(
                  title: Text("View Block List"),
                  trailing: Icon(Icons.block),
                  onTap: () {
                    Navigator.of(context).pushNamed("blockListScreen");
                  },
                )
              ],
            )
          ],
        ));
  }
}
