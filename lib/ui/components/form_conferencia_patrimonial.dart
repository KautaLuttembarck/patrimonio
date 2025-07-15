import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';

import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:vibration/vibration.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/utils/help_dialog.dart' as help_dialog;

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
  bool _hasVibrator = false;

  Future<void> _submitData() async {
    FocusScope.of(context).unfocus();

    final continuar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: Icon(Icons.cloud_upload_outlined, size: 42),
            iconColor: Theme.of(context).primaryColor,
            title: Text("Finalizar a conferência?"),
            content: Text(
              "Deseja enviar o resultado da conferência ao SPMETRODF"
              " e finalizar o processo?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true); // Retorna `true`
                },
                child: Text(
                  "Finalizar",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false); // Retorna `false`
                },
                child: Text("Voltar"),
              ),
            ],
          ),
    );

    if (continuar == true) {
      setState(() => _isLoading = true);
      bool? result = true;
      // on success:

      if (result) {
        Clarity.sendCustomEvent(
          "Enviou a conferência patrimonial para o SPMETRODF",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Dados da conferência patrimonial encaminhados ao SPMETRODF",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) {
          await context.read<ConferenciaProvider>().limparConferencia();
        }
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.menuInicial,
            (Route<dynamic> route) => false,
          );
        }
      }
    } else {
      // Usuário cancelou ou clicou fora do dialog
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Vibration.hasVibrator().then((value) => _hasVibrator = value);
    setState(() {
      context.read<ConferenciaProvider>().carregarItens();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Realiza a leitura óptica do patrimônio, atualiza o status de conferência
  // para lido e registra a ação no Microsoft Clarity
  Future<void> _lerPatrimonio() async {
    String? patrimonioLido = await SimpleBarcodeScanner.scanBarcode(
      context,
      cancelButtonText: "Cancelar",
      isShowFlashIcon: true,
      // delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
      lineColor: "#F29100",
    );

    try {
      // Encerra a função em caso de leitura cancelada
      if (patrimonioLido == '-1') {
        Clarity.sendCustomEvent("Leitura óptica cancelada pelo usuário");
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
      if (patrimonioLido != "INVÁLIDO") {
        Clarity.sendCustomEvent(
          "Patrimônio lido não encontrado na lista de conferência",
        );
      } else {
        Clarity.sendCustomEvent(
          "Leitura óptica retornou um patrimônio INVÁLIDO",
        );
      }
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
      Clarity.sendCustomEvent("Conferiu patrimonio por leitura óptica");
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

  // Registra o status de conferência do patrimônio e envia a ação para o
  // Microsoft Clarity
  Future<void> _marcaComoConferido(Patrimonio patrimonio) async {
    final String situacao =
        patrimonio.situacaoConferencia == "pendente" ? "conferido" : "pendente";

    await context.read<ConferenciaProvider>().atualizaStatusConferido(
      situacao,
      patrimonio.patrimonio,
    );
    if (_hasVibrator) {
      Vibration.vibrate(duration: 50);
    }
    Clarity.sendCustomEvent(
      "Marcom um patrimonio como $situacao por toque",
    );
  }

  Future<bool> _confirmaDismiss(String patrimonio) async {
    return await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                icon: Icon(Icons.delete_forever, size: 42),
                iconColor: Theme.of(context).colorScheme.error,
                title: Text(
                  "Remover o patrimônio $patrimonio da lista de conferência?",
                ),

                actions: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Remover"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Voltar"),
                  ),
                ],
              ),
        ) ??
        false;
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Patrimônios conferidos: "
                  "${context.watch<ConferenciaProvider>().patrimoniosConferidos} "
                  "/ ${context.watch<ConferenciaProvider>().tamanhoLista}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                if (context
                        .watch<ConferenciaProvider>()
                        .patrimoniosConferidos ==
                    context.watch<ConferenciaProvider>().tamanhoLista)
                  Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 23,
                  ).animate(
                    delay: Duration(milliseconds: 50),
                    effects: [
                      ScaleEffect(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                      ),
                    ],
                  ),
              ],
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
                        return Dismissible(
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
                          confirmDismiss: (_) async {
                            return await _confirmaDismiss(
                              patrimonio.patrimonio,
                            );
                          },
                          onDismissed: (_) async {
                            if (_hasVibrator) {
                              Vibration.vibrate(duration: 50);
                            }
                            final bool success = await context
                                .read<ConferenciaProvider>()
                                .removerItem(patrimonio, index);
                            if (!success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Erro ao remover o patrimônio!",
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              child: ListTile(
                                onLongPress:
                                    () => help_dialog.showDetalhesPatrimonio(
                                      context,
                                      patrimonio,
                                    ),
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
                                onTap: () => _marcaComoConferido(patrimonio),
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
              if (context.watch<ConferenciaProvider>().tamanhoLista != 0)
                Positioned(
                  bottom: 34,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: _lerPatrimonio,
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
        if (context.watch<ConferenciaProvider>().tamanhoLista != 0)
          ElevatedButton(
            onPressed:
                (_isLoading ||
                        context.watch<ConferenciaProvider>().tamanhoLista == 0)
                    ? null
                    : _submitData,
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
