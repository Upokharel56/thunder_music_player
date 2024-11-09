import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData myTheme = ThemeData(
  scaffoldBackgroundColor: bgColor,
  primaryColor: whiteColor,
  // Set text theme
  textTheme: getTextTheme(whiteColor),

//Set textButton theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: blackColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      foregroundColor: whiteColor,
    ),
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    color: bgColor,
    iconTheme: IconThemeData(color: whiteColor),
    titleTextStyle:
        TextStyle(color: whiteColor, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  // BottomNavigationBar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: bgColor,
    selectedItemColor: whiteColor,
    unselectedItemColor: whiteColor.withOpacity(0.7),
  ),
  // Icon theme
  iconTheme: const IconThemeData(color: whiteColor),
  // Button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: whiteColor,
    ),
  ),
);

TextTheme getTextTheme(Color themeColor) {
  return TextTheme(
    bodyLarge: TextStyle(color: themeColor),
    bodySmall: TextStyle(color: themeColor),
    bodyMedium:
        TextStyle(color: themeColor), // Replace bodyText2 with bodyMedium
    displayLarge: TextStyle(color: themeColor),
    displaySmall: TextStyle(color: themeColor),
    displayMedium: TextStyle(color: themeColor),
    labelLarge: TextStyle(color: themeColor),
    labelSmall: TextStyle(color: themeColor),
    labelMedium: TextStyle(color: themeColor),
    titleLarge: TextStyle(color: themeColor),
    titleSmall: TextStyle(color: themeColor),
    titleMedium: TextStyle(color: themeColor),
    headlineLarge: TextStyle(color: themeColor),
    headlineSmall: TextStyle(color: themeColor),
    headlineMedium: TextStyle(color: themeColor),
  );
}
