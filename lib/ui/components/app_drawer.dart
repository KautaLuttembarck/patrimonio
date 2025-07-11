import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/app_drawer_action_list.dart';
import 'package:patrimonio/ui/components/app_drawer_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: Border.all(color: Colors.black.withAlpha(0)),
      backgroundColor: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Column(
          spacing: 25,
          children: [
            const SizedBox(height: 20),
            const AppDrawerHeader(),

            const AppDrawerActionList(),
            Expanded(child: SizedBox()),
            Text(
              "Versão: 1.0",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
