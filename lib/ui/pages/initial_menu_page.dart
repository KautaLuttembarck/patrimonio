import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/initial_menu_page_action_list.dart';
import 'package:patrimonio/ui/components/app_drawer.dart';

class InitialMenuPage extends StatelessWidget {
  const InitialMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/logo_metro_horizontal_invertido.png",
          height: 50,
          cacheHeight: (50 * MediaQuery.of(context).devicePixelRatio).round(),
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: InitialMenuPageActionList(),
          ),
        ),
      ),
    );
  }
}
