import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  late String _theme; // Track the current theme

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load the theme from ThemeProvider and update the state
  void _loadTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _theme = themeProvider.currentTheme == ThemeMode.dark ? 'dark' : 'light';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.theme),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.themeScreenDescription,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.5),
              ),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.lightMode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Radio<String>(
              value: 'light',
              groupValue: _theme,
              onChanged: (value) {
                if (value != null && value != _theme) {
                  themeProvider.setLightMode();
                  setState(() {
                    _theme = 'light';
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.darkMode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Radio<String>(
              value: 'dark',
              groupValue: _theme,
              onChanged: (value) {
                if (value != null && value != _theme) {
                  themeProvider.setDarkMode();
                  setState(() {
                    _theme = 'dark';
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
