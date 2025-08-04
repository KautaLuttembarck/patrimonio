import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';

import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/utils/help_dialog.dart' as help_dialog;

class ConferenciaWidget extends StatefulWidget {
  const ConferenciaWidget({
    super.key,
    required this.searchFieldController,
    required this.primaryScrollController,
  });
  final TextEditingController searchFieldController;
  final ScrollController primaryScrollController;
  @override
  State<ConferenciaWidget> createState() => _PatrimonioReaderComponentState();
}

class _PatrimonioReaderComponentState extends State<ConferenciaWidget> {
  bool _isLoading = false;
  bool _hasVibrator = false;
  final FocusNode _searchFieldFocusNode = FocusNode();
  bool _searchFieldFocused = false;
  final GlobalKey _stackKey = GlobalKey();
  Offset _buttonPosition = Offset(3000, 3000);
  bool _showCongratulations = false;
  late int _tamanhoDaLista;
  late int _patrimoniosConferidos;
  late final Widget _botaoLeituraOptica;

  @override
  void initState() {
    super.initState();
    Vibration.hasVibrator().then((value) => _hasVibrator = value);

    _botaoLeituraOptica = FloatingActionButton(
      onPressed: _lerPatrimonio,
      child: const Icon(Icons.barcode_reader, size: 30),
    );

    _searchFieldFocusNode.addListener(() {
      setState(() => _searchFieldFocused = _searchFieldFocusNode.hasFocus);
    });

    // função para ser executada após a renderização inicial do frame, permitindo
    // controlar o posicionamento do FAB.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _stackKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;

      const double buttonSize = 56;
      const double padding = 16;

      setState(() {
        _buttonPosition = Offset(
          size.width - buttonSize - padding,
          size.height - buttonSize - padding - 70,
        );
      });
    });

    setState(() {
      context.read<ConferenciaProvider>().carregarItens();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Quantidade de patrimonios conferidos
    final conferidos =
        context.watch<ConferenciaProvider>().patrimoniosConferidos;

    // Quantidade de patrimônios para conferir
    final total = context.watch<ConferenciaProvider>().tamanhoLista;

    // Verifica se tudo foi conferido para mostrar a animação
    if (conferidos == total) {
      setState(() => _showCongratulations = true);
    } else {
      setState(() => _showCongratulations = false);
    }

    // Atualiza o tamanho e a conferência da lista
    setState(() {
      _tamanhoDaLista = total;
      _patrimoniosConferidos = conferidos;
    });
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();
    super.dispose();
  }

  // Envia os dados da conferência ao SPMETRODF
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
                  Navigator.of(ctx).pop(false); // Retorna `false`
                },
                child: Text("Voltar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text(
                  "Finalizar",
                ),
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

  // Remove o patrimonio ao executar o dismiss
  void _dismissPatrimonio(Patrimonio patrimonio) async {
    if (_hasVibrator) {
      Vibration.vibrate(duration: 50);
    }
    final bool success = await context.read<ConferenciaProvider>().removerItem(
      patrimonio,
    );
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Erro ao remover o patrimônio!"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Controla o drag do botão de leitura óptica de patrimônios
  void _botaoLeituraOpticaDragController(DraggableDetails details) {
    // Obtém as dimensões do stack na tela
    final RenderBox renderBox =
        _stackKey.currentContext!.findRenderObject() as RenderBox;

    // Separa as coordenadas do stack
    // Subtrai das coordenadas obtidas o tamanho do botão e do padding interno
    final double maxX = renderBox.size.width - 70;
    final double maxY = renderBox.size.height - 70;

    final Offset localOffset = renderBox.globalToLocal(
      details.offset,
    );

    final double dx = localOffset.dx.clamp(0.0, maxX);
    final double dy = localOffset.dy.clamp(0.0, maxY);

    setState(() {
      _buttonPosition = Offset(dx, dy);
    });
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
      "Marcou um patrimonio como $situacao por toque",
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
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Voltar"),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Remover"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _searchFieldFocusNode.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        key: _stackKey,
        children: [
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_tamanhoDaLista > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Patrimônios conferidos: "
                              "$_patrimoniosConferidos / $_tamanhoDaLista",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_showCongratulations)
                                  Lottie.asset(
                                    'assets/lotties/success_check_green_transparent.json',
                                    height: 25,
                                    repeat: false,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end:
                              context
                                  .watch<ConferenciaProvider>()
                                  .patrimoniosConferidos /
                              context.watch<ConferenciaProvider>().tamanhoLista,
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(15),
                            minHeight: 8,
                            // backgroundColor:
                            //     Theme.of(
                            //       context,
                            //     ).colorScheme.onPrimary,
                            value: value,
                          );
                        },
                      ),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        width: double.infinity,
                        child: TextField(
                          autocorrect: false,
                          decoration: InputDecoration(
                            suffixIcon: AnimatedSwitcher(
                              switchInCurve: Curves.easeInOutBack,
                              duration: Duration(milliseconds: 200),
                              child:
                                  widget.searchFieldController.text != ""
                                      ? IconButton(
                                        key: ValueKey("Limpar"),
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          widget.searchFieldController.text =
                                              "";
                                          context
                                              .read<ConferenciaProvider>()
                                              .filtrarItens(
                                                "",
                                              );
                                        },
                                      )
                                      : Icon(
                                        Icons.search,
                                        key: ValueKey("search"),
                                      ),
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            label: Text("Pesquisar"),

                            labelStyle: Theme.of(context).textTheme.bodyLarge,

                            contentPadding: EdgeInsets.all(
                              12,
                            ), // (opcional) ajuste de padding
                          ),
                          controller: widget.searchFieldController,
                          focusNode: _searchFieldFocusNode,
                          style: Theme.of(context).textTheme.bodyLarge,
                          spellCheckConfiguration:
                              SpellCheckConfiguration.disabled(),
                          onChanged: (valorBuscado) {
                            context.read<ConferenciaProvider>().filtrarItens(
                              valorBuscado,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Stack(
                  children: [
                    Consumer<ConferenciaProvider>(
                      builder: (context, provider, child) {
                        late List<Patrimonio> lista;
                        if (_searchFieldFocused ||
                            widget.searchFieldController.text != "") {
                          lista = provider.filteredItens;
                        } else {
                          lista = provider.itens;
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              lista.isEmpty
                                  ? Center(
                                    key: const ValueKey("ListaVazia"),
                                    child: Text(
                                      widget.searchFieldController.text == ""
                                          ? 'Nenhum patrimônio listado para conferência.'
                                          : "Nenhum patrimônio encontrado com o termo pesquisado.",
                                      textAlign: TextAlign.center,
                                    ).animate(
                                      effects: const [
                                        FadeEffect(
                                          delay: Duration(milliseconds: 100),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      ],
                                    ),
                                  )
                                  : RawScrollbar(
                                    key: const ValueKey("ListaCheia"),
                                    controller: widget.primaryScrollController,
                                    radius: const Radius.circular(10),
                                    interactive: true,
                                    scrollbarOrientation:
                                        ScrollbarOrientation.right,
                                    child: ListView.builder(
                                      controller:
                                          widget.primaryScrollController,
                                      padding: const EdgeInsets.only(
                                        bottom: 60.0,
                                      ),
                                      itemCount: lista.length,
                                      itemBuilder: (context, index) {
                                        final patrimonio = lista[index];
                                        return Dismissible(
                                          direction:
                                              DismissDirection.endToStart,
                                          background: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ),
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            ),
                                            padding: const EdgeInsets.only(
                                              right: 30,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 11,
                                            ),

                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.white,
                                                      size: 35,
                                                    ),
                                                    Text(
                                                      "Arraste para\napagar",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ).animate(
                                              effects: const [
                                                ScaleEffect(
                                                  curve: Curves.easeOutQuart,
                                                  duration: Duration(
                                                    milliseconds: 600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          key: ValueKey(patrimonio.patrimonio),

                                          confirmDismiss: (_) async {
                                            return await _confirmaDismiss(
                                              patrimonio.patrimonio,
                                            );
                                          },

                                          onDismissed:
                                              (_) => _dismissPatrimonio(
                                                patrimonio,
                                              ),
                                          child: Card(
                                            elevation: 5,
                                            margin: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            child: ListTile(
                                              onLongPress:
                                                  () => help_dialog
                                                      .showDetalhesPatrimonio(
                                                        context,
                                                        patrimonio,
                                                      ),
                                              isThreeLine: true,
                                              selected:
                                                  patrimonio
                                                      .situacaoConferencia ==
                                                  "conferido",
                                              tileColor:
                                                  patrimonio.situacaoConferencia ==
                                                          "pendente"
                                                      ? null
                                                      : Theme.of(
                                                            context,
                                                          )
                                                          .colorScheme
                                                          .surfaceContainerHigh,
                                              leading:
                                                  patrimonio.situacaoConferencia ==
                                                          "pendente"
                                                      ? const Icon(
                                                        Icons
                                                            .check_box_outline_blank,
                                                      )
                                                      : const Icon(
                                                        Icons.check_box,
                                                      ),
                                              title: Text(
                                                patrimonio.nAntigo.isNotEmpty
                                                    ? "Patrimônio: ${patrimonio.patrimonio}\nNº Antigo: ${patrimonio.nAntigo}"
                                                    : "Patrimônio: ${patrimonio.patrimonio}",
                                              ),
                                              subtitle: Text(
                                                patrimonio.descricao,
                                              ),
                                              onTap:
                                                  () => _marcaComoConferido(
                                                    patrimonio,
                                                  ),
                                            ),
                                          ).animate(
                                            target:
                                                patrimonio.situacaoConferencia ==
                                                        'conferido'
                                                    ? 1
                                                    : 0,
                                            effects: const [
                                              ShakeEffect(
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                rotation: 0.01,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).animate(
                                      effects: const [
                                        FadeEffect(
                                          delay: Duration(milliseconds: 100),
                                          duration: Duration(milliseconds: 300),
                                        ),
                                      ],
                                    ),
                                  ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              if (_tamanhoDaLista != 0 &&
                  !_searchFieldFocused &&
                  widget.searchFieldController.text == "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading ||
                                context
                                        .watch<ConferenciaProvider>()
                                        .tamanhoLista ==
                                    0)
                            ? null
                            : _submitData,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? CircularProgressIndicator(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              constraints: const BoxConstraints(
                                maxWidth: 25,
                                maxHeight: 25,
                                minWidth: 25,
                                minHeight: 25,
                              ),
                            )
                            : const Text("Enviar conferência"),
                      ],
                    ),
                  ).animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 100),
                        duration: Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Botão pro leitor óptico de patrimônios
          Positioned(
            left: _buttonPosition.dx,
            top: _buttonPosition.dy,
            child: Draggable(
              childWhenDragging: const SizedBox(),
              feedback: _botaoLeituraOptica,
              onDragEnd: _botaoLeituraOpticaDragController,
              child: _botaoLeituraOptica,
            ),
          ).animate(
            target:
                (_tamanhoDaLista != 0 &&
                        !_searchFieldFocused &&
                        widget.searchFieldController.text.isEmpty)
                    ? 1
                    : 0,
            effects: const [
              ScaleEffect(
                curve: Curves.easeInOutBack,
                delay: Duration(milliseconds: 100),
                duration: Duration(milliseconds: 300),
              ),
            ],
          ),

          if (_showCongratulations && _tamanhoDaLista != 0)
            Positioned(
              bottom: 0,
              child: IgnorePointer(
                ignoring: true,
                child: Lottie.asset(
                  'assets/lotties/congratulation.json',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  repeat: false,
                  fit: BoxFit.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
