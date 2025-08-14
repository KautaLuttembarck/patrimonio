import 'package:flutter/material.dart';
import 'package:patrimonio/app/models/patrimonio.dart';

class PatrimonioDetailsPage extends StatelessWidget {
  const PatrimonioDetailsPage({
    required this.patrimonio,
    super.key,
  });

  final Patrimonio patrimonio;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Patrimônio"),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close_fullscreen),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Voltar"),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Icon(
                      patrimonio.situacaoConferencia == "conferido"
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 50,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Patrimônio: ${patrimonio.patrimonio}",
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    patrimonio.nAntigo.isNotEmpty
                                        ? "\nNº Antigo: ${patrimonio.nAntigo}"
                                        : "",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: "\n",
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: "Unidade Administrativa:\n",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "${patrimonio.ua}\n\n"),

                        TextSpan(
                          text: "Localização:\n",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "${patrimonio.localidade}\n\n"),

                        TextSpan(
                          text: "Responsável:\n",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "${patrimonio.responsavel}\n\n"),

                        TextSpan(
                          text: "Decrição:\n",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "${patrimonio.descricao}\n\n"),

                        TextSpan(
                          text: "Situação:\n",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              patrimonio.situacaoConferencia == "conferido"
                                  ? "Patrimônio conferido\n"
                                  : "Conferência pendente\n",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
