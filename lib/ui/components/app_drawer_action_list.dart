import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:patrimonio/ui/widgets/drawer_option.dart';

import 'package:patrimonio/app/utils/help_dialog.dart' as helper;

class AppDrawerActionList extends StatelessWidget {
  const AppDrawerActionList({super.key});

  @override
  Widget build(BuildContext context) {
    bool continuarConferencia =
        context.watch<ConferenciaProvider>().tamanhoLista > 0;
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ir para o menu inicial
        const DrawerOption(
          route: AppRoutes.menuInicial,
          buttonText: "Início",
          icon: Icons.home,
        ),

        // Conferência patrimonial
        if (!continuarConferencia)
          // Iniciar
          const DrawerOption(
            route: AppRoutes.selecionaUlPage,
            buttonText: "Conferência Patrimonial",
            icon: Icons.barcode_reader,
            helperFunction: helper.showConferenciaHelpDialog,
          )
        else
          // Continuar uma existente
          const DrawerOption(
            popOnNavigate: false,
            route: AppRoutes.conferenciaPage,
            buttonText: "Continuar a conferência",
            icon: Icons.barcode_reader,
            helperFunction: helper.showContinuarConferenciaHelpDialog,
          ),

        // Ir para as configurações do app
        const DrawerOption(
          route: AppRoutes.configuracoesPage,
          buttonText: "Configurações",
          icon: Icons.settings,
          helperFunction: helper.showSettingsHelpDialog,
        ),
      ],
    );
  }
}
