import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF04A9D7);
const Color secondaryColor = Color(0xFFB0E0E6);
const Color errorColor = Color(0xFFE57373);
const Color lightBackgroundColor = Color(0xFFFFFFFF);
const Color darkBackgroundColor = Color(0xFF121212);

MaterialColor createMaterialColor(Color color) {
  List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  Map<int, Color> swatch = <int, Color>{};

  for (int strength in strengths) {
    swatch[strength] = Color.fromRGBO(
      color.red,
      color.green,
      color.blue,
      1.0,
    ).withOpacity(strength / 1000);
  }

  return MaterialColor(color.value, swatch);
}

class AppTheme {
  static final MaterialColor primarySwatch = createMaterialColor(primaryColor);

  static final lightTheme = ThemeData(
      fontFamily: 'SFProDisplay',
      brightness: Brightness.light,
      primarySwatch: primarySwatch,
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: AppBarTheme(
        color: primaryColor,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'SFProDisplay'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        displayLarge: TextStyle(
            color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'SFProDisplay')),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        showUnselectedLabels: false,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ));

  static final darkTheme = ThemeData(
    fontFamily: 'SFProDisplay',
    brightness: Brightness.dark,
    primarySwatch: primarySwatch,
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      color: primarySwatch[700],
      titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProDisplay'),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
      displayLarge: TextStyle(
          color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBackgroundColor,
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(width: 2, color: primaryColor)),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: Colors.black,
    ),
    snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'SFProDisplay',
            color: Colors.black)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showUnselectedLabels: false,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
