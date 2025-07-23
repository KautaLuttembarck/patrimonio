import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double imageOpacity = 0;
  int timeToAnimationInMilliseconds = 1500;
  @override
  void initState() {
    super.initState();
    waitAndShow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Color(0xFFFFFFFF)
              : Color(0xFF1B3C72),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? "assets/images/native_splash/native_splash_logo_light.png"
                  : "assets/images/native_splash/native_splash_logo_dark.png",
              width: 288,
              cacheWidth:
                  (288 * MediaQuery.of(context).devicePixelRatio).round(),
            ),
            Positioned(
              bottom: 70,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: timeToAnimationInMilliseconds),
                opacity: imageOpacity,
                curve: Curves.ease,
                child: Hero(
                  tag:
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? "assets/images/logo_metro_horizontal.png"
                          : "assets/images/logo_metro_horizontal_invertido.png",

                  child: Image.asset(
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? "assets/images/logo_metro_horizontal.png"
                        : "assets/images/logo_metro_horizontal_invertido.png",
                    width: 135,
                    cacheWidth:
                        (135 * MediaQuery.of(context).devicePixelRatio).round(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void waitAndShow() {
    Future.delayed(const Duration(milliseconds: 700)).then((value) {
      setState(() {
        imageOpacity = 1;
      });
      waitAndNextScreen();
    });
  }

  void waitAndNextScreen() {
    Future.delayed(
      Duration(milliseconds: timeToAnimationInMilliseconds + 300),
    ).then((value) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: RouteSettings(
              name: AppRoutes.authPage,
              arguments: "something",
            ),
            pageBuilder:
                (context, animation, secondaryAnimation) => const AuthPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final curvedAnimation = animation.drive(
                CurveTween(curve: Curves.easeInOut),
              );
              return FadeTransition(
                opacity: curvedAnimation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }
}
