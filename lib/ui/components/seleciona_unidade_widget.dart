import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:patrimonio/app/services/sp_database_service.dart';
import 'package:patrimonio/app/models/dropdown_item.dart';
import 'package:patrimonio/ui/widgets/dropdown_search.dart';
import 'package:patrimonio/app/services/local_database_service.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';

class SelecionaUnidadeWidget extends StatefulWidget {
  const SelecionaUnidadeWidget({super.key});

  @override
  State<SelecionaUnidadeWidget> createState() => _SelecionaUnidadeWidgetState();
}

class _SelecionaUnidadeWidgetState extends State<SelecionaUnidadeWidget> {
  void obtemDadosPatrimoniais() async {
    setState(() => _isLoadingPatrimonios = true);
    bool result = await SpDatabaseService().getListaPatrimonios(context);
    if (mounted) {
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar os dados de patrimonio!"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Clarity.sendCustomEvent(
          "Erro ao obter os dados patrimoniais na tela de Seleção de UL",
        );
        setState(() => _isLoadingPatrimonios = false);
      } else {
        Clarity.sendCustomEvent(
          "Obteve os dados patrimoniais na tela de Seleção de UL",
        );
        final patrimonios = await context
            .read<LocalDatabaseService>()
            .getPatrimoniosDaUl(idUlSelecionada!);

        setState(() {
          _listagemPatrimonial = patrimonios;
          _precisaAtualizar = false;
          _isLoadingPatrimonios = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _conferenciaAndamento =
        context.watch<ConferenciaProvider>().tamanhoLista > 0;
  }

  @override
  void initState() {
    super.initState();
    SpDatabaseService().getListaUa().then((data) {
      final List<dynamic> decodedList = jsonDecode(data);

      uaDropdownList =
          decodedList.map((item) => DropdownItem.fromUaJson(item)).toList();

      setState(() => _isLoadingListaUa = false);
    });
    context.read<LocalDatabaseService>().precisaAtualizar().then(
      (precisa) => setState(() => _precisaAtualizar = precisa),
    );
  }

  late bool _conferenciaAndamento;

  List<DropdownItem> uaDropdownList = [];
  List<DropdownItem> ulDropdownList = [];

  bool _isLoadingListaUa = true;
  bool _isLoadingListaUl = true;
  bool _isLoadingPatrimonios = false;
  bool _precisaAtualizar = false;

  int? idUaSelecionada;
  int? idUlSelecionada;

  List<Patrimonio> _listagemPatrimonial = [];
  DropdownItem? _selectedUa;
  DropdownItem? _selectedUl;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 25,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor da Unidade Administrativa (UA)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _isLoadingListaUa
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CircularProgressIndicator(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                  : DropdownSearch(
                    isEnabled: !_conferenciaAndamento,
                    label: 'Unidade Administrativa (UA)',
                    hint: 'Selecione a Unidade Administrativa',
                    searchHint: 'Pesquisar UA...',
                    items: uaDropdownList,
                    value: _selectedUa,
                    isRequired: true,
                    prefixIcon: Icon(
                      Icons.maps_home_work_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedUa = value;
                        idUaSelecionada = int.parse(value?.id ?? '0');
                        _selectedUl = null;
                        idUlSelecionada = null;
                        _isLoadingListaUl = true;
                        _listagemPatrimonial = [];
                      });
                      SpDatabaseService().getListaUl(idUaSelecionada!).then((
                        data,
                      ) {
                        final List<dynamic> decodedList = jsonDecode(data);
                        setState(() {
                          ulDropdownList =
                              decodedList
                                  .map(
                                    (item) => DropdownItem.fromUlJson(item),
                                  )
                                  .toList();
                          _isLoadingListaUl = false;
                        });
                      });
                    },
                  ),
        ),

