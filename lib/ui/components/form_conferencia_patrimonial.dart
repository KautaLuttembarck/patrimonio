import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class FormConferenciaPatrimonial extends StatefulWidget {
  const FormConferenciaPatrimonial({super.key});

  @override
  State<FormConferenciaPatrimonial> createState() =>
      _PatrimonioReaderComponentState();
}

class _PatrimonioReaderComponentState
    extends State<FormConferenciaPatrimonial> {
  bool _isLoading = false;
  late ScrollController _scrollController;

  Future<void> _submitData() async {
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // on success:
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Supostamente foi enviado ao SPMETRODF"),
          backgroundColor: Colors.green,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    setState(() {
      context.read<ConferenciaProvider>().carregarItens();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Realiza a leitura óptica do patrimônio e atualiza o status de conferência
  // do patrimônio lido
  Future<void> lerPatrimonio() async {
    String? patrimonioLido = await SimpleBarcodeScanner.scanBarcode(
      context,
      cancelButtonText: "Cancelar",
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
      lineColor: "#F29100",
    );

    try {
      // Encerra a função em caso de leitura cancelada
      if (patrimonioLido == '-1') {
        return;
      }

      // 98 inicial removido por regra de negócio no BD
      // Conforme informado pela AGPAT, o código 98000000 não deveria existir.
      // Zeros a esquerda removidos da leitura, pois o BD não possui os zeros
      if (patrimonioLido!.substring(0, 2) == "98") {
        patrimonioLido = patrimonioLido.substring(2);
        final int patrimonioInt = int.parse(patrimonioLido);
        patrimonioLido = patrimonioInt.toString();
      } else {
        final int patrimonioInt = int.parse(patrimonioLido);
        patrimonioLido = patrimonioInt.toString();
      }
    } catch (erro) {
      patrimonioLido = "INVÁLIDO";
    }

    bool resultado = false;
    if (mounted) {
      resultado = await context
          .read<ConferenciaProvider>()
          .atualizaStatusConferido("conferido", patrimonioLido);
    }

    if (!resultado) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 8),
            content: RichText(
              text: TextSpan(
                // style: TextStyle(color: Colors.white), // cor padrão
                children: [
                  TextSpan(
                    text: "Patrimônio ($patrimonioLido) não encontrado na ",
                  ),
                  TextSpan(
                    text: "LISTA DE CONFERÊNCIA!",
                    style: TextStyle(fontWeight: FontWeight.bold), // negrito
                  ),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Patrimônio "),
                  TextSpan(
                    text: patrimonioLido,
                    style: TextStyle(fontWeight: FontWeight.bold), // negrito
                  ),
                  TextSpan(text: " marcado como CONFERIDO!"),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.watch<ConferenciaProvider>().tamanhoLista > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              "Patrimônios conferidos: ${context.watch<ConferenciaProvider>().patrimoniosConferidos} / ${context.watch<ConferenciaProvider>().tamanhoLista}",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

        Expanded(
          child: Stack(
            children: [
              Consumer<ConferenciaProvider>(
                builder: (context, provider, child) {
                  final lista = provider.itens;

                  if (lista.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum patrimônio listado para conferência.',
                      ).animate(
                        effects: [
                          FadeEffect(
                            delay: Duration(milliseconds: 100),
                            duration: Duration(milliseconds: 800),
                          ),
                        ],
                      ),
                    );
                  }

                  return RawScrollbar(
                    controller: _scrollController,
                    radius: Radius.circular(10),
                    interactive: true,
                    scrollbarOrientation: ScrollbarOrientation.right,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 60.0),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final patrimonio = lista[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              padding: EdgeInsets.only(right: 30),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              color: Theme.of(context).colorScheme.error,
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                              ),
                            ),
                            key: ValueKey(patrimonio.patrimonio),
                            onDismissed: (_) {
                              context.read<ConferenciaProvider>().removerItem(
                                patrimonio.patrimonio,
                              );
                            },
                            child: Card(
                              child: ListTile(
                                isThreeLine: true,
                                selected:
                                    patrimonio.situacaoConferencia ==
                                    "conferido",
                                tileColor:
                                    patrimonio.situacaoConferencia == "pendente"
                                        ? null
                                        : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHigh,
                                onTap: () {
                                  final String situacao =
                                      patrimonio.situacaoConferencia ==
                                              "pendente"
                                          ? "conferido"
                                          : "pendente";
                                  context
                                      .read<ConferenciaProvider>()
                                      .atualizaStatusConferido(
                                        situacao,
                                        patrimonio.patrimonio,
                                      );
                                  // });
                                },
                                leading:
                                    patrimonio.situacaoConferencia == "pendente"
                                        ? Icon(Icons.check_box_outline_blank)
                                        : Icon(Icons.check_box),
                                title: Text(
                                  patrimonio.nAntigo != ""
                                      ? "Patrimônio: ${patrimonio.patrimonio}\nNº Antigo: ${patrimonio.nAntigo}"
                                      : "Patrimônio: ${patrimonio.patrimonio}",
                                ),
                                subtitle: Text(patrimonio.descricao),
                              ),
                            ),
                          ),
                        );
                      },
                    ).animate(
                      effects: [
                        const FadeEffect(
                          delay: Duration(milliseconds: 100),
                          duration: Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 34,
                right: 10,
                child: FloatingActionButton(
                  onPressed: lerPatrimonio,
                  child: Icon(Icons.barcode_reader, size: 30),
                ),
              ).animate(
                effects: [
                  const FadeEffect(
                    delay: Duration(milliseconds: 100),
                    duration: Duration(milliseconds: 200),
                  ),
                ],
              ),

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
        ),

        ElevatedButton(
          onPressed: _isLoading ? null : _submitData,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    constraints: BoxConstraints(
                      maxWidth: 25,
                      maxHeight: 25,
                      minWidth: 25,
                      minHeight: 25,
                    ),
                  )
                  : Text("Enviar conferência"),
            ],
          ),
        ).animate(
          effects: [
            const FadeEffect(
              delay: Duration(milliseconds: 100),
              duration: Duration(milliseconds: 200),
            ),
          ],
        ),
      ],
    );
  }
}
