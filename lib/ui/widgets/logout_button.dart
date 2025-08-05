import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patrimonio/app/providers/user_provider.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() {
      context.read<UserProvider>().registraLogout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.authPage,
        (Route<dynamic> route) => false,
      );
    }

    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
      onPressed: logout,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              const SizedBox(width: 0),
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              Text(
                "Sair do Aplicativo",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}
