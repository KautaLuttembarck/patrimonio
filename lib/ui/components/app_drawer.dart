import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/app_drawer_action_list.dart';
import 'package:patrimonio/ui/components/app_drawer_header.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _versao = '';

  Future<void> _carregarVersao() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _versao = info.version;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarVersao();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: Border.all(color: Colors.transparent),
      backgroundColor: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Column(
          spacing: 25,
          children: [
            const SizedBox(height: 20),
            const AppDrawerHeader(),

            const AppDrawerActionList(),
            const Expanded(child: SizedBox()),
            Text(
              "Versão $_versao",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
