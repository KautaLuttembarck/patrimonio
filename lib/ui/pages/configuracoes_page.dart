import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/app_drawer.dart';
import 'package:patrimonio/ui/components/configuracoes_widget.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: const ConfiguracoesWidget(),
        ),
      ),
    );
  }
}
