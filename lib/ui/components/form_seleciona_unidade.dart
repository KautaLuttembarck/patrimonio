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

class FormSelecionaUnidade extends StatefulWidget {
  const FormSelecionaUnidade({super.key});

  @override
  State<FormSelecionaUnidade> createState() => _FormSelecionaUnidadeState();
}

class _FormSelecionaUnidadeState extends State<FormSelecionaUnidade> {
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
          listagemPatrimonial = patrimonios;
          _precisaAtualizar = false;
          _isLoadingPatrimonios = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    SpDatabaseService().getListaUa().then((data) {
      final List<dynamic> decodedList = jsonDecode(data);

      uaDropdownList =
          decodedList.map((item) => DropdownItem.fromUaJson(item)).toList();

      setState(() {
        _isLoadingListaUa = false;
      });
    });
    context.read<LocalDatabaseService>().precisaAtualizar().then(
      (precisa) => setState(() => _precisaAtualizar = precisa),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DropdownItem> uaDropdownList = [];
  List<DropdownItem> ulDropdownList = [];

  bool _isLoadingListaUa = true;
  bool _isLoadingListaUl = true;
  bool _isLoadingPatrimonios = false;
  bool _precisaAtualizar = false;

  int? idUaSelecionada;
  int? idUlSelecionada;
  String? idResponsavelSelecionado;

  List<Patrimonio> listagemPatrimonial = [];
  late ScrollController _scrollController;
  DropdownItem? _selectedUa;
  DropdownItem? _selectedUl;
  String? _errorTextUl;

  @override
  Widget build(BuildContext context) {
    bool conferenciaAndamento =
        context.watch<ConferenciaProvider>().tamanhoLista > 0;
    return Form(
      child: Column(
        spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor da Unidade Administrativa (UA)
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
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
                      isEnabled: !conferenciaAndamento,
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
                          listagemPatrimonial = [];
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
            duration: Duration(milliseconds: 300),
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
                      isEnabled: !conferenciaAndamento,
                      label: 'Unidade de Localização (UL)',
                      hint: 'Selecione a Unidade Localização',
                      searchHint: 'Pesquisar UL...',
                      items: ulDropdownList,
                      value: _selectedUl,
                      isRequired: true,
                      errorText: _errorTextUl,
                      prefixIcon: Icon(
                        Icons.place,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onChanged: (value) async {
                        setState(() {
                          _selectedUl = value;
                          _errorTextUl = null;
                          idUlSelecionada = int.parse(value?.id ?? '0');
                        });

                        final patrimonios = await context
                            .read<LocalDatabaseService>()
                            .getPatrimoniosDaUl(idUlSelecionada!);

                        setState(() => listagemPatrimonial = patrimonios);
                      },
                    ),
          ).animate(
            target: (idUaSelecionada != null) ? 1 : 0,
            effects: [
              FadeEffect(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),

          // Listview dos patrimônios
          if (idUaSelecionada != null && idUlSelecionada != null)
            Expanded(
              child:
                  listagemPatrimonial.isEmpty
                      ? Center(
                        child: Text(
                          _precisaAtualizar
                              ? "Baixe ou atualize os dados locais para visualizar os patrimônios associados a esta Localização (UL)"
                              : "Não existem patrimônios associados a esta Localização (UL)",
                          textAlign: TextAlign.center,
                        ),
                      )
                      : RawScrollbar(
                        controller: _scrollController,
                        radius: Radius.circular(10),
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: listagemPatrimonial.length,
                          itemBuilder: (context, index) {
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                tileColor: Colors.transparent,
                                title: Text(
                                  listagemPatrimonial[index].nAntigo != ""
                                      ? "Patrimônio: ${listagemPatrimonial[index].patrimonio}\nNº Antigo: ${listagemPatrimonial[index].nAntigo}"
                                      : "Patrimônio: ${listagemPatrimonial[index].patrimonio}",
                                ),
                                dense: true,
                                subtitle: Text(
                                  listagemPatrimonial[index].descricao,
                                ),
                              ),
                            );
                          },
                        ).animate(
                          effects: [
                            FadeEffect(
                              delay: Duration(milliseconds: 100),
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
            ).animate(
              effects: [
                FadeEffect(
                  delay: Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),

          // Botão para iniciar a conferência patrimonial
          if (!_precisaAtualizar &&
              idUaSelecionada != null &&
              idUlSelecionada != null &&
              !conferenciaAndamento)
            ElevatedButton(
              onPressed:
                  listagemPatrimonial.isEmpty
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    listagemPatrimonial.isEmpty
                        ? "Selecione uma UL com patrimônios"
                        : "Iniciar a conferência Patrimonial",
                  ),
                ],
              ),
            ).animate(
              effects: [
                FadeEffect(
                  delay: Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),

          if (conferenciaAndamento)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.conferenciaPage);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Continuar a conferência Patrimonial")],
              ),
            ).animate(
              effects: [
                FadeEffect(
                  delay: Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),

          if (idUaSelecionada != null &&
              idUlSelecionada != null &&
              _precisaAtualizar)
            OutlinedButton(
              onPressed: _isLoadingPatrimonios ? null : obtemDadosPatrimoniais,
              child:
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
                          Icon(Icons.security_update),
                          Text(
                            _precisaAtualizar
                                ? "Atualizar dados"
                                : "Baixar Patrimônios",
                          ),
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
      ),
    );
  }
}
