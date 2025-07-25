import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

final Color _baseTextColor = Color(0xFF1B3C72);
final Color _primaryTextButtonFontColor = Color(0xFF1B3C72);
final Color _reverseTextColor = Colors.white;
final Color _errorColor = Colors.red.shade900;
final Color _baseBackgroundColor = Color(0xFF1B3C72);
final Color _themeSelectedFontColor = Colors.blue;
final Color _baseOverlayColor = Colors.black12;
final double _baseElevation = 5;

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
    },
  ),

  primaryColor: _baseBackgroundColor,

  dividerTheme: DividerThemeData(
    color: Colors.white,
    thickness: 0,
    space: 0,
  ),

  scaffoldBackgroundColor: Colors.white,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: _baseBackgroundColor,
    onPrimary: Colors.white,

    secondary: Colors.blueGrey.shade300,
    onSecondary: Colors.black54,

    error: _errorColor,
    onError: _errorColor,

    surface: Colors.white,
    onSurface: Colors.black54,

    surfaceContainerHighest: Colors.grey,
    surfaceBright: Colors.blue,

    shadow: Colors.black87,

    outline: Colors.grey,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: _baseBackgroundColor,
    foregroundColor: _reverseTextColor,
  ),

  listTileTheme: ListTileThemeData(
    iconColor: _primaryTextButtonFontColor,
    textColor: _primaryTextButtonFontColor,
    tileColor: Colors.white,
    selectedTileColor: Color(0xFFE3F2FD),
    selectedColor: _themeSelectedFontColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    style: ListTileStyle.list,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 4,
    ),
    titleTextStyle: TextStyle(
      color: Colors.black87,
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
    closeIconColor: _reverseTextColor,
    contentTextStyle: TextStyle(
      color: _reverseTextColor,
    ),
    behavior: SnackBarBehavior.floating,
  ),
);
