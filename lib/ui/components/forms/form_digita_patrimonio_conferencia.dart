import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:clarity_flutter/clarity_flutter.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/services/local_database_service.dart';

class FormDigitaPatrimonioConferencia extends StatefulWidget {
  const FormDigitaPatrimonioConferencia({super.key});

  @override
  State<FormDigitaPatrimonioConferencia> createState() =>
      _FormDigitaPatrimonioConferenciaState();
}

class _FormDigitaPatrimonioConferenciaState
    extends State<FormDigitaPatrimonioConferencia> {
  final _formKey = GlobalKey<FormState>();
  final _patrimonioController = TextEditingController();
  final _patrimonioFocus = FocusNode();
  bool _useNAntigo = false;
  static const double _tamanhoMaximo = 0.90;
  static const int _alturaElementos = 350; // Altura dos elementos apresentados

  @override
  void initState() {
    super.initState();
    _patrimonioFocus.requestFocus();
  }

  void _showAdicionaPatrimonioDialog(Patrimonio patrimonio) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: Icon(Icons.wrong_location, size: 42),
            iconColor: Theme.of(context).colorScheme.primary,
            title: Text("Patrimônio não listado"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Text(
                  "O Patrimônio ${patrimonio.patrimonio} ${patrimonio.nAntigo.isEmpty ? "" : "(número antigo ${patrimonio.nAntigo})"} não está na lista de conferência "
                  "e possui as seguintes informações associadas:",
                  textAlign: TextAlign.justify,
                ),
                Flexible(
                  child: Card(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: RichText(
                          text: TextSpan(
                            text: "",
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: "Unidade Administrativa: ",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${patrimonio.ua}\n"),

                              TextSpan(
                                text: "Localização: ",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${patrimonio.localidade}\n\n"),

                              TextSpan(
                                text: "Responsável: ",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${patrimonio.responsavel}\n\n"),

                              TextSpan(
                                text: "Decrição: ",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: patrimonio.descricao),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Text(
                  "Deseja adiciona-lo à lista de conferência?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Voltar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await context.read<ConferenciaProvider>().adicionarItem(
                    patrimonio,
                  );
                  if (mounted) await _atualizaPatrimonio();
                  if (mounted) Navigator.of(context).pop();
                },
                child: Text("Adicionar"),
              ),
            ],
          ),
    );
  }

  Future<List<Patrimonio>> _obtemPatrimonioForaDaConferencia(
    String patrimonioInformado,
  ) async {
    late final String patrimonio;
    try {
      patrimonio = int.parse(patrimonioInformado.trim()).toString();
    } catch (e) {
      patrimonio = "";
    }

    late final List<Patrimonio> resultado;
    if (!_useNAntigo) {
      resultado = await context.read<LocalDatabaseService>().getPatrimonio(
        patrimonio,
      );
    } else {
      resultado = await context
          .read<LocalDatabaseService>()
          .getPatrimonioAntigo(patrimonio);
    }
    return resultado;
  }

  Future<void> _atualizaPatrimonio() async {
    late final bool resultado;
    if (_formKey.currentState!.validate()) {
      if (!_useNAntigo) {
        resultado = await context
            .read<ConferenciaProvider>()
            .atualizaStatusConferido("conferido", _patrimonioController.text);
      } else {
        resultado = await context
            .read<ConferenciaProvider>()
            .atualizaStatusConferidoNumeroAntigo(
              "conferido",
              _patrimonioController.text,
            );
      }
      if (resultado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Patrimônio ${_useNAntigo ? "Antigo" : ""} ${_patrimonioController.text} marcado como conferido!",
              ),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
        if (_useNAntigo) {
          Clarity.sendCustomEvent(
            "Conferiu patrimonio digitando o número ANTIGO",
          );
        } else {
          Clarity.sendCustomEvent(
            "Conferiu patrimonio digitando o número ATUAL",
          );
        }
        _patrimonioController.text = "";
        return;
      } else {
        final List<Patrimonio> patrimonioImportado =
            await _obtemPatrimonioForaDaConferencia(_patrimonioController.text);
        if (patrimonioImportado.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Patrimônio ${_patrimonioController.text} não encontrado em NENHUMA LISTA!",
                ),
                duration: Duration(seconds: 5),
                showCloseIcon: true,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            return;
          }
        } else {
          _showAdicionaPatrimonioDialog(patrimonioImportado[0]);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double tamanhoMinimo =
        _alturaElementos / MediaQuery.of(context).size.height;

    // Aplica um percentual mínimo com base no valor ocupado pelo teclado
    // para acompanhar o tamanho de tela efetivamente disponível
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      tamanhoMinimo =
          (MediaQuery.of(context).viewInsets.bottom + 300) /
          MediaQuery.of(context).size.height;
    }

    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      initialChildSize: tamanhoMinimo,
      minChildSize: 0.01,
      maxChildSize: _tamanhoMaximo,
      builder: (context, scrollController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Container(
            padding: EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                // puxador da tela
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Informar a conferência',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 30,
                    children: [
                      Column(
                        spacing: 0,
                        children: [
                          TextFormField(
                            controller: _patrimonioController,
                            focusNode: _patrimonioFocus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              labelText: 'Número do patrimônio',
                              labelStyle: Theme.of(context).textTheme.bodyLarge,
                              suffixIcon: Icon(Icons.numbers_sharp),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (patrimonioInformado) {
                              String limpa = patrimonioInformado.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              _patrimonioController.value = TextEditingValue(
                                text: limpa,
                                selection: TextSelection.collapsed(
                                  offset: limpa.length,
                                ),
                              );
                            },
                            onFieldSubmitted: (_) => _atualizaPatrimonio(),

                            validator: (patrimonioInformado) {
                              String patrimonio = patrimonioInformado ?? "";
                              if (patrimonio.isEmpty) {
                                return "Preenchimento obrigatório!";
                              }
                              return null;
                            },
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Checkbox(
                                visualDensity: VisualDensity.compact,
                                value: _useNAntigo,
                                onChanged: (value) {
                                  setState(() {
                                    _useNAntigo = value!;
                                  });
                                },
                              ),
                              Text("Número patrimonial antigo"),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _atualizaPatrimonio,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("Marcar como conferido")],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
