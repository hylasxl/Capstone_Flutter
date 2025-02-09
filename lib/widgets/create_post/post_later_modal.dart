import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PostLaterBottomSheetContent extends StatefulWidget {
  final bool isPublishLater;
  final DateTime? selectedDateTime;
  final VoidCallback onCancel;

  const PostLaterBottomSheetContent({
    super.key,
    required this.isPublishLater,
    required this.selectedDateTime,
    required this.onCancel,
  });

  @override
  PostLaterBottomSheetContentState createState() =>
      PostLaterBottomSheetContentState();
}

class PostLaterBottomSheetContentState
    extends State<PostLaterBottomSheetContent> {
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.selectedDateTime;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.selectDate,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.selectDate),
          ),
          SizedBox(height: 20),
          if (selectedDateTime != null)
            Text(
              _formatDate(selectedDateTime!),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedDateTime);
                },
                child: Text(AppLocalizations.of(context)!.accept),
              ),
              SizedBox(width: 10),
              if (widget.isPublishLater)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
            ],
          )
        ],
      ),
    );
  }
}
