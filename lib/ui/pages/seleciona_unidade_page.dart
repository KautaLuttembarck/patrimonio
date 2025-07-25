import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/app_drawer.dart';
import 'package:patrimonio/ui/components/seleciona_unidade_widget.dart';

class SelecionaUnidadePage extends StatefulWidget {
  const SelecionaUnidadePage({super.key});

  @override
  State<SelecionaUnidadePage> createState() => _SelecionaUnidadeState();
}

class _SelecionaUnidadeState extends State<SelecionaUnidadePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Definir Localização")),
        drawer: AppDrawer(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SelecionaUnidadeWidget(),
          ),
        ),
      ),
    );
  }
}
