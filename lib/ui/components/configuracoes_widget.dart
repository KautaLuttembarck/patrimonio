import 'package:flutter/material.dart';
import 'package:patrimonio/app/services/sp_database_service.dart';
import 'package:patrimonio/app/services/local_database_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class ConfiguracoesWidget extends StatefulWidget {
  const ConfiguracoesWidget({super.key});

  @override
  State<ConfiguracoesWidget> createState() => _ConfiguracoesWidgetState();
}

class _ConfiguracoesWidgetState extends State<ConfiguracoesWidget> {
  bool _downloadingData = false;
  bool _conferenciaEmAndamento = false;
  double _downloadProgress = 0;
  String? _dataAtualizacao;
  String _situacaoTransferencia = "Transferindo dados patrimoniais";

  void _obtemDadosPatrimoniais() async {
    setState(() {
      _situacaoTransferencia = "Transferindo dados patrimoniais";
      _downloadingData = true;
      _downloadProgress = 0;
    });
    bool result = await SpDatabaseService().getListaPatrimonios(context);
    if (mounted) {
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar os dados de patrimonio!"),
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _situacaoTransferencia = "Falha ao transferir os dados!";
          _downloadProgress = 0;
        });
      } else {
        Clarity.sendCustomEvent(
          "Obteve os dados patrimoniais na tela de Configuração",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dados salvos com sucesso!"),
            backgroundColor: Colors.green,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _situacaoTransferencia = "Transferência realizada!";
          _downloadProgress = 1;
        });
        context.read<LocalDatabaseService>().obterUltimaCarga().then((
          ultimaCarga,
        ) {
          if (ultimaCarga != null && ultimaCarga.isNotEmpty) {
            DateTime data = DateTime.parse(ultimaCarga['realizado_em']);
            setState(() {
              _dataAtualizacao = DateFormat(
                "dd/MM/yyyy HH:mm",
                "pt_BR",
              ).format(data);
            });
          } else {
            setState(() {
              _dataAtualizacao = null;
            });
          }
        });
      }
    }
    if (mounted) {
      setState(() {
        _downloadingData = false;
      });
    }
  }

  void _limparBancoDeDados() async {
    final bool result;
    result =
        await context.read<LocalDatabaseService>().esvaziaTabelaPatrimonios();
    if (mounted) {
      await context.read<LocalDatabaseService>().limparTabelaConferencia();
    }
    if (result) {
      setState(() {
        _dataAtualizacao = null;
        _downloadProgress = 0;
      });
      if (mounted) {
        context.read<ConferenciaProvider>().carregarItens();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dados removidos"),
            backgroundColor: Colors.green,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _limparBancoDeDadosConferencias() async {
    await context.read<ConferenciaProvider>().limparConferencia();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conferência Patrimonial Cancelada!"),
          backgroundColor: Colors.green,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<LocalDatabaseService>().obterUltimaCarga().then((ultimaCarga) {
      if (ultimaCarga != null && ultimaCarga.isNotEmpty) {
        DateTime data = DateTime.parse(ultimaCarga['realizado_em']);
        setState(() {
          _dataAtualizacao = DateFormat(
            "dd/MM/yyyy HH:mm",
            "pt_BR",
          ).format(data);
        });
      } else {
        setState(() {
          _dataAtualizacao = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _conferenciaEmAndamento =
          context.watch<ConferenciaProvider>().tamanhoLista > 0;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 18,
      children: [
        GestureDetector(
          onLongPress: () async {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 50);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("🏆🏆🏆"),
                      Text(
                        "Desenvolvido pela PGSIS!",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text("🏆🏆🏆"),
                    ],
                  ),
                  showCloseIcon: false,
                ),
              );
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              // color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(80),
              border: BoxBorder.fromBorderSide(
                BorderSide(
                  width: 3,
                  color: Colors.blueGrey.shade500,
                ),
              ),
            ),
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
              size: 90,
            ),
          ),
        ),

        Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.6, // Largura da borda
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          // elevation: 15,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _dataAtualizacao == null ? 20 : 45,
                  width: MediaQuery.of(context).size.width,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          _dataAtualizacao != null
                              ? "Dados patrimoniais atualizados em\n"
                              : "Dados patrimoniais ausentes!",
                      style:
                          _dataAtualizacao != null
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text:
                              _dataAtualizacao != null
                                  ? "$_dataAtualizacao"
                                  : "",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height:
                      (_downloadingData || (_downloadProgress > 0)) ? 60 : 0,
                  child:
                      (_downloadingData || (_downloadProgress > 0))
                          ? Column(
                            children: [
                              SizedBox(height: 20),
                              Column(
                                spacing: 10,
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child:
                                        _situacaoTransferencia ==
                                                "Transferindo dados patrimoniais"
                                            ? Text(
                                              key: ValueKey("Transferindo"),
                                              _situacaoTransferencia,
                                            )
                                            : Text(
                                              key: ValueKey("Transferido"),
                                              _situacaoTransferencia,
                                            ),
                                  ),
                                  LinearProgressIndicator(
                                    value: _downloadProgress > 0 ? 1 : null,
                                    borderRadius: BorderRadius.circular(15),
                                    minHeight: 7,
                                  ),
                                ],
                              ),
                            ],
                          ).animate(
                            delay: Duration(milliseconds: 300),
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 500),
                              ),
                            ],
                          )
                          : SizedBox(
                            height: 0,
                          ),
                ),
              ],
            ),
          ),
        ).animate(
          effects: [
            ShakeEffect(
              delay: Duration(milliseconds: 250),
              duration: Duration(milliseconds: 300),
              rotation: 0.04,
            ),
            FadeEffect(
              delay: Duration(
                milliseconds: 30, // * index,
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),

        ElevatedButton.icon(
          onPressed:
              ((_downloadingData || (_downloadProgress > 0))
                  ? null
                  : _obtemDadosPatrimoniais),
          icon: Icon(Icons.security_update),
          label: Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Baixar Patrimônios")],
          ),
        ),

        if (MediaQuery.of(context).size.height > 670)
          Expanded(child: SizedBox()),

        // Remove os dados de conferência em andamento
        if (_conferenciaEmAndamento)
          ElevatedButton.icon(
            onPressed: _limparBancoDeDadosConferencias,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            icon: Icon(Icons.cancel),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Cancelar a conferência patrimonial"),
              ],
            ),
          ).animate(
            effects: [
              FadeEffect(
                delay: const Duration(
                  milliseconds: 30, // * index,
                ),
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),

        //Remove os dados de patrimônio e conferência em andamento
        if (_dataAtualizacao != null)
          ElevatedButton.icon(
            onPressed: _limparBancoDeDados,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            icon: Icon(Icons.delete_forever),
            label: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Limpar todos os dados locais"),
              ],
            ),
          ).animate(
            effects: [
              FadeEffect(
                delay: const Duration(
                  milliseconds: 30, // * index,
                ),
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
      ],
    );
  }
}
