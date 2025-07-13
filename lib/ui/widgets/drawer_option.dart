import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';

class DrawerOption extends StatelessWidget {
  final bool popOnNavigate;
  final String route;
  final String buttonText;
  final IconData icon;
  final disabledColor = Colors.white60;
  final void Function(BuildContext context)? helperFunction;

  const DrawerOption({
    this.popOnNavigate = true,
    required this.route,
    required this.icon,
    required this.buttonText,
    this.helperFunction,
    super.key,
  });

  void _navigate(BuildContext ctx) {
    if (popOnNavigate) {
      Clarity.sendCustomEvent("Acionou $route usando o menu principal");
      Navigator.of(ctx).pushReplacementNamed(route);
    } else {
      Clarity.sendCustomEvent("Acionou $route usando o menu principal");
      Navigator.of(ctx).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
      onLongPress: () {
        if (helperFunction != null) {
          helperFunction!(context);
        }
      },
      onPressed:
          ModalRoute.of(context)?.settings.name == route
              ? null
              : () => _navigate(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Icon(
                icon,
                color:
                    ModalRoute.of(context)?.settings.name == route
                        ? disabledColor
                        : Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                buttonText,
                style: TextStyle(
                  color:
                      ModalRoute.of(context)?.settings.name == route
                          ? disabledColor
                          : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color:
                ModalRoute.of(context)?.settings.name == route
                    ? disabledColor
                    : Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
