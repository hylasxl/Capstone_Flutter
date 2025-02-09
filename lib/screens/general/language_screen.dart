import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "en";

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? "en";
    });
  }

  Future<void> _setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    setState(() {
      _selectedLanguage = languageCode;
    });

    Provider.of<LocaleProvider>(context, listen: false).setLocale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.language),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.languageScreenDescription,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.5)),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.english,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Radio<String>(
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _setLanguage(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.vietnamese,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Radio<String>(
              value: 'vi',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _setLanguage(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.mandarinChinese,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Radio<String>(
              value: 'zh',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _setLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
