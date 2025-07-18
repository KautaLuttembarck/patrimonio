import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    waitAndShow();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
    super.dispose();
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
                          ? "assets/images/logo_metro_horizontal_600x209.png"
                          : "assets/images/logo_metro_horizontal_invertido_600x209.png",

                  child: Image.asset(
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? "assets/images/logo_metro_horizontal_600x209.png"
                        : "assets/images/logo_metro_horizontal_invertido_600x209.png",
                    width: 135,
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
