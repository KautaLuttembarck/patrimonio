import 'package:flutter/material.dart';
import 'package:patrimonio/app/services/sp_database_service.dart';
import 'package:patrimonio/app/services/local_database_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class FormConfiguracoes extends StatefulWidget {
  const FormConfiguracoes({super.key});

  @override
  State<FormConfiguracoes> createState() => _FormConfiguracoesState();
}

class _FormConfiguracoesState extends State<FormConfiguracoes> {
  bool _downloadingData = false;
  bool _conferenciaEmAndamento = false;
  double _downloadProgress = 0;
  String? _dataAtualizacao;
  String _situacaoTransferencia = "Transferindo dados patrimoniais";

  void obtemDadosPatrimoniais() async {
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

  void limparBancoDeDados() async {
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

  void limparBancoDeDadosConferencias() async {
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
      spacing: 20,
      children: [
        SizedBox(height: 30),
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
          child: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.secondary,
            size: 90,
          ).animate(
            onPlay: (controller) => controller.repeat(),
            effects: [RotateEffect(duration: Duration(seconds: 5))],
          ),
        ),
        SizedBox(height: 20),
        Text(
          _dataAtualizacao != null
              ? "Dados patrimoniais atualizados pela última vez em $_dataAtualizacao"
              : "Sem registro de obtenção dos dados patrimoniais!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        if (_downloadingData || (_downloadProgress > 0))
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.6, // Largura da borda
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 15,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(_situacaoTransferencia),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _downloadProgress > 0 ? 1 : null,
                    minHeight: 5,
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

        ElevatedButton(
          onPressed:
              ((_downloadingData || (_downloadProgress > 0))
                  ? null
                  : obtemDadosPatrimoniais),
          child: Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.security_update), Text("Baixar Patrimônios")],
          ),
        ),

        Expanded(child: SizedBox()),

        // Remove os dados de conferência em andamento
        if (_conferenciaEmAndamento)
          ElevatedButton(
            onPressed: limparBancoDeDadosConferencias,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            child: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel),
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
          ElevatedButton(
            onPressed: limparBancoDeDados,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            child: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever),
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
