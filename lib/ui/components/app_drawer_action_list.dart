import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:patrimonio/ui/widgets/drawer_option.dart';

import 'package:patrimonio/app/utils/help_dialog.dart' as helper;
import 'package:patrimonio/ui/widgets/logout_button.dart';

class AppDrawerActionList extends StatelessWidget {
  const AppDrawerActionList({super.key});

  @override
  Widget build(BuildContext context) {
    bool continuarConferencia =
        context.watch<ConferenciaProvider>().tamanhoLista > 0;
    return Column(
      spacing: 0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 0.5, height: 0),

        // Ir para o menu inicial
        const DrawerOption(
          route: AppRoutes.menuInicial,
          buttonText: "Início",
          icon: Icons.home,
        ),
        const Divider(thickness: 0.5, height: 0),

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
        const Divider(thickness: 0.5, height: 0),

        // Ir para as configurações do app
        const DrawerOption(
          route: AppRoutes.configuracoesPage,
          buttonText: "Configurações",
          icon: Icons.settings,
          helperFunction: helper.showSettingsHelpDialog,
        ),
        const Divider(thickness: 0.5, height: 0),

        // Logout action
        const LogoutButton(),
        const Divider(thickness: 0.5, height: 0),
      ],
    );
  }
}
