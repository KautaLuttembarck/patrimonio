import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/ui/widgets/item_menu_principal.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:patrimonio/app/utils/help_dialog.dart' as helper;

class InitialMenuPageActionList extends StatelessWidget {
  const InitialMenuPageActionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (context.watch<ConferenciaProvider>().tamanhoLista == 0)
          // Iniciar a conferência patrimonial
          const ItemMenuPrincipal(
            helpDialog: helper.showConferenciaHelpDialog,
            icone: Icons.barcode_reader,
            acao: "Conferência Patrimônial",
            explicacao: "Inicia a conferência do patrimônio de um setor",
            destino: AppRoutes.selecionaUlPage,
          )
        else
          // Continuar uma conferência anterior, caso exista.
          const ItemMenuPrincipal(
            helpDialog: helper.showContinuarConferenciaHelpDialog,
            icone: Icons.barcode_reader,
            acao: "Continuar a Conferência",
            explicacao: "Continua a conferência do patrimônio",
            destino: AppRoutes.conferenciaPage,
            popOnNavigate: false,
          ),

        // Ajustar as configurações
        const ItemMenuPrincipal(
          helpDialog: helper.showSettingsHelpDialog,
          icone: Icons.settings,
          acao: "Configurações",
          explicacao: "Configurações necessárias ao uso do aplicativo",
          destino: AppRoutes.configuracoesPage,
        ),
      ],
    );
  }
}
