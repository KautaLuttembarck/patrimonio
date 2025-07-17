import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/form_conferencia_patrimonial.dart';
import 'package:patrimonio/ui/components/form_digita_patrimonio_conferencia.dart';

class ConferenciaPage extends StatefulWidget {
  const ConferenciaPage({super.key});

  @override
  State<ConferenciaPage> createState() => _ConferenciaPageState();
}

class _ConferenciaPageState extends State<ConferenciaPage> {
  // Abre uma modal para preencher os dados de patrimônio
  // Se o valor existir, será gravado como conferido no bd
  void _openBottomSheet() {
    Clarity.sendCustomEvent(
      "Abriu a modal de conferência de patrimônio por digitação",
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conferência Patrimonial"),
        actions: [
          IconButton(onPressed: _openBottomSheet, icon: Icon(Icons.edit_note)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: const FormConferenciaPatrimonial(),
        ),
      ),
    );
  }
}
