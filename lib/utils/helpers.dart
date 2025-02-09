import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncio_capstone/services/types.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Helpers {
  Future<LoginResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('userData');

    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return LoginResponse.fromJson(jsonMap);
    }
    return null;
  }

  String getPrivacyText(BuildContext context, String privacy) {
    switch (privacy) {
      case "public":
        return AppLocalizations.of(context)!.public;
      case "private":
        return AppLocalizations.of(context)!.private;
      case "friend_only":
        return AppLocalizations.of(context)!.friendOnly;
      default:
        return AppLocalizations.of(context)!.public;
    }
  }

  IconData getPrivacyIcon(String privacy) {
    switch (privacy) {
      case "public":
        return Icons.public;
      case "private":
        return Icons.lock;
      case "friend_only":
        return Icons.people;
      default:
        return Icons.public;
    }
  }

  IconData getReactIcon(String type) {
    switch (type) {
      case "like":
        return Icons.thumb_up_outlined;
      case "dislike":
        return Icons.thumb_down_alt_outlined;
      case "love":
        return Icons.favorite_outline;
      case "hate":
        return Icons.sentiment_very_dissatisfied;
      case "cry":
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.thumb_up_outlined;
    }
  }

  Color getReactColor(BuildContext context, String type) {
    switch (type) {
      case "like":
        return Color.fromRGBO(25, 4, 169, 21);
      case "dislike":
        return Colors.red;
      case "love":
        return Colors.redAccent;
      case "hate":
        return Colors.deepOrange;
      case "cry":
        return Colors.blueAccent;
      default:
        return Colors.black;
    }
  }

  String getDisplayName(String firstName, String lastName, String displayType) {
    switch (displayType) {
      case "first_name_first":
        return "$firstName $lastName";
      case "last_name_first":
        return "$lastName $firstName";
      default:
        return "$firstName $lastName";
    }
  }

  String getMaterialStatus(String type, BuildContext context) {
    switch (type) {
      case "single":
        return AppLocalizations.of(context)!.single;
      case "in_a_relationship":
        return AppLocalizations.of(context)!.in_a_relationship;
      case "engaged":
        return AppLocalizations.of(context)!.engaged;
      case "married":
        return AppLocalizations.of(context)!.married;
      case "in_a_civil_union":
        return AppLocalizations.of(context)!.in_a_civil_union;
      case "in_a_domestic_partnership":
        return AppLocalizations.of(context)!.in_a_domestic_partnership;
      case "in_an_open_relationship":
        return AppLocalizations.of(context)!.in_an_open_relationship;
      case "its_complicated":
        return AppLocalizations.of(context)!.its_complicated;
      case "separated":
        return AppLocalizations.of(context)!.separated;
      case "divorced":
        return AppLocalizations.of(context)!.divorced;
      case "widowed":
        return AppLocalizations.of(context)!.widowed;
      default:
        return AppLocalizations.of(context)!.single;
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('userData');

    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final LoginResponse jsonData = LoginResponse.fromJson(jsonMap);
      return int.parse(jsonData.userID);
    }
    return null;
  }
}
