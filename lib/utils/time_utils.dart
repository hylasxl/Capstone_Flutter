import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeUtils {
  int timestamp;
  TimeUtils({required this.timestamp});

  String convertToText(BuildContext context) {
    DateTime parsedTimestamp =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

    DateTime currentTimeUtc = DateTime.now().toUtc();
    DateTime currentUTC7 = currentTimeUtc.add(Duration(hours: 0));

    Duration difference = currentUTC7.difference(parsedTimestamp);
    int durationInSeconds = difference.inSeconds;

    if (durationInSeconds < 60) {
      return AppLocalizations.of(context)!.justNow;
    } else if (durationInSeconds < 3600) {
      int minutes = (durationInSeconds / 60).floor();
      return AppLocalizations.of(context)!.minuteAgo(minutes);
    } else if (durationInSeconds < 86400) {
      int hours = (durationInSeconds / 3600).floor();
      return AppLocalizations.of(context)!.hourAgo(hours);
    } else if (durationInSeconds < 604800) {
      int days = (durationInSeconds / 86400).floor();
      return AppLocalizations.of(context)!.dayAgo(days);
    } else if (durationInSeconds < 2419200) {
      int weeks = (durationInSeconds / 604800).floor();
      return AppLocalizations.of(context)!.weekAgo(weeks);
    } else if (durationInSeconds < 29030400) {
      int months = (durationInSeconds / 2419200).floor();
      return AppLocalizations.of(context)!.monthAgo(months);
    } else {
      int years = (durationInSeconds / 29030400).floor();
      return AppLocalizations.of(context)!.yearAgo(years);
    }
  }
}
