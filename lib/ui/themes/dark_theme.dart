import 'package:flutter/material.dart';

final Color _baseTextColor = Colors.white;
final Color _primaryTextButtonFontColor = Colors.white;
final Color _reverseTextColor = Colors.white;
final Color _errorColor = Colors.red.shade900;
final Color _baseBackgroundColor = Color(0xFF1B3C72);
final Color _themeFontColor = Color(0xFF1B3C72);
final Color _baseOverlayColor = Colors.white38;
final double _baseElevation = 5;

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  primaryColor: _baseBackgroundColor,

  scaffoldBackgroundColor: Colors.black,

  colorScheme: ColorScheme(
    brightness: Brightness.dark,

    primary: _baseBackgroundColor,
    onPrimary: Colors.white,

    secondary: Colors.blueGrey.shade300,
    onSecondary: Colors.black54,

    error: _errorColor,
    onError: _errorColor,

    surface: Colors.grey[800]!,
    onSurface: Colors.white,

    surfaceContainerHighest: Colors.grey,
    surfaceBright: Colors.blue,

    shadow: Colors.white24,

    outline: Colors.white,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: _baseBackgroundColor,
    foregroundColor: _reverseTextColor,
  ),

  listTileTheme: ListTileThemeData(
    iconColor: _baseTextColor,
    textColor: _baseTextColor,
    tileColor: Colors.grey[800]!,
    selectedTileColor: Color(0xFFE3F2FD),
    selectedColor: _themeFontColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    style: ListTileStyle.list,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 4,
    ),
    titleTextStyle: TextStyle(
      color: _baseTextColor,
      fontWeight: FontWeight.bold,
    ),
  ),

  textTheme: TextTheme(
    titleSmall: TextStyle(
      color: _baseTextColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: _baseTextColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: _baseTextColor,
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),

    bodySmall: TextStyle(
      color: _baseTextColor,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: _baseTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      color: _baseTextColor,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),

    labelMedium: TextStyle(
      color: _baseBackgroundColor,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.white.withAlpha(200),
    foregroundColor: _baseBackgroundColor, // Cor do ícone
    elevation: _baseElevation,
    shape: CircleBorder(
      side: BorderSide(
        color: _baseBackgroundColor, // Cor da borda
        width: 2,
      ),
    ),
    sizeConstraints: BoxConstraints(minWidth: 70, minHeight: 70),
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: _baseBackgroundColor,
    circularTrackColor: Color.fromRGBO(0, 0, 0, 0.0),
    linearTrackColor: Color.fromRGBO(0, 0, 0, 0.0),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStatePropertyAll(_baseOverlayColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(_baseBackgroundColor),
      foregroundColor: WidgetStatePropertyAll(_reverseTextColor),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(_primaryTextButtonFontColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      overlayColor: WidgetStatePropertyAll(_baseOverlayColor),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(_primaryTextButtonFontColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      overlayColor: WidgetStatePropertyAll(_baseOverlayColor),
    ),
  ),

  cardTheme: CardThemeData(
    elevation: _baseElevation,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: Colors.grey.withAlpha(40), // Cor da borda
        width: 1, // Largura da borda
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    showCloseIcon: true,
    closeIconColor: _baseTextColor,
    contentTextStyle: TextStyle(
      color: _baseTextColor,
    ),
    behavior: SnackBarBehavior.floating,
  ),
);
