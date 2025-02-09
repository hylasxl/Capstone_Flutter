import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterBirthday extends StatefulWidget {
  const RegisterBirthday({super.key});

  @override
  RegisterBirthdayState createState() => RegisterBirthdayState();
}

class RegisterBirthdayState extends State<RegisterBirthday> {
  DateTime _selectedDate = DateTime.now();
  bool _showSnackBar = false;
  String? _snackBarText;

  void _handleNext(BuildContext context) {
    if (_selectedDate == DateTime.now()) {
      _showSnackBarWithMessage(AppLocalizations.of(context)!.pebd);
      return;
    }
    int age = DateTime.now().year - _selectedDate.year;
    if (DateTime.now().month < _selectedDate.month ||
        (DateTime.now().month == _selectedDate.month &&
            DateTime.now().day < _selectedDate.day)) {
      age--;
    }
    if (age < 16) {
      _showSnackBarWithMessage(AppLocalizations.of(context)!.uma16yo);
      return;
    }
    Navigator.of(context).pushNamed('registerGender');
  }

  void _showSnackBarWithMessage(String message) {
    setState(() {
      _showSnackBar = true;
      _snackBarText = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSnackBar = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: RegisterForm(
              title: AppLocalizations.of(context)!.wybd,
              desc: AppLocalizations.of(context)!.wybdd,
              inputFields: DatePickerField(
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date!;
                  });
                },
              ),
              onNextPress: () => _handleNext(context),
            ),
          ),
          if (_showSnackBar)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _snackBarText ?? '',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DatePickerField extends StatefulWidget {
  final Function(DateTime?)? onDateSelected;

  const DatePickerField({super.key, this.onDateSelected});

  @override
  DatePickerFieldState createState() => DatePickerFieldState();
}

class DatePickerFieldState extends State<DatePickerField> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString('selectedBirthday');
    setState(() {
      _selectedDate =
          dateString != null ? DateTime.parse(dateString) : DateTime.now();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedBirthday', picked.toIso8601String());

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: _formatDate(_selectedDate),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: AppLocalizations.of(context)!.selectDate,
          ),
        ),
      ),
    );
  }
}
