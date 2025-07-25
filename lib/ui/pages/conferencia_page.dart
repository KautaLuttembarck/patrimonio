import 'dart:io';

import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/conferencia_widget.dart';
import 'package:patrimonio/ui/components/forms/form_digita_patrimonio_conferencia.dart';

class ConferenciaPage extends StatefulWidget {
  const ConferenciaPage({super.key});

  @override
  State<ConferenciaPage> createState() => _ConferenciaPageState();
}

class _ConferenciaPageState extends State<ConferenciaPage> {
  final ScrollController _scrollController = ScrollController();

  // Controller do campo de pesquisa que será usado no formulário
  final TextEditingController searchFieldController = TextEditingController();

  // Abre uma modal para preencher os dados de patrimônio
  // Se o valor existir, será gravado como conferido no bd
  void _openBottomSheet() {
    Clarity.sendCustomEvent(
      "Abriu a modal de conferência de patrimônio por digitação",
    );
    setState(() {
      searchFieldController.text = "";
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permite altura maior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FormDigitaPatrimonioConferencia(),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _scrollController,
      child: Scaffold(
        appBar: AppBar(
          title: Stack(
            children: [
              Text("Conferência Patrimonial"),
              if (Platform.isAndroid)
                // Barra invisível para fazer o efeito de voltar ao topo
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    },
                    child: SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width - 60,
                      child: Text(""),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _openBottomSheet,
              icon: Icon(Icons.edit_note),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConferenciaWidget(
              searchFieldController: searchFieldController,
              primaryScrollController: _scrollController,
            ),
          ),
        ),
      ),
    );
  }
}
