import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/privacy_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/widgets/create_post/privacy_modal.dart';
import 'package:intl/intl.dart';

class EditDetailScreen extends StatefulWidget {
  final String screenName;
  final String dataType;
  final String? initialValue;
  final String privacyStatus;

  const EditDetailScreen(
      {super.key,
      required this.screenName,
      required this.dataType,
      this.privacyStatus = "public",
      this.initialValue});

  @override
  State<EditDetailScreen> createState() => _EditDetailScreenState();
}

class _EditDetailScreenState extends State<EditDetailScreen> {
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  String groupValue = "first_name_first";
  String? firstNameFirst = "";
  String? lastNameFirst = "";

  String emailPrivacy = "";
  String initEmailPirvacy = "";

  String phonePrivacy = "";
  String initPhonePrivacy = "";

  String genderPrivacy = "";
  String initGenderPrivacy = "";
  String genderGroupValue = "male";
  String initGender = "";

  String dbPrivacy = "";
  String initDbPrivacy = "";
  String db = "";
  String initDb = "";

  String mtPrivacy = "";
  String initMtPrivacy = "";
  String mt = "";
  String initMt = "";

  late TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailPrivacy = widget.privacyStatus;
    initEmailPirvacy = widget.privacyStatus;
    phonePrivacy = widget.privacyStatus;
    initPhonePrivacy = widget.privacyStatus;
    genderPrivacy = widget.privacyStatus;
    initGenderPrivacy = widget.privacyStatus;
    genderGroupValue = widget.initialValue ?? "male";
    initGender = widget.initialValue!;
    initDbPrivacy = widget.privacyStatus;
    initDb = widget.initialValue!;
    dbPrivacy = widget.privacyStatus;
    db = widget.initialValue!;
    initMtPrivacy = widget.privacyStatus;
    initMt = widget.initialValue!;
    mtPrivacy = widget.privacyStatus;
    mt = widget.initialValue!;
    dateController.text = _getDateText(widget.initialValue ?? "");
    _initName();
  }

  @override
  void didChangeDependencies() {
    dateController.text = _getDateText(db);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _initName() {
    if (widget.dataType == "displayName") {
      String name = widget.initialValue ?? "";
      int spaceIndex = name.indexOf(" ");
      if (spaceIndex > 0) {
        firstNameController.text = name.substring(0, spaceIndex).trim();
        lastNameController.text = name.substring(spaceIndex + 1).trim();
        setState(() {
          firstNameFirst =
              '${firstNameController.text} ${lastNameController.text}';
          lastNameFirst =
              '${lastNameController.text} ${firstNameController.text}';
        });
      } else {
        firstNameController.text = name.trim();
        lastNameController.clear();
      }
    }
  }

  String _getDateText(String value) {
    try {
      int timestamp = int.parse(value);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return _formatDate(dateTime);
    } catch (e) {
      return 'Invalid date';
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

  void _onTextInputChange() {
    if (widget.dataType == "displayName") {
      setState(() {
        firstNameFirst =
            '${firstNameController.text} ${lastNameController.text}';
        lastNameFirst =
            '${lastNameController.text} ${firstNameController.text}';
        firstNameFirst = firstNameFirst!.trim();
        lastNameFirst = lastNameFirst!.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(widget.screenName),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.dataType == "displayName") ...[
              Text(
                AppLocalizations.of(context)!.wynd,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: firstNameController,
                onChanged: (value) => _onTextInputChange(),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fn,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: lastNameController,
                onChanged: (value) => _onTextInputChange(),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.ln,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.displayType,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              if (firstNameFirst != "" && lastNameFirst != "") ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        firstNameFirst ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Radio(
                      value: "first_name_first",
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value.toString();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lastNameFirst ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Radio(
                      value: "last_name_first",
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ],
              (firstNameController.text != "" && lastNameController.text != "")
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: firstNameController.text,
                                  dataFieldName: "first_name"));
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: lastNameController.text,
                                  dataFieldName: "last_name"));
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: groupValue,
                                  dataFieldName: "name_display_type"));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else if (widget.dataType == "birthday") ...[
              TextField(
                onTap: () async {
                  final DateTime today = DateTime.now();
                  final DateTime ageLimit =
                      DateTime(today.year - 16, today.month, today.day);
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: ageLimit,
                    firstDate: DateTime(1900),
                    lastDate: ageLimit,
                  );
                  if (picked != null) {
                    setState(() {
                      db = (picked.millisecondsSinceEpoch ~/ 1000).toString();
                      dateController.text = _formatDate(picked);
                    });
                  }
                },
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.bd,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyBottomSheet(context, (privacyOption) {
                    setState(() {
                      dbPrivacy = privacyOption;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers().getPrivacyIcon(dbPrivacy),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Helpers().getPrivacyText(context, dbPrivacy),
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
              const SizedBox(height: 15),
              (initDbPrivacy != dbPrivacy || initDb != db)
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          await PrivacyService().setPrivacy(SetPrivacyRequest(
                              accountID: int.parse(userData.userID),
                              privacyIndex: 1,
                              privacyStatus: dbPrivacy));
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: db,
                                  dataFieldName: "date_of_birth"));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else if (widget.dataType == "gender") ...[
              Text(
                AppLocalizations.of(context)!.gdd,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.male,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Radio(
                    value: "male",
                    groupValue: genderGroupValue,
                    onChanged: (value) {
                      setState(() {
                        genderGroupValue = value.toString();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.female,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Radio(
                    value: "female",
                    groupValue: genderGroupValue,
                    onChanged: (value) {
                      setState(() {
                        genderGroupValue = value.toString();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.other,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Radio(
                    value: "other",
                    groupValue: genderGroupValue,
                    onChanged: (value) {
                      setState(() {
                        genderGroupValue = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyBottomSheet(context, (privacyOption) {
                    setState(() {
                      genderPrivacy = privacyOption;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers().getPrivacyIcon(genderPrivacy),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Helpers().getPrivacyText(context, genderPrivacy),
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
              (initGenderPrivacy != genderPrivacy ||
                      initGender != genderGroupValue)
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          await PrivacyService().setPrivacy(SetPrivacyRequest(
                              accountID: int.parse(userData.userID),
                              privacyIndex: 2,
                              privacyStatus: genderPrivacy));
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: genderGroupValue,
                                  dataFieldName: "gender"));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else if (widget.dataType == "phone") ...[
              TextField(
                readOnly: true,
                controller: TextEditingController(text: widget.initialValue),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumber,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyBottomSheet(context, (privacyOption) {
                    setState(() {
                      phonePrivacy = privacyOption;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers().getPrivacyIcon(phonePrivacy),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Helpers().getPrivacyText(context, phonePrivacy),
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
              const SizedBox(height: 15),
              (initPhonePrivacy != phonePrivacy)
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          await PrivacyService().setPrivacy(SetPrivacyRequest(
                              accountID: int.parse(userData.userID),
                              privacyIndex: 4,
                              privacyStatus: phonePrivacy));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else if (widget.dataType == "email") ...[
              TextField(
                readOnly: true,
                controller: TextEditingController(text: widget.initialValue),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.em,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyBottomSheet(context, (privacyOption) {
                    setState(() {
                      emailPrivacy = privacyOption;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers().getPrivacyIcon(emailPrivacy),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Helpers().getPrivacyText(context, emailPrivacy),
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
              const SizedBox(height: 15),
              (initEmailPirvacy != emailPrivacy)
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          await PrivacyService().setPrivacy(SetPrivacyRequest(
                              accountID: int.parse(userData.userID),
                              privacyIndex: 5,
                              privacyStatus: emailPrivacy));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else if (widget.dataType == "material_status") ...[
              Text(
                AppLocalizations.of(context)!.materialStatus,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              DropdownButton<String>(
                value: mt,
                items: [
                  "single",
                  "in_a_relationship",
                  "engaged",
                  "married",
                  "in_a_civil_union",
                  "in_a_domestic_partnership",
                  "in_an_open_relationship",
                  "it_complicated",
                  "separated",
                  "divorced",
                  "widowed",
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(Helpers().getMaterialStatus(value, context)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    mt = value!;
                  });
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyBottomSheet(context, (privacyOption) {
                    setState(() {
                      mtPrivacy = privacyOption;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers().getPrivacyIcon(mtPrivacy),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Helpers().getPrivacyText(context, mtPrivacy),
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
              (initMtPrivacy != mtPrivacy || initMt != mt)
                  ? ElevatedButton(
                      onPressed: () async {
                        final userData = await Helpers().getUserData();
                        if (userData == null) return;
                        try {
                          print(mt);
                          await PrivacyService().setPrivacy(SetPrivacyRequest(
                              accountID: int.parse(userData.userID),
                              privacyIndex: 3,
                              privacyStatus: mtPrivacy));
                          await UserService().changeUserInfo(
                              ChangeAccountInfoRequest(
                                  accountID: int.parse(userData.userID),
                                  data: mt,
                                  dataFieldName: "marital_status"));
                          Navigator.pop(context);
                        } catch (e) {
                          throw Exception(e);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                  : SizedBox.shrink(),
            ] else
              ...[],
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