        // Seletor da Unidade de Localização (UL)
        // e consequente responsável
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _isLoadingListaUl
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CircularProgressIndicator(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                  : DropdownSearch(
                    isEnabled: !_conferenciaAndamento,
                    label: 'Unidade de Localização (UL)',
                    hint: 'Selecione a Unidade Localização',
                    searchHint: 'Pesquisar UL...',
                    items: ulDropdownList,
                    value: _selectedUl,
                    isRequired: true,
                    errorText: null,
                    prefixIcon: Icon(
                      Icons.place,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onChanged: (value) async {
                      setState(() {
                        _selectedUl = value;
                        idUlSelecionada = int.parse(value?.id ?? '0');
                      });

                      final patrimonios = await context
                          .read<LocalDatabaseService>()
                          .getPatrimoniosDaUl(idUlSelecionada!);

                      setState(() => _listagemPatrimonial = patrimonios);
                    },
                  ),
        ).animate(
          target: (idUaSelecionada != null) ? 1 : 0,
          effects: [
            const FadeEffect(
              delay: Duration(milliseconds: 200),
              duration: Duration(milliseconds: 200),
            ),
          ],
        ),

        // Listview dos patrimônios
        if (idUaSelecionada != null && idUlSelecionada != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child:
                  _listagemPatrimonial.isEmpty
                      ? Center(
                        child: Text(
                          _precisaAtualizar
                              ? "É necessário baixar os patrimônios para prosseguir com a conferência"
                              : "Não existem patrimônios para conferência nesta Localização (UL)",
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "${_listagemPatrimonial.length}\n",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "patrimônio${_listagemPatrimonial.length > 1 ? "s" : ""} para conferência nesta localização (UL)",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ).animate(
            effects: [
              const FadeEffect(
                delay: Duration(milliseconds: 100),
                duration: Duration(milliseconds: 300),
              ),
            ],
          ),

        // Botão para iniciar a conferência patrimonial
        if (!_precisaAtualizar &&
            idUaSelecionada != null &&
            idUlSelecionada != null &&
            !_conferenciaAndamento)
          ElevatedButton.icon(
            onPressed:
                _listagemPatrimonial.isEmpty
                    ? null
                    : () {
                      context
                          .read<LocalDatabaseService>()
                          .copiarParaConferenciaPorUl(idUlSelecionada!)
                          .then((_) {
                            if (context.mounted) {
                              Navigator.of(context).pushNamed(
                                AppRoutes.conferenciaPage,
                              );
                            }
                          });
                    },
            icon: Icon(
              _listagemPatrimonial.isEmpty
                  ? Icons.highlight_remove
                  : Icons.play_circle_outline,
            ),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _listagemPatrimonial.isEmpty
                      ? "Selecione uma UL com patrimônios"
                      : "Iniciar a conferência Patrimonial",
                ),
              ],
            ),
          ).animate(
            target:
                (!_precisaAtualizar &&
                        idUaSelecionada != null &&
                        idUlSelecionada != null &&
                        !_conferenciaAndamento)
                    ? 1
                    : 0,
            effects: [
              const ScaleEffect(
                curve: Curves.easeInOutBack,
                delay: Duration(milliseconds: 100),
                duration: Duration(milliseconds: 300),
              ),
            ],
          ),

        if (_conferenciaAndamento)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.conferenciaPage);
            },
            icon: Icon(Icons.redo),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Continuar a conferência Patrimonial")],
            ),
          ).animate(
            target: _conferenciaAndamento ? 1 : 0,
            effects: [
              const ScaleEffect(
                curve: Curves.easeInOutBack,
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 300),
              ),
            ],
          ),

        if (idUaSelecionada != null &&
            idUlSelecionada != null &&
            _precisaAtualizar)
          OutlinedButton.icon(
            onPressed: _isLoadingPatrimonios ? null : obtemDadosPatrimoniais,
            icon: Icon(Icons.security_update),
            label:
                _isLoadingPatrimonios
                    ? Center(
                      child: CircularProgressIndicator(
                        constraints: BoxConstraints(
                          maxWidth: 25,
                          maxHeight: 25,
                          minWidth: 25,
                          minHeight: 25,
                        ),
                      ).animate(
                        effects: [
                          FadeEffect(
                            delay: Duration(milliseconds: 30),
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    )
                    : Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Baixar Patrimônios"),
                      ],
                    ),
          ).animate(
            effects: [
              FadeEffect(
                delay: Duration(milliseconds: 30),
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
      ],
    );
  }
}
